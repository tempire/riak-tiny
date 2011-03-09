use Riak::Tiny;
use Test::More;

ok my $n = Riak::Tiny->new(host => 'http://localhost:8098');

ok !$n->new_object(bucket => 'bad/key' => 'value');

subtest 'create bucket/key and delete' => sub {
    ok my $obj = $n->new_object(bucket => key => 'value'), 'create';
    is ref $obj     => 'Riak::Tiny::Object';
    is $obj->bucket => 'bucket';
    is $obj->key    => 'key';
    is $obj->value  => 'value';
    ok !$obj->json;
    ok $obj->delete, 'delete';
    ok !$n->get(bucket => 'key'), 'confirmed';
};

subtest 'create bucket/key, get and delete' => sub {
    ok $n->new_object(bucket => key => 'value'), 'create';
    ok my $obj = $n->get(bucket => 'key'), 'get';
    is ref $obj     => 'Riak::Tiny::Object';
    is $obj->bucket => 'bucket';
    is $obj->key    => 'key';
    is $obj->value  => 'value';

    ok $obj->delete, 'delete';
    ok !$obj->get, 'confirmed';
};


subtest 'delete bucket keys' => sub {
    ok $n->new_object(bucket => key  => 'value');
    ok $n->new_object(bucket => key2 => 'value2');
    ok $n->new_object(bucket => key3 => 'value3');

    ok my $bucket = $n->get('bucket');
    is_deeply [sort $bucket->keys] => [qw/ key key2 key3 /];

    is_deeply [sort $bucket->delete_keys] => [qw/key key2 key3/],
      'delete all keys in bucket';
    ok !$n->get('bucket')->keys, 'confirmed';
};

subtest 'json decoding' => sub {
    ok my $obj = $n->new_object(bucket => key => '{"json":"value"}'),
      'create';
    is_deeply $obj->json => {json => 'value'}, 'json decoded';
    ok $obj->delete, 'delete';
};

subtest 'links' => sub {
    ok my $obj = $n->new_object(bucket => key => 'value');
    ok !$obj->add_link;
    ok $obj->add_link(
        obj2 => 'bucket/key2',
        obj3 => 'bucket/key3',
    );

    like $obj->client->tx->res->headers->header('Link') =>
      qr|</riak/bucket/key2>; riaktag="obj2", </riak/bucket/key3>; riaktag="obj3"|;
    ok my @objs = $obj->links;
    is @objs => 2;

    is $objs[0]->tag => 'obj2';
    is $objs[1]->tag => 'obj3';

    ok !$objs[0]->linked_to, 'linked-to key does not exist';
    ok !$objs[1]->linked_to, 'linked-to key does not exist';

    ok $n->new_object(bucket => key2 => 'value2'), 'create linked-to key';
    is $objs[0]->linked_to->key => 'key2', 'linked-to key exists';

    ok $obj->clear_links;
    ok !$obj->links;
    is $obj->get->client->tx->res->headers->header('Link') =>
      '</riak/bucket>; rel="up"';
};

subtest 'list buckets and bucket keys' => sub {
    ok grep $_ eq 'bucket', $n->buckets, 'list buckets';
    ok my $bucket = $n->get('bucket');
    is ref $bucket => 'Riak::Tiny::Bucket';
    is_deeply [$bucket->keys] => [qw/ key key2 /];
};

done_testing;
