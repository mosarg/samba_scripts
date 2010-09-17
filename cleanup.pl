#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Server::Actions qw(cleanupDir cleanupDustbins);
use Switch;

my $item='none';

GetOptions( 'item=s' => \$item);


switch ($item){
	
	case "dustbins" { cleanupDustbins;}
	else {print "Item $item not defined\n";}
}

