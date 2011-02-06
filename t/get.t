use Test::Most;

use Riak::Tiny;
use Devel::Dwarn;

ok my $n = Riak::Tiny->new(host => 'http://localhost:8098');

ok !$n->new_object(bucket => 'bad/key' => 'value');

ok my $obj = $n->new_object(bucket => key => 'value');
is ref $obj     => 'Riak::Tiny::Object';
is $obj->bucket => 'bucket';
is $obj->key    => 'key';
is $obj->value  => 'value';
ok !$obj->json;

ok $obj = $n->get(bucket => 'key');
is ref $obj     => 'Riak::Tiny::Object';
is $obj->bucket => 'bucket';
is $obj->key    => 'key';
is $obj->value  => 'value';

ok my $obj2 = $n->new_object(bucket => key2 => '{"json":"value"}');
is_deeply $obj2->json => {json => 'value'};

ok !$obj->add_link;
ok $obj->add_link(
    obj2 => 'bucket/key2',
    obj3 => 'bucket/key3',
);

like $obj->tx->res->headers->header('Link') =>
  qr|</riak/bucket/key2>; riaktag="obj2", </riak/bucket/key3>; riaktag="obj3"|;
ok my @objs = $obj->links;
is @objs => 2;

is $objs[0]->tag => 'obj2';
is $objs[1]->tag => 'obj3';

is $objs[0]->linked_to->key => 'key2';
ok !$objs[1]->linked_to, 'no key3 keyvalue';

ok $obj->reset_links;
ok !$obj->links;
is $obj->get->tx->res->headers->header('Link') => '</riak/bucket>; rel="up"';

ok my $bucket = $n->get('bucket');
is ref $bucket => 'Riak::Tiny::Bucket';
eq_or_diff [$bucket->keys] => [qw/ key key2 /];
is $bucket->get('key')->value => 'value';

ok $obj2->delete, 'delete key2';
ok !$obj2->get, 'confirmed';

$n->new_object(bucket => key2 => 'value4');
$n->new_object(bucket => key3 => 'value5');
is_deeply [sort $bucket->delete_keys] => [qw/key key2 key3/],
  'delete all keys in bucket';
ok !$n->get('bucket')->keys, 'confirmed';

done_testing;
