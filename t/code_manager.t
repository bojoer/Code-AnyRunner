use strict;
use warnings;
use parent qw/Test::Class/;
use Test::Double;
use Test::More;

use Code::AnyRunner::CodeManager;

sub setup : Test(setup) {
    my $self = shift;
    my $need_compile_recipe = +{
        compile => "command CODE EXEC",
        code_suffix => "",
        execute => "EXEC",
        exec_suffix => "",
    };
    $self->{need_compile_manager} = Code::AnyRunner::CodeManager->new(
        code   => "some codes",
        recipe => $need_compile_recipe,
    );
    my $no_need_compile_recipe = +{
        execute => "command CODE",
        exec_suffix => "",
    };
    $self->{no_need_compile_manager} = Code::AnyRunner::CodeManager->new(
        code   => "some codes",
        recipe => $no_need_compile_recipe,
    );
}

sub test_compile : Tests {
    my $self = shift;
    my $need_compile_manager = $self->{need_compile_manager};
    my $no_need_compile_manager = $self->{no_need_compile_manager};

    my $runner = $need_compile_manager->{runner};
    stub($runner)->run("COMPILED");

    is($need_compile_manager->compile, "COMPILED");

    $runner = $no_need_compile_manager->{runner};
    stub($runner)->run("COMPILED");

    is($no_need_compile_manager->compile, undef);
}

sub test_execute : Tests {
    my $self = shift;
    my $need_compile_manager = $self->{need_compile_manager};
    my $no_need_compile_manager = $self->{no_need_compile_manager};

    my $runner = $need_compile_manager->{runner};
    stub($runner)->run("EXECUTED");

    is($need_compile_manager->execute, "EXECUTED");

    $runner = $no_need_compile_manager->{runner};
    stub($runner)->run("EXECUTED");

    is($no_need_compile_manager->execute, "EXECUTED");
}

__PACKAGE__->runtests;
