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

1;
