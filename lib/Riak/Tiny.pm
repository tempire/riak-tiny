package Riak::Tiny;

use strict;
use warnings;
use Mojo::Base -base;
use Mojo::Client;
use Devel::Dwarn;
use Riak::Tiny::Object;
use Riak::Tiny::Bucket;

has [qw/host/];
has client => sub { Mojo::Client->new };

use Riak::Tiny;

sub get {
    my $self = shift;
    my ($bucket, $key) = @_;

    my $tx = $self->client->get($self->host . "/riak/$bucket/" . ($key||''));
    $@ = $tx->res->code, return if $tx->res->code != 200;

    # Key
    if ($key) {
        return Riak::Tiny::Object->new(
            client => $self->client,
            tx     => $tx,
            bucket => $bucket,
            key    => $key,
            value  => $tx->res->body
        );
    }

    # Bucket
    return Riak::Tiny::Bucket->new(
        client => $self->client,
        tx     => $tx,
        bucket => $bucket,
    );
}

sub new_object {
    my $self = shift;
    my ($bucket, $key, $value) = @_;

    my $tx = $self->client->put($self->host . "/riak/$bucket/$key",
        {'content-type' => 'application/json'}, $value);

    return if $tx->res->code != 204;

    return Riak::Tiny::Object->new(
        client => $self->client,
        tx     => $tx,
        bucket => $bucket,
        key    => $key,
        value  => $value
    );
}

sub buckets {
    my $self = shift;
    my $tx = $self->client->get($self->host . '/riak?buckets=true');

    return if $tx->res->code != 200;

    return @{$tx->res->json->{buckets}};
}

1;

=head1 NAME

Riak::Tiny

=head1 DESCRIPTION

Use Perl to interact with Riak

=head1 METHODS

=head2 get

Get a keyvalue object

=head2 new_object

Create a keyvalue object, returns L<Riak::Tiny::Object>

=head2 buckets

List of all buckets with keys

=cut
