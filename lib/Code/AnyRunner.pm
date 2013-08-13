package Code::AnyRunner;
use strict;
use warnings;
our $VERSION = '0.01';

use Code::AnyRunner::ConfigLoader;
use Code::AnyRunner::Runner;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {
        recipes => {},
        timeout_sec => $opt{timeout_sec} || 1,
    }, $class;

    my $loader = Code::AnyRunner::ConfigLoader->new;
    my $config = $loader->load($opt{config_path});

    $self->load_recipes($config);

    $self;
}

sub add_recipe {
    my ($self, %opt) = @_;

    my $recipe_name = $opt{name};
    delete $opt{name};

    $self->{recipes}->{$recipe_name} = \%opt;
}

sub load_recipes {
    my ($self, $config) = @_;

    foreach my $recipe_name (keys %$config) {
        if ($recipe_name ne "_") {
            my $recipe = $config->{$recipe_name};
            $recipe->{name} = $recipe_name;
            $self->add_recipe(%$recipe);
        }
    }
}

sub run_code {
    my ($self, $recipe_name, $code, $input) = @_;

    my $recipe = $self->{recipes}->{$recipe_name};
    my $runner = Code::AnyRunner::Runner->new(
        recipe => $recipe,
        code    => $code,
    );
    $runner->execute($input);
}

1;
__END__

=head1 NAME

Code::AnyRunner -

=head1 SYNOPSIS

  use Code::AnyRunner;

=head1 DESCRIPTION

Code::AnyRunner is

=head1 AUTHOR

Kosuke Asami E<lt>tfortress58@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
