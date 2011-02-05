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
            'Content-Type' => $self->tx->res->headers->content_type,
        },
        $self->tx->res->body
      )->res->code eq 204;
}

sub reset_links {
    my $self = shift;

    my $link;

    return 1
      if $self->client->put($self->tx->req->url,
        {'Content-Type' => $self->tx->res->headers->content_type,},
        $self->tx->res->body)->res->code eq 204;
}

sub links {
    my $self = shift;

    return map { { $2 => $1 } if /<\/riak\/(.+)>; (?:riaktag|rel)="(.+)"/ }
      split ',', $self->tx->res->headers->header('Link');
}

1;

=head1 NAME

Riak::Tiny

=head1 DESCRIPTION

Riak object

=head1 METHODS

=head2 json

JSON response, transormed into perl structure (hashref|arrayref)

=head2 add_link

Adds a link to another key

=head2 reset_links

Removes all custom links to other keys

=cut
