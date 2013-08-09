package Code::AnyRunner;
use strict;
use warnings;
our $VERSION = '0.01';

use File::Temp;
use IPC::Run qw/run timeout/;

use List::Util qw/first/;

sub new {
    my ($class, %opt) = @_;
    bless {
        settings => {},
    }, $class;
}

sub add_setting {
    my ($self, %opt) = @_;

    my $setting_name = $opt{name};
    delete $opt{name};

    $self->{settings}->{$setting_name} = \%opt;
}

sub run_code {
    my ($self, $code, $input) = @_;

    my $setting = $self->{settings}->{"perl"};

    my ($temp_fh, $temp_filename) = File::Temp::tempfile(
        SUFFIX => $setting->{code_suffix},
    );

    print $temp_fh $code;
    close $temp_fh;

    my @command = split(/ /, $setting->{execute});
    my $code_idx = first { $command[$_] eq "CODE" } (0 .. $#command);
    $command[$code_idx] = $temp_filename;

    my ($output, $error, $timeout) = ("", "", 0);
    eval {
        run \@command, \$input, \$output, \$error, timeout(1);
    };
    if ($@) {
        if ($@ =~ /timeout/) {
            $timeout = 1;
        }
        else {
            die $@;
        }
    }
    return ($output, $error, $timeout);
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
