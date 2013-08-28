package Code::AnyRunner::CodeManager;
use strict;
use warnings;

use File::Temp;

use Code::AnyRunner::Command;
use Code::AnyRunner::Runner;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {}, $class;

    my $recipe = $opt{recipe};
    my ($temp_fh, $temp_code_filename) = File::Temp::tempfile(
        SUFFIX => $recipe->{code_suffix},
    );

    my $code = $opt{code};
    print $temp_fh $code;
    close $temp_fh;

    $self->{timeout_sec} = $recipe->{timeout_sec} || 1;
    $self->{runner} = Code::AnyRunner::Runner->new;

    my $command = Code::AnyRunner::Command->new(
        recipe => $recipe,
        temp_code_filename => $temp_code_filename
    );
    $self->{compile_command} = $command->{compile_command};
    $self->{execute_command} = $command->{execute_command};

    $self;
}

sub compile {
    my $self = shift;

    my $command = $self->{compile_command};
    if ($command) {
        my $runner = $self->{runner};
        my $timeout_sec = $self->{timeout_sec};
        my $result = $runner->run($command, "", $timeout_sec);
        return $result;
    }
}

sub execute {
    my ($self, $input) = @_;

    my $command = $self->{execute_command};
    my $runner = $self->{runner};
    my $timeout_sec = $self->{timeout_sec};
    my $result = $runner->run($command, $input, $timeout_sec);
    return $result;
}

1;
