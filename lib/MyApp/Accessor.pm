package MyApp::Accessor;

use strict;
use warnings;

# MyApp::Accessor class

sub new {
    my $class = shift;
    my $self  = {};

    no strict 'refs';

    for my $foo ( @_ ) {
        *{"${class}::$foo"} = sub {
            my ($self, $val) = @_;

            $self->{ $foo } = $val if defined $val;
            $self->{ $foo };
        };
    }

    bless $self, $class;
}

1;

=pod

SYNOPSYS:

    use MyApp::Accessor;

    my $app = MyApp::Accessor->new(
        'param_name_1',
        'param_name_2',
        ...
    );

    $app->param_name_1( 'param_value_1' );

    warn $app->param_name_1;
