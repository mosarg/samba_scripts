#!/usr/bin/perl
use strict;
use warnings;
use Client::startstop qw(wakeup_client);
use Getopt::Long;

my $client = 'localhost';

GetOptions( 'client=s' => \$client );

if ( $client ne 'localhost' ) {
	wakeup_client($client);
}
else {
	print "Localhost is already up\n";
}

