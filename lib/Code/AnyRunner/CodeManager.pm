package Code::AnyRunner::CodeManager;
use strict;
use warnings;

use File::Path;
use File::Spec;
use File::Temp;

use Code::AnyRunner::Command;
use Code::AnyRunner::Runner;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {}, $class;

    my $recipe = $opt{recipe};
    my $tempdir = File::Temp::tempdir( CLEANUP => 0 );
    die "Temporary directory $tempdir doesn't exist" unless (-e $tempdir);
    die "Temporary directory $tempdir is not a directory" unless (-d $tempdir);
    $self->{tempdir} = $tempdir;

    my $recipe_name = $recipe->{name} || "";
    my $code_suffix = $self->{code_suffix} || "";
    my $temp_code_filename = File::Spec->catfile(
        $self->{tempdir},
        $recipe_name.$$.$code_suffix
    );

    open my $temp_fh, ">", $temp_code_filename or die "Can't open $temp_code_filename";
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

sub DESTROY {
    my $self = shift;
    if ($self->{tempdir}) {
        File::Path::remove_tree($self->{tempdir});
    }
}

1;
