package Riak::Tiny::Bucket;

use strict;
use warnings;
use Mojo::Base -base;
use Riak::Tiny;
use Riak::Tiny::Object;

has [qw/url client tx bucket/];

sub keys {
    my $self = shift;

    return
      @{$self->client->get($self->bucket . "?keys=true")->res->json->{keys}};
}

sub get {
    my $self   = shift;
    my $bucket = $self->bucket;
    my $key    = shift || '';

    my $tx = $self->client->get("$bucket/$key");
    $@ = $tx->res->code, return if $tx->res->code != 200;

    return Riak::Tiny::Object->new(
        client => $self->client,
        bucket => $bucket,
        key    => $key,
        value  => $tx->res->body
    );
}

sub delete_keys {
    my $self = shift;

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
