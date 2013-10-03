#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Client::startstop qw(turnoff_clients turnoff_client);
use Switch;
use threads;


my $clients = 'localhost';
my $group = '';
my $all     = '';


GetOptions(
	'clients=s' => \$clients,
	'all'       => \$all,
	'group=s'   => \$group
);



if ($all){
	
	turnoff_clients($group);
	
}else{
	switch($clients){
		case 'localhost'{print "Localhost cannot be shut down!\n";}
		case /,/{
			foreach my $computer ( split( /,/, $clients ) ) {
				turnoff_client($computer);
			}
		}
		case /\|/{print "Use , as client separator\n";}
		
		else{
			turnoff_client($clients);
		}
	}
}

