use strict;
use warnings;
use base qw/Test::Class/;
use Test::More;

use Code::AnyRunner::Result;

__PACKAGE__->runtests;

sub test_error : Tests {
    my $error = "error";
    my $result = Code::AnyRunner::Result->new(
        error => $error,
    );

    ok($result->is_error, "some error");
}

sub test_no_error : Tests {
    my $error = "";
    my $result = Code::AnyRunner::Result->new(
        error => $error,
    );

    ok(!$result->is_error, "no error");
}

sub test_timeout : Tests {
    my $timeout = 1;
    my $result = Code::AnyRunner::Result->new(
        timeout => $timeout,
    );

    ok($result->is_timeout, "timed out");
}

sub test_rusage : Tests {
    my $elapsed_time = rand(1000);
    my $maxrss = rand(1000);
    my $rusage = {
        elapsed_time => $elapsed_time,
        maxrss => $maxrss,
    };
    my $result = Code::AnyRunner::Result->new(
        rusage => $rusage,
    );

    is($result->elapsed_time, $elapsed_time, "elapsed time");
    is($result->maxrss, $maxrss, "max rss");
}
