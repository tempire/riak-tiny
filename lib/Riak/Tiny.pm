package Riak::Tiny;

use strict;
use warnings;
use Mojo::Base -base;
use Mojo::Client;
use Devel::Dwarn;
use Riak::Tiny::Object;

has [qw/host/];
has client => sub { Mojo::Client->new };

use Riak::Tiny;

sub get {
    my $self = shift;
    my $url = shift;

    my $tx = $self->client->get($self->host . '/riak/' . $url );

    return Riak::Tiny::Object->new( url => $url, client => $self->client, tx => $tx );
}

1;
