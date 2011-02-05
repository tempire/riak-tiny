package Riak::Tiny::Object;

use strict;
use warnings;
use Mojo::Base -base;
use Devel::Dwarn;
use Riak::Tiny::Link;

has [qw/url client tx tag/];

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

    my $url  = $self->tx->req->url;
    my $host = $url->scheme . '://' . $url->host . ':' . $url->port;

    my $header = $self->tx->res->headers->header('Link');
    my @links = split ',', substr($header, 0, rindex($header, ','));

    #return map { { $2 => $1 } if /<\/riak\/(.+)>; (?:riaktag|rel)="(.+)"/ }
    return map {

        /<\/riak\/(.+)>; (?:riaktag)="(.+)"/;

        Riak::Tiny::Link->new(
            url    => $1,
            client => $self->client,
            tag    => $2,
            host   => $host
          )
    } @links;
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

=head2 links

Riak::Tiny::Link objects for each link in current object

=cut
