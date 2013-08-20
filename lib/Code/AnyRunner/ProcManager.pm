package Code::AnyRunner::ProcManager;
use strict;
use warnings;

use IPC::Run;
use Parallel::ForkManager;

use Code::AnyRunner::Result;

sub new {
    my ($class, %args) = @_;
    bless {}, $class;
}

sub run {
    my ($self, $command, $input, $timeout_sec) = @_;

    my ($output, $error, $timeout, $rusage) = ("", "", 0, {});
    my $manager = Parallel::ForkManager->new(1);
    $manager->run_on_finish(
        sub {
            my $data = $_[5];
            $output = $data->{output};
            $error = $data->{error};
            $timeout = $data->{timeout};
            $rusage = $data->{rusage};
        }
    );

    my $pid = $manager->start;
    if ($pid) {
        $manager->wait_all_children;
    }
    else {
        my ($output, $error, $timeout) = ("", "", 0);

        unshift @$command, ("/usr/bin/time", "--verbose");
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
        $manager->finish(0, {
            output  => $output,
            error   => $error,
            timeout => $timeout,
            rusage  => $rusage,
        });
    }

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

    my @error = split "\n", $error;
    my $error_array_size = scalar(@error);

    my @rusage = @error[$#error - 22 .. $#error];
    splice @error, $#error - 22, 23 if $error_array_size >= 23;

    $error = join "\n", @error;

    my $rusage = {};
    foreach my $line (@rusage) {
        next unless defined $line;
        if ($line =~ /^\tUser time[ a-zA-Z\(\):]+([\.\d]+)$/) {
            $rusage->{ru_utime} = $1;
        } elsif ($line =~ /^\tSystem time[ a-zA-Z\(\):]+([\.\d]+)$/) {
            $rusage->{ru_stime} = $1;
        } elsif ($line =~ /^\tMaximum resident set size[ a-zA-Z\(\):]+([\.\d]+)$/) {
            $rusage->{ru_maxrss} = $1;
        }
    }

    ($rusage, $error);
}

1;
