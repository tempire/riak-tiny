package Riak::Tiny::Client;

use Mojo::Base 'Mojo::Client';

__PACKAGE__->attr([qw/ host /]);

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
