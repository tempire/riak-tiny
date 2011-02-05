use Test::Most;

use Riak::Tiny;

ok my $n = Riak::Tiny->new(host => 'http://localhost:8098');
ok my $obj = $n->get('photos/3846452652');
is ref $obj => 'Riak::Tiny::Object';

ok $obj->add_link(
    [set => 'application/json' => 'photosets/72157618164628634'],
    [foo => 'bar/baz']);

like $n->get('photos/3846452652')->tx->res->headers->header('Link') =>
  qr|</riak/photosets/72157618164628634>; riaktag="set"|;
like $n->get('photos/3846452652')->tx->res->headers->header('Link') =>
  qr|</riak/bar/baz>; riaktag="foo"|;

done_testing;
