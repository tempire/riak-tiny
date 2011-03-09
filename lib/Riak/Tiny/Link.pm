package Riak::Tiny::Link;

use strict;
use warnings;
use Mojo::Base -base;
use Riak::Tiny;

has [qw/url client tag host/];

sub linked_to { Riak::Tiny->new(host => $_[0]->client->host)->get(split '/', shift->url) }

1;

=head1 NAME

Riak::Tiny::Link

=head1 DESCRIPTION

Riak link

=head1 METHODS

=head2 linked_to

Returns list of L<Riak::Tiny::Object>s that current object links to.

=cut
