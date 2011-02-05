use Test::Most;

use Riak::Tiny;
use Devel::Dwarn;

ok my $n = Riak::Tiny->new(host => 'http://localhost:8098');
ok my $obj = $n->get('photos/3846452652');
is ref $obj => 'Riak::Tiny::Object';

ok $obj->add_link(
    set => 'photosets/72157618164628634',
    foo => 'bar/baz'
);

like $n->get('photos/3846452652')->tx->res->headers->header('Link') =>
  qr|</riak/photosets/72157618164628634>; riaktag="set"|;
like $n->get('photos/3846452652')->tx->res->headers->header('Link') =>
  qr|</riak/bar/baz>; riaktag="foo"|;

ok my @objs = $obj->links;
is @objs => 2;

is $objs[0]->tag => 'set';
is $objs[1]->tag => 'foo';

is $objs[0]->get->url => 'photosets/72157618164628634';
is $objs[1]->get->url => 'bar/baz';

#is $objs[2]->get->url => 'photos';
#ok $objs[2]->get->keys;

#eq_or_diff [$obj->links] =>
#  [{set => 'photosets/72157618164628634'}, {foo => 'bar/baz'},];

#ok $obj->reset_links;
#is $n->get('photos/3846452652')->tx->res->headers->header('Link') => '</riak/photos>; rel="up"';

done_testing;
