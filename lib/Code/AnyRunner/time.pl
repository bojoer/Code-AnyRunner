#!/usr/bin/env perl
use strict;
use warnings;

use Time::HiRes qw( gettimeofday tv_interval );
use Linux::Smaps;
use POSIX qw( WNOHANG );

if (@ARGV == 0) {
    print "Usage: ".__FILE__." command [arg...]\n";
    exit 0;
}

my $start_time = [gettimeofday];

my $child_pid = fork;
if ($child_pid < 0) {
    die "cannot fork";
}
elsif ($child_pid == 0) {
    exec @ARGV;
    die "cannot run";
}

(my $signal_int, $SIG{INT}) = ($SIG{INT}, "IGNORE");
(my $signal_quit, $SIG{QUIT}) = ($SIG{QUIT}, "IGNORE");

my $smaps = Linux::Smaps->new($child_pid);
my $maxuss = uss($smaps);

# this infinite loop cannot get a correct maximum uss ...
# so this maximum uss change by execute timing ...
while (1) {
    my $uss = uss($smaps);
    $maxuss = $uss if $maxuss < $uss;

    my $caught = waitpid(-1, WNOHANG);
    last if $caught == $child_pid;

    last unless defined $smaps->update;
}

my $elapsed = tv_interval($start_time, [gettimeofday]);

$SIG{INT} = $signal_int;
$SIG{QUIT} = $signal_quit;

print STDERR "$elapsed $maxuss\n";

sub uss {
    my $smaps = shift;
    $smaps->private_dirty + $smaps->private_clean;
}
