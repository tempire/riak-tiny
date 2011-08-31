package Riak::Tiny::Client;

use Mojo::Base 'Mojo::UserAgent';

__PACKAGE__->attr([qw/ host tx /]);

sub build_tx {
    my $self   = shift;
    my @params = @_;

    $params[1] = '/' . $params[1] if substr($params[1], 0, 1) ne '/';
    $params[1] = $self->host . '/riak' . $params[1];

    my $tx = $self->SUPER::build_tx(@params);

    $self->tx($tx);

    return $tx;
}

1;

=head1 NAME

Riak::Tiny::Client

=head1 DESCRIPTION

Subclass of Mojo::UserAgent, making the host persistent.

=head1 METHODS

Riak::Tiny::Client inherits all methods from Mojo::UserAgent and implements the following new ones.

=head2 build_tx

Builds a transaction using a persistently stored hostname

=cut
