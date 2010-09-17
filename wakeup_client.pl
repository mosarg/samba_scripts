#!/usr/bin/perl
use strict;
use warnings;
use Client::startstop qw(wakeup_client wakeup_clients);
use Getopt::Long;
use Switch;

my $clients = 'localhost';
my $all	   = '';
my $group ='';
GetOptions( 'client=s' => \$clients,'all'=>\$all,'group=s'=>\$group );

if ($all){
	wakeup_clients($group);
}else{
	switch($clients){
		case 'localhost'{print "Localhost already up!\n";}
		case /,/{
			foreach my $computer ( split( /,/, $clients ) ) {
				wakeup_client($computer);
			}
		}
		case /\|/{print "Use , as client separator\n";}
		else{
			wakeup_client($clients);
		}
	}
}

