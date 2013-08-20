#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Server::Configuration qw($ldap);
use Server::Commands qw(hashNav);
use Server::System qw(listOu createOu checkOu);




my $commands = "init,sync,list";

my $backend     = 'samba4';
my $all         = 0;
my $description = 'generic description';

my $data={};

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s'     => \$backend,
	'all'           => \$all,
	'description=s' => \$description
);
$backend or die("You must specify a backend\n");

switch ( $ARGV[0] ) {
	case 'sync' {
		listOu($backend, \&createOu );
	}
	case 'list' {
		listOu($backend, \&checkOu );
	}
	case 'init' {
		listOu($backend, \&createOu );
	}
	else { die("$ARGV[0] is not a command!\n"); }
}

