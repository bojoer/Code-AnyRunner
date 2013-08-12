use strict;
use warnings;
use base qw/Test::Class/;
use Test::More;

use Code::AnyRunner;

__PACKAGE__->runtests;

sub setup : Test(setup) {
    my $self = shift;
    $self->{runner} = Code::AnyRunner->new;
    $self->{runner}->add_setting(
        name => "perl",
        code_suffix => ".pl",
        exec_suffix => "",
        compile => "",
        execute => "perl CODE",
    );
}

sub test_no_input : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
use strict;
use warnings;

my \$aaa = 100;
my \$bbb = 200;
my \$ccc = \$aaa + \$bbb;

print \$ccc;
CODE
    my $result = $runner->run_code("perl", $code);
    my $output = $result->{output};
    my $timeout = $result->{timeout};
    is $output, 300;
    ok !($result->is_error);
    ok !$timeout;
}

sub test_input : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
use strict;
use warnings;

my \$sum = 0;
while (defined(my \$line = <STDIN>)) {
    chomp(\$line);
    \$sum += \$line;
}

print \$sum;
CODE
    my $input = <<INPUT;
100
200
INPUT
    my $result = $runner->run_code("perl", $code, $input);
    my $output = $result->{output};
    my $timeout = $result->{timeout};
    is $output, 300;
    ok !($result->is_error);
    ok !$timeout;
}

sub test_cause_error : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
use
CODE
    my $result = $runner->run_code("perl", $code);
    my $output = $result->{output};
    my $error = $result->{error};
    my $timeout = $result->{timeout};
    ok !$output;
    like $error, qr/syntax error/;
    ok !$timeout;
}

sub test_cause_timeout : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
sleep(5);
CODE
    my $result = $runner->run_code("perl", $code);
    my $output = $result->{output};
    my $timeout = $result->{timeout};
    ok !$output;
    ok !($result->is_error);
    is $timeout, 1;
}
