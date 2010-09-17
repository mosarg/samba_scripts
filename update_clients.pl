#!/usr/bin/perl

use strict;
use warnings;
use threads;
use Client::startstop qw(wakeup_clients checkclients_up turnoff_clients);
use Client::update qw(do_client_update);
use Client::Info qw(get_clients_info);
use Getopt::Long;
use Client::update qw(do_client_update);

my $group = '';

GetOptions( 'group=s' => \$group);

#wake up all clients

wakeup_clients($group);

print "I'm waiting 120 seconds for hosts to come up\n";

sleep 120;

#check all host are up
checkclients_up($group);

my @threads_array = ();

#spawn an update thread per client
foreach my $computer ( @{ get_clients_info($group) } ) {
	push( @threads_array,
		threads->create( \&do_client_update, $computer->[1], 10 ) );
}

#join all threads
foreach ( threads->list() ) {
	print $_->join() . "\n";
}

#turn off all computers
turnoff_clients($group);

