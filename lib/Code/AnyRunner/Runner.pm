package Code::AnyRunner::Runner;
use strict;
use warnings;

use IPC::Run qw/run timeout/;
use File::Temp;
use List::Util qw/first/;

use Code::AnyRunner::Result;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {
        timeout_sec => 1
    }, $class;

    my $setting = $opt{setting};
    my ($temp_fh, $temp_filename) = File::Temp::tempfile(
        SUFFIX => $setting->{code_suffix},
    );

    my $code = $opt{code};
    print $temp_fh $code;
    close $temp_fh;

    my @command = split(/ /, $setting->{execute});
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
    eval {
        run $command, \$input, \$output, \$error, timeout($timeout_sec);
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
        timeout => $timeout
    );

    return $result;
}

1;
