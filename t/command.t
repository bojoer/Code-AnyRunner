use strict;
use warnings;
use parent qw/Test::Class/;
use Test::More;

use Code::AnyRunner::Command;

sub no_need_compile : Tests {
    my $recipe = {
        execute => "execute CODE",
        exec_suffix => ".code"
    };
    my $code_filename = "/path/to/code.code";

    my $command = Code::AnyRunner::Command->new(
        recipe => $recipe,
        temp_code_filename => $code_filename,
    );

    my $expected_execute_command =
      ["execute", "/path/to/code.code"];

    is_deeply($command->{execute_command}, $expected_execute_command, "execute command");
}

sub need_compile : Tests {
    my $recipe = {
        compile => "compile CODE -o EXEC",
        execute => "execute EXEC",
        code_suffix => ".test",
        exec_suffix => ".exe"
    };
    my $code_filename = "/path/to/code.test";

    my $command = Code::AnyRunner::Command->new(
        recipe => $recipe,
        temp_code_filename => $code_filename,
    );

    my $expected_compile_command =
      ["compile", "/path/to/code.test", "-o", "/path/to/code.exe"];

    my $expected_execute_command =
      ["execute", "/path/to/code.exe"];

    is_deeply($command->{compile_command}, $expected_compile_command, "compile command");
    is_deeply($command->{execute_command}, $expected_execute_command, "execute command");
}

__PACKAGE__->runtests;
