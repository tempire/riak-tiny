package Riak::Tiny;

use Mojo::Base -base;
use Mojo::Client;
use Riak::Tiny::Bucket;
use Riak::Tiny::Client;
use Riak::Tiny::Object;

has [qw/host client/];
has client => sub { Riak::Tiny::Client->new( host => shift->host ) };

use Riak::Tiny;

sub get {
    my $self = shift;
    my ($bucket, $key) = @_;

    my $tx = $self->client->get("$bucket/" . ($key||''));
    $@ = $tx->res->code, return if $tx->res->code != 200;

    # Key
    if ($key) {
        return Riak::Tiny::Object->new(
            client => $self->client,
            bucket => $bucket,
            key    => $key,
            value  => $tx->res->body
        );
    }

    # Bucket
    return Riak::Tiny::Bucket->new(
        client => $self->client,
        bucket => $bucket,
    );
}

sub new_object {
    my $self = shift;
    my ($bucket, $key, $value) = @_;

    my $tx = $self->client->put("$bucket/$key",
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
    my $tx = $self->client->get('?buckets=true');

    return if $tx->res->code != 200;

    return @{$tx->res->json->{buckets}};
}

1;

=head1 NAME

Riak::Tiny

=head1 DESCRIPTION

Use Perl to interact with Riak

=head1 USAGE

    my $r = Riak::Tiny->new( host => 'http://localhost:8098' );

Keys

    my $obj = $r->new_object(bucket => key => 'value');
    say $obj->bucket, $obj->key, $obj->value;

Buckets

    my $bucket = $r->bucket('bucket');
    say $_ for $bucket->keys;

    $bucket->delete_keys;

Links

    $obj->add_link(
        tag1 => 'bucket/key2',
        tag2 => 'bucket/key3',
    );

    # Get links
    my ($tag1, $tag2) = $obj->links;
    print $tag1->tag, $tag2->tag;

    # Linked-to key
    my $obj1 = $tag1->linked_to;
    print $obj1->bucket, $obj1->key, $obj1->value;

    $obj->clear_links;

=head1 METHODS

=head2 get

Get a keyvalue object

=head2 new_object

Create a keyvalue object, returns L<Riak::Tiny::Object>

=head2 buckets

List of all buckets with keys

=cut
