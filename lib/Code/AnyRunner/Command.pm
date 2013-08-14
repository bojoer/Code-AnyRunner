package Code::AnyRunner::Command;
use strict;
use warnings;

use File::Basename;
use File::Temp;
use List::Util qw/first/;

sub new {
    my ($class, %opt) = @_;
    my $self = bless {}, $class;

    $self->{recipe} = $opt{recipe};
    $self->{temp_code_filename} = $opt{temp_code_filename};
    my $temp_exec_filename = $self->_create_exec_filename;

    $self->{compile_command} = $self->_create_compile_command(
        $temp_exec_filename
    );
    $self->{execute_command} = $self->_create_execute_command(
        $temp_exec_filename
    );

    $self;
}

sub _create_exec_filename {
    my ($self) = @_;
    my $recipe = $self->{recipe};
    my $code_filename = $self->{temp_code_filename};
    my $exec_filename = $code_filename;
    if ($recipe->{compile}) {
        $exec_filename = $self->_change_file_ext($code_filename,
                                                 $recipe->{code_suffix},
                                                 $recipe->{exec_suffix});
    }
    $exec_filename;
}

sub _create_compile_command {
    my ($self, $exec_filename) = @_;
    my $recipe = $self->{recipe};
    my $code_filename = $self->{temp_code_filename};
    if ($recipe->{compile}) {
        my @command = split(/ /, $recipe->{compile});
        @command = $self->_change_word(\@command, "CODE", $code_filename);
        @command = $self->_change_word(\@command, "EXEC", $exec_filename);
        \@command;
     } else {
         undef;
     }
}

sub _create_execute_command {
    my ($self, $filename) = @_;
    my $recipe = $self->{recipe};
    my @command = split(/ /, $recipe->{execute});
    if ($recipe->{compile}) {
        @command = $self->_change_word(\@command, "EXEC", $filename);
    } else {
        @command = $self->_change_word(\@command, "CODE", $filename);
    }
    \@command;
}

sub _change_file_ext {
    my ($self, $filepath, $from_ext, $to_ext) = @_;

    my $dirname = dirname($filepath);
    my $filename = basename($filepath, $from_ext).$to_ext;
    File::Spec->catfile($dirname, $filename);
}

sub _change_word {
    my ($self, $list, $from_word, $to_word) = @_;
    my @list_copy = @$list;

    my $idx = first { $list_copy[$_] eq $from_word } (0 .. $#list_copy);
    $list_copy[$idx] = $to_word;
    @list_copy;
}

1;
