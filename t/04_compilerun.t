use strict;
use warnings;
use base qw/Test::Class/;
use Test::More;

use Code::AnyRunner;

__PACKAGE__->runtests;

sub setup : Test(setup) {
    my $self = shift;
    $self->{runner} = Code::AnyRunner->new;
    $self->{runner}->add_recipe(
        name => "c++",
        code_suffix => ".cpp",
        exec_suffix => ".o",
        compile => "g++ CODE -o EXEC",
        execute => "EXEC",
    );
}

sub test_no_input : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
#include <iostream>
int main(){
  int aaa = 100;
  int bbb = 200;
  std::cout << aaa + bbb;
}
CODE
    my $result = $runner->run_code("c++", $code);
    my $output = $result->{output};
    is $output, 300;
    ok !($result->is_error);
    ok !($result->is_timeout);
}
