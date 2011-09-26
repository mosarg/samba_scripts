#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Server::Actions qw(cleanupDir cleanupDustbins cleanupOldProfiles);
use Switch;

my $item='none';

GetOptions( 'item=s' => \$item);


switch ($item){
	
	case "dustbins" { cleanupDustbins;}
	case "profiles" { cleanupOldProfiles;}
	else {print "Item $item not defined\n";}
}

