package Riak::Tiny::Object;

use strict;
use warnings;
use Mojo::Base -base;
use Devel::Dwarn;
use Riak::Tiny::Link;
use Mojo::JSON;

has [qw/url client tx bucket key value/];

sub json {
    my $self = shift;
    return Mojo::JSON->new->decode($self->value)
      if $self->tx->res->headers->content_type eq 'application/json';
}

sub add_link {
    my $self = shift;

    return if !@_;

    my $link;

    while (my ($name, $url) = splice @_, 0, 2) {
        $link .= "</riak/$url>; riaktag=\"$name\"";
        $link .= ', ' if @_;
    }

    my $tx = $self->client->put(
        $self->tx->req->url,
        {   'Link'         => $link,
            'Content-Type' => $self->tx->res->headers->content_type,
        },
        $self->tx->res->body
    );

    return if $tx->res->code != 204;

    return $self->get;
}

sub reset_links {
    my $self = shift;

    my $link;

    my $tx =
      $self->client->put($self->tx->req->url,
        {'Content-Type' => $self->tx->res->headers->content_type,},
        $self->tx->res->body);

    return if $tx->res->code != 204;

    return $self->tx($tx);
}

sub links {
    my $self = shift;

    my $url  = $self->tx->req->url;
    my $host = $url->scheme . '://' . $url->host . ':' . $url->port;

    my $header = $self->tx->res->headers->header('Link');
    return if !$header;

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

sub get {
    my $self = shift;

    my $url  = $self->tx->req->url;
    my $host = $url->scheme . '://' . $url->host . ':' . $url->port;

    my $tx =
      $self->client->get($host . '/riak/' . $self->bucket . '/' . $self->key);

    return if $tx->res->code == 404;

    $self->tx($tx);
    $self->value($tx->res->body);

    return $self;
}

sub delete {
    my $self = shift;

    my $url  = $self->tx->req->url;
    my $host = $url->scheme . '://' . $url->host . ':' . $url->port;

    my $tx =
      $self->client->delete(
        $host . '/riak/' . $self->bucket . '/' . $self->key);

    return $self->tx($tx);
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

=head2 get

Refresh object from server, returns object

=head2 delete

Delete keyvalue

=cut
