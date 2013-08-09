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
    my ($output, $error, $timeout) = $runner->run_code($code);
    is $output, 300;
    ok !$error;
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
    my ($output, $error, $timeout) = $runner->run_code($code, $input);
    is $output, 300;
    ok !$error;
    ok !$timeout;
}

sub test_cause_error : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
use
CODE
    my ($output, $error, $timeout) = $runner->run_code($code);
    ok !$output;
    like $error, qr/syntax error/;
    ok !$timeout;
}

sub test_cause_timeout : Tests {
    my $runner = shift->{runner};
    my $code = <<CODE;
sleep(5);
CODE
    my ($output, $error, $timeout) = $runner->run_code($code);
    ok !$output;
    ok !$error;
    is $timeout, 1;
}
