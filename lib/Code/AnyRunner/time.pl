#!/usr/bin/env perl
use strict;
use warnings;

use Time::HiRes qw( gettimeofday tv_interval );
use Proc::Wait3;

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

# resuse_end

my ($pid, $status, $utime, $stime, $maxrss, $ixrss, $idrss, $isrss,
    $minflt, $majflt, $nswap, $inblock, $oublock, $msgsnd, $msgrcv,
    $nsignals, $nvcsw, $nivcsw);
while(1) {
    ($pid, $status, $utime, $stime, $maxrss, $ixrss, $idrss, $isrss,
     $minflt, $majflt, $nswap, $inblock, $oublock, $msgsnd, $msgrcv,
     $nsignals, $nvcsw, $nivcsw) = wait3(1);
    last unless defined $pid;   # there are no dead children
    last if $pid == $child_pid;
}

my $elapsed = tv_interval($start_time, [gettimeofday]);

$SIG{INT} = $signal_int;
$SIG{QUIT} = $signal_quit;

print STDERR "$utime $stime $elapsed $maxrss\n";
