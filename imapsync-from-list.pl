#!/opt/csw/bin/perl
#
# google-sync-fromlist.pl
#
#
# By default this script forks $MAX_PROCCESSES processes and synchronizes.

# This script accepts a text file as input, formatted with one
# user ID per line

# This script should be modified to support flags for --nodelete
# and an option to do migrated users, not migrated users, or all

use strict;
use POSIX qw( WNOHANG );
use warnings;
use Parallel::ForkManager;

my $filename = $ARGV[0] or die "missing arguments: filename, syncdir ";
my $syncdir = $ARGV[1] or die "missing argument: syncdir";
my $info;

open $info, $filename or die $!;

# default processes below is 10 - can increase within reason..
my $MAX_PROCESSES = 10;

printf "Max Procs: %s\n", $MAX_PROCESSES;

my $pm = Parallel::ForkManager->new($MAX_PROCESSES);

while ( my $uid = <$info>) {

        # Fork a process to sync this netid
        my $pid = $pm->start and next;

        # Queue up a NetID from the results

        chomp($uid);
        printf ("Now syncing %s...\n", $uid);
        printf ("syncdir: %s\n", $syncdir);

        system ("imapsync_wrapper.sh $uid $syncdir > /dev/null 2>&1");

        $pm->finish;
}

close $info;

printf "%s: Waiting for child processes to finish.\n", scalar localtime;
$pm->wait_all_children;
printf "%s: All processes finished.\n", scalar localtime;
