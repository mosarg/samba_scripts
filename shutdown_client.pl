#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Client::startstop qw(turnoff_client);
use Switch;

my $clients = 'localhost';
my $all     = '';

GetOptions(
	'clients=s' => \$clients,
	'all'       => \$all
);

if ($all){
	turnoff_clients();
}else{
	switch($clients){
		case 'localhost'{print "Localhost cannot be shut down!\n";}
		case /,/{
			foreach my $computer ( split( /,/, $clients ) ) {
				turnoff_client($computer);
			}
		}
		case /\|/{print "Use , as client separator\n";}
		default{
			turnoff_client($clients);
		}
	}
}

