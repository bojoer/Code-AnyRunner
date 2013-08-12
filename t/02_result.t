use strict;
use warnings;
use base qw/Test::Class/;
use Test::More;

use Unix::Getrusage;

use Code::AnyRunner;

__PACKAGE__->runtests;

sub test_rusage : Tests {
    my $self = shift;
    my $rusage = getrusage;
    my $result = Code::AnyRunner::Result->new(
        rusage => $rusage
    );

    ok $result->utime >= 0;
    ok $result->stime >= 0;
    ok $result->maxrss >= 0;
}
