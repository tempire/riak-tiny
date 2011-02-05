package Riak::Tiny::Object;

use strict;
use warnings;
use Mojo::Base -base;
use Devel::Dwarn;

has [qw/url client tx/];

sub json {
    shift->tx->res->json;
}

sub add_link {
    my $self = shift;

    my $link;

    while (my ($name, $url) = splice @_, 0, 2) {
        $link .= "</riak/$url>; riaktag=\"$name\"";
        $link .= ', ' if @_;
    }

    return 1
      if $self->client->put(
        $self->tx->req->url,
        {   'Link'         => $link,
            'Content-Type' => 'application/json'
        },
        $self->tx->res->body
      )->res->code eq 200;
}

1;

=head1 NAME

Riak::Tiny

=head1 DESCRIPTION

Riak object

=head1 METHODS

=head2 json

JSON response, transormed into perl structure (hashref|arrayref)

=cut
