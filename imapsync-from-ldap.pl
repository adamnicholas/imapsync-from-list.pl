#!/opt/csw/bin/perl
#
# imapsync-from-ldap.pl
#
# By default this script forks 40 processes and synchronizes
# accounts to Google that have NOT already been migrated
# and uses the DELETE version of the imapsync_wrapper script.

# This script should be modified to support flags for --nodelete
# and an option to do migrated users, not migrated users, or all

use strict;
use POSIX qw( WNOHANG );
use warnings;

use Net::LDAP;
use Parallel::ForkManager;

# connect to ldap as DM
my $ldap = Net::LDAP->new( 'ldap://ldap.example.com:389') or die $@;

$ldap->bind(
        dn => "dn of privileged user",
        password => "pasword"
);

# search for anyone who has a g.example.com mailForwardingAddress attribute

my $result = $ldap->search(
    base   => "dc=example,dc=com",
    filter => "(&(objectClass=mailRecipient)(!(&(mailDeliveryOption=forward)(mailForwardingAddress=*\@g.example.com))))",
    attrs => ['uid'],
    scope => "subtree"
);

die $result->error if $result->code;

# Clean up those connections and handles

$ldap->unbind;
$ldap->disconnect;

# for debug
printf "Results: %s\n", $result->count;

# for debug
#foreach my $entry ($result->entries) {
#       $entry->dump;
#}


my $MAX_PROCESSES = 40;
printf "Max Procs: %s\n", $MAX_PROCESSES;

my $pm = Parallel::ForkManager->new($MAX_PROCESSES);

my $count = 0;

foreach my $entry ($result->entries) {

        $count++;

        # Fork a process to sync this netid
        my $pid = $pm->start and next;

        # Queue up a NetID from the results
        my $uid = $entry->get_value("uid");

        printf ("Now syncing %s...\n", $uid);

        system ("imapsync_wrapper.sh $uid FINAL > /dev/null 2>&1");

        $pm->finish;
}

printf "%s: Waiting for child processes to finish.\n", scalar localtime;
$pm->wait_all_children;
printf "%s: All processes finished.\n", scalar localtime;
