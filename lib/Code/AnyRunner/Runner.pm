package Code::AnyRunner::Runner;
use strict;
use warnings;

use Code::AnyRunner::Command;
use Code::AnyRunner::ProcManager;

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
    $self->{proc_manager} = Code::AnyRunner::ProcManager->new;

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
        my $proc_manager = $self->{proc_manager};
        my $timeout_sec = $self->{timeout_sec};
        my $result = $proc_manager->run($command, "", $timeout_sec);
        return $result;
    }
}

sub execute {
    my ($self, $input) = @_;

    my $command = $self->{execute_command};
    my $proc_manager = $self->{proc_manager};
    my $timeout_sec = $self->{timeout_sec};
    my $result = $proc_manager->run($command, $input, $timeout_sec);
    return $result;
}

1;
