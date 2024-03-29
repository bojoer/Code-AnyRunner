use strict;
use warnings;
use parent qw( Test::Class );
use Test::More;

use File::Basename qw( dirname );
use File::Spec;

use Code::AnyRunner::ConfigLoader;

sub test_load : Tests{
    my $self = shift;
    my $config_path = $self->fixture_path("config.ini");

    my $loader = Code::AnyRunner::ConfigLoader->new;
    my $actual_config = $loader->load($config_path);

    my $expected = {
        _ => {
            baz => "zzz"
        },
        foo => {
            bar => "hoge"
        }
    };

    is_deeply $expected, $actual_config;
}

sub fixture_path {
    my ($self, $file_path) = @_;
    File::Spec->catfile(dirname(__FILE__), "fixtures", $file_path);
}

__PACKAGE__->runtests;
