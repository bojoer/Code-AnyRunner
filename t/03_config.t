use strict;
use warnings;
use base qw/Test::Class/;
use Test::More;

use File::Basename;

use Code::AnyRunner;

__PACKAGE__->runtests;

sub test_load : Tests{
    my $self = shift;
    my $config_path = $self->fixture_path("config.ini");
    my $runner = Code::AnyRunner->new(
        config_path => $config_path,
    );

    my $expected = {
        foo => {
            bar => "hoge"
        }
    };

    is_deeply $expected, $runner->{recipes};
}

sub fixture_path {
    my ($self, $file_path) = @_;
    File::Spec->catfile(dirname(__FILE__), "fixtures", $file_path);
}
