package Code::AnyRunner;
use strict;
use warnings;
our $VERSION = '0.01';

use Code::AnyRunner::Runner;

sub new {
    my ($class, %opt) = @_;
    bless {
        settings => {},
        timeout_sec => $opt{timeout_sec} || 1,
    }, $class;
}

sub add_setting {
    my ($self, %opt) = @_;

    my $setting_name = $opt{name};
    delete $opt{name};

    $self->{settings}->{$setting_name} = \%opt;
}

sub run_code {
    my ($self, $setting_name, $code, $input) = @_;

    my $setting = $self->{settings}->{$setting_name};
    my $runner = Code::AnyRunner::Runner->new(
        setting => $setting,
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
