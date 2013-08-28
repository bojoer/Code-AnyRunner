use strict;
use warnings;
use parent qw/Test::Class/;
use Test::Double;
use Test::MockObject;
use Test::More;

use Code::AnyRunner;

sub test_add_recipe : Tests {
    my $runner = Code::AnyRunner->new;
    $runner->add_recipe(
        name => "recipe_name",
        key  => "value",
    );

    my $expected_recipes = +{
        recipe_name => +{
            key => "value",
        },
    };
    my $actual_recipes = $runner->{recipes};
    is_deeply($actual_recipes, $expected_recipes);
}

sub test_load_recipes : Tests {
    my $runner = Code::AnyRunner->new;
    my $config = +{
        _ => {
            baz => "zzz",
        },
        foo => {
            bar => "hoge",
        },
    };
    $runner->load_recipes($config);

    my $expected_recipes = +{
        foo => +{
            baz => "zzz",
            bar => "hoge",
        },
    };
    my $actual_recipes = $runner->{recipes};
    is_deeply($actual_recipes, $expected_recipes);
}

sub test_run_code : Tests {
    my $runner = Code::AnyRunner->new;

    my $mock_object = Test::MockObject->new;
    $mock_object->mock("compile");
    $mock_object->mock("execute", sub { Code::AnyRunner::Result->new });

    stub($runner)->_create_manager($mock_object);
    isa_ok($runner->run_code, "Code::AnyRunner::Result");
}

__PACKAGE__->runtests;
