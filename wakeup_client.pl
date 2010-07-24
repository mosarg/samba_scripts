#!/usr/bin/perl
use strict;
use warnings;
use Client::startstop qw(wakeup_client);
use Getopt::Long;
use Switch;

my $clients = 'localhost';
my $all	   = '';
GetOptions( 'client=s' => \$clients,'all'=>\$all );

if ($all){
	turnoff_clients();
}else{
	switch($clients){
		case 'localhost'{print "Localhost already up!\n";}
		case /,/{
			foreach my $computer ( split( /,/, $clients ) ) {
				wakeup_client($computer);
			}
		}
		case /\|/{print "Use , as client separator\n";}
		default{
			wakeup_client($clients);
		}
	}
}

