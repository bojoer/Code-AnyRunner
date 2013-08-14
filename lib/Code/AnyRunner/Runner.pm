package Code::AnyRunner::Runner;
use strict;
use warnings;

use IPC::Run qw/run start finish timeout/;
use Unix::Getrusage;

use Code::AnyRunner::Command;
use Code::AnyRunner::Result;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {}, $class;

    my $recipe = $opt{recipe};
    my ($temp_fh, $temp_code_filename) = File::Temp::tempfile(
        SUFFIX => $recipe->{code_suffix},
    );

    my $code = $opt{code};
    print $temp_fh $code;
    close $temp_fh;

    $self->{timeout_sec} = $recipe->{timeout_sec} || 1;

    my $command = Code::AnyRunner::Command->new(
        recipe => $recipe,
        temp_code_filename => $temp_code_filename
    );
    $self->{compile_command} = $command->{compile_command};
    $self->{execute_command} = $command->{execute_command};

    $self;
}

sub compile {
    my $self = shift;

    my $command = $self->{compile_command};
    if ($command) {
        my $timeout_sec = $self->{timeout_sec};
        my ($input, $output, $error, $timeout) = ("", "", "", 0);
        eval {
            run $command, \$input, \$output, \$error, timeout($timeout_sec);
        };
        if ($@) {
            if ($@ =~ /timeout/) {
                $timeout = 1;
            } else {
                die $@;
            }
        }

        my $result = Code::AnyRunner::Result->new(
            output => $output,
            error  => $error,
            timeout => $timeout
        );

        return $result;
    }
}

sub execute {
    my ($self, $input) = @_;

    my $command = $self->{execute_command};
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
