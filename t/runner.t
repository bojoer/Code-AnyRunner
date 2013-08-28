use strict;
use warnings;
use parent qw( Test::Class );
use Test::MockModule;
use Test::More;

use Code::AnyRunner::Runner;

sub test_return_result : Tests {
    my $mock_module = new Test::MockModule("IPC::Run");
    $mock_module->mock("run", sub { "DUMMY" });

    my ($command, $input, $timeout_sec);
    my $runner = Code::AnyRunner::Runner->new;
    my $result = $runner->run($command, $input, $timeout_sec);

    isa_ok($result, "Code::AnyRunner::Result", "Return Code::AnyRunner::Result");
}

sub test_timeout : Tests {
    my $mock_module = new Test::MockModule("IPC::Run");
    $mock_module->mock("run", sub {
        die "timeout";
    });

    my ($command, $input, $timeout_sec);
    my $runner = Code::AnyRunner::Runner->new;
    my $result = $runner->run($command, $input, $timeout_sec);

    is($result->{timeout}, 1, "Set timeout flag");
}

sub test_eval_error : Tests {
    my $mock_module = new Test::MockModule("IPC::Run");
    $mock_module->mock("run", sub {
        die "eval error";
    });

    my ($command, $input, $timeout_sec);
    my $runner = Code::AnyRunner::Runner->new;

    my $result;
    eval {
        $result = $runner->run($command, $input, $timeout_sec);
    };

    ok(!(defined $result), "Result is undefined");
    like($@, qr/eval error/, "Cause eval error");
}

sub test_split_usage : Tests {
    my $error = <<ERROR;
some error
12.34 56.78
ERROR

    my $runner = Code::AnyRunner::Runner->new;
    my ($actual_rusage, $actual_error) = $runner->_split_rusage($error);

    my $expected_rusage = +{
        elapsed_time => 12.34,
        maxrss => 56.78,
    };
    is_deeply($actual_rusage, $expected_rusage, "Split rusage");
    is($actual_error, "some error", "Split error");
}

__PACKAGE__->runtests;
