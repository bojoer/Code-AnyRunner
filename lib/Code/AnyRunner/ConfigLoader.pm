package Code::AnyRunner::ConfigLoader;
use strict;
use warnings;

use Config::Tiny;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub load {
    my ($self, $config_path) = @_;
    my $config = Config::Tiny->new->read($config_path);
    return $config;
}

1;
