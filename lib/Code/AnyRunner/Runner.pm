package Code::AnyRunner::Runner;
use strict;
use warnings;

use IPC::Run qw/start finish timeout/;
use File::Temp;
use List::Util qw/first/;
use Unix::Getrusage;

use Code::AnyRunner::Result;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {}, $class;

    my $recipe = $opt{recipe};
    my ($temp_fh, $temp_filename) = File::Temp::tempfile(
        SUFFIX => $recipe->{code_suffix},
    );

    my $code = $opt{code};
    print $temp_fh $code;
    close $temp_fh;

    $self->{timeout_sec} = $recipe->{timeout_sec} || 1;

    my @command = split(/ /, $recipe->{execute});
    my $code_idx = first { $command[$_] eq "CODE" } (0 .. $#command);
    $command[$code_idx] = $temp_filename;
    $self->{command} = \@command;

    $self;
}

sub compile {
    # TODO
}

sub execute {
    my ($self, $input) = @_;

    my $command = $self->{command};
    my $timeout_sec = $self->{timeout_sec};
    my ($output, $error, $timeout) = ("", "", 0);
    my $harness = start $command, \$input, \$output, \$error, timeout($timeout_sec);
    my $rusage = getrusage_children;
    eval {
        finish $harness;
    };
    if ($@) {
        if ($@ =~ /timeout/) {
            $timeout = 1;
        }
        else {
            die $@;
        }
    }

    my $result = Code::AnyRunner::Result->new(
        output => $output,
        error  => $error,
        timeout => $timeout,
        rusage => $rusage
    );

    return $result;
}

1;
