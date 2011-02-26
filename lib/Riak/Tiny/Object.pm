package Riak::Tiny::Object;

use Mojo::Base -base;
use Mojo::JSON;
use Riak::Tiny::Link;

has [qw/url client bucket key value/];

sub json {
    my $self = shift;
    return Mojo::JSON->new->decode($self->value)
      if $self->client->tx->res->headers->content_type eq 'application/json';
}

sub add_link {
    my $self = shift;

    return if !@_;

    my $link;

    while (my ($name, $url) = splice @_, 0, 2) {
        $link .= "</riak/$url>; riaktag=\"$name\"";
        $link .= ', ' if @_;
    }

    my $tx = $self->client->tx;

    $tx = $self->client->put(
        $self->bucket . '/' . $self->key,
        {   'Link'         => $link,
            'Content-Type' => $tx->res->headers->content_type,
        },
        $tx->res->body
    );

    return if $tx->res->code != 204;

    return $self->get;
}

sub clear_links {
    my $self = shift;

    my $link;

    my $tx = $self->client->tx;

    $tx = $self->client->put(
        $self->bucket . '/' . $self->key,
        {'Content-Type' => $tx->res->headers->content_type},
        $tx->res->body
    );

    return if $tx->res->code != 204;

    return $self;
}

sub links {
    my $self = shift;

    #my $url  = $self->tx->req->url;
    #my $host = $url->scheme . '://' . $url->host . ':' . $url->port;

    my $header = $self->client->tx->res->headers->header('Link');
    return if !$header;

    my @links = split ',', substr($header, 0, rindex($header, ','));

    #return map { { $2 => $1 } if /<\/riak\/(.+)>; (?:riaktag|rel)="(.+)"/ }
    return map {

        /<\/riak\/(.+)>; (?:riaktag)="(.+)"/;

        Riak::Tiny::Link->new(
            url    => $1,
            client => $self->client,
            tag    => $2,

            #host   => $host
          )
    } @links;
}

sub get {
    my $self = shift;

    my $tx = $self->client->get($self->bucket . '/' . $self->key);

    return if $tx->res->code == 404;

    $self->value($tx->res->body);

    return $self;
}

sub delete {
    my $self = shift;

    return $self->client->delete($self->bucket . '/' . $self->key);
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

=head2 clear_links

Removes all custom links to other keys

=head2 links

Riak::Tiny::Link objects for each link in current object

=head2 get

Refresh object from server, returns object

=head2 delete

Delete keyvalue

=cut
