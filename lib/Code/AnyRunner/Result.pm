package Code::AnyRunner::Result;
use strict;
use warnings;

sub new {
    my ($class, %opt) = @_;
    bless {
        output  => $opt{output},
        error   => $opt{error},
        timeout => $opt{timeout},
        rusage  => $opt{rusage}
    }, $class;
}

sub is_error {
    shift->{error} ne "";
}

sub is_timeout {
    shift->{timeout} == 1;
}

sub utime {
    shift->{rusage}->{ru_utime};
}

sub stime {
    shift->{rusage}->{ru_stime};
}

sub maxrss {
    shift->{rusage}->{ru_maxrss};
}

1;
