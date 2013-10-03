#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Data::Dumper;
use Server::Actions qw(notifyDiskSpace);
use Switch;
use Getopt::Long;


my $action='disk_space';


GetOptions( 'action=s' => \$action);


if ($action){
	switch ($action){
	
	case "disk_space" {notifyDiskSpace();}
	else {print "Action $action not defined\n";}
}
}else{
	print "I need at least an action\n";
}