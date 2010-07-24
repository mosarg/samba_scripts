#!/usr/bin/perl

use strict;
use warnings;
use Client::update qw(do_client_update);
my $client = 'localhost';

GetOptions( 'client=s' => \$client );

if ($client ne "localhost"){

do_client_update($client,10);
}else{
	print "Usage update_client.pl --client <client-name>\n";
}



