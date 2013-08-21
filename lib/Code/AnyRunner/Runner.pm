package Code::AnyRunner::Runner;
use strict;
use warnings;

use File::Basename;
use File::Spec;
use IPC::Run;

use Code::AnyRunner::Result;

sub new {
    my ($class, %args) = @_;
    bless {}, $class;
}

sub run {
    my ($self, $command, $input, $timeout_sec) = @_;

    my ($output, $error, $timeout, $rusage) = ("", "", 0, {});

        my $time_command = File::Spec->catfile(dirname(File::Spec->rel2abs(__FILE__)), "time.pl");
        unshift @$command, $time_command;

        eval {
            IPC::Run::run($command, \$input, \$output, \$error,
                          IPC::Run::timeout($timeout_sec));
        };
        if ($@) {
            if ($@ =~ /timeout/) {
                $timeout = 1;
            } else {
                die $@;
            }
        }

        ($rusage, $error) = $self->_split_rusage($error);

    my $result = Code::AnyRunner::Result->new(
        output  => $output,
        error   => $error,
        timeout => $timeout,
        rusage  => $rusage,
    );
    $result;
}

sub _split_rusage {
    my ($self, $error) = @_;

    my $rusage = {};
    my @error = split "\n", $error;
    if ($#error >= 0) {
        my $rusage_line = splice @error, $#error;
        if ($rusage_line =~ /([\.\d]+) ([\.\d]+)/) {
            $rusage->{ru_maxrss} = $2;
        }
    }
    $error = join "\n", @error;

    ($rusage, $error);
}

1;
