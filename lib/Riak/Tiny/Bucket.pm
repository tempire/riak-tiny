package Riak::Tiny::Bucket;

use strict;
use warnings;
use Mojo::Base -base;
use Devel::Dwarn;
use Riak::Tiny;
use Riak::Tiny::Object;

has [qw/url client tx bucket/];

sub keys {
    my $self = shift;

    my $url = $self->tx->req->url;

    return @{$self->client->get($url . "?keys=true")->res->json->{keys}};
}

sub get {
    my $self = shift;
    my $key  = shift;

    my $url  = $self->tx->req->url;
    my $host = $url->scheme . '://' . $url->host . ':' . $url->port;

    return Riak::Tiny->new(host => $host)->get($self->bucket => $key);
}

sub delete_keys {
    my $self = shift;

    my $url = $self->tx->req->url;

    return map {
        Riak::Tiny::Object->new(
            client => $self->client,
            tx     => $self->tx,
            bucket => $self->bucket,
            key    => $_,
        )->delete;
        $_;
    } $self->keys;
}

1;

=head1 NAME

Riak::Tiny::Bucket

=head1 DESCRIPTION

Riak bucket object

=head1 METHODS

=head2 keys

All keys in bucket

=head2 get

Get key from this bucket

=head2 delete_keys

Delete all keys in bucket

=cut
