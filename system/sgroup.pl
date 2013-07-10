#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Server::AdbGroup qw(getAllGroupsAdb);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist);

my $commands = "init add,remove,sync,list";

my $backend = '';
my $all     = 0;

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s' => \$backend,
	'all'       => \$all
);
$backend or die("You must specify a backend\n");

switch ( $ARGV[0] ) {
	case 'add' {

	}
	case 'remove' {
		
		removeGroup();
	}
	case 'sync' {

	}
	case 'list' {
		listGroup();
	}
	case 'init' {
		initGroups();
	}
	else { die("$ARGV[0] is not a command!\n"); }

}

#Remove a single group or all groups defined in database
sub removeGroup {
	switch ($backend) {
		case 'samba4' {
			if ($all) {
				my $groups = getAllGroupsAdb($backend);
				foreach my $group (@{$groups}){
					deleteS4Group($group->[0]);
				}
			}else{
				(scalar(@ARGV)>1)||die("You must specify a group");
				deleteS4Group($ARGV[1]);
			}
		}
	}

}

#list backend groups

sub listGroup{
	switch($backend){
		case 'samba4' {
			my $groups=getAllGroupsAdb($backend);
			my $color='green';
			my $message='[OK]';
			foreach my $group (@{$groups}){
				if (!doS4GroupExist($group->[0])){
					$color='red';
					$message='[Not synced]';
				}
				print $group->[0]," db ",colored("[OK] ",'green'),$backend,colored(" $message",$color),"\n";
				
			}
		}
	}
}


#Init groups according to database definition
sub initGroups {
	my $color='green';
	my $message='[OK]';
	#Get all backend groups from adb database;
	my $groups = getAllGroupsAdb($backend);
	switch ($backend) {
		case 'samba4' {
			foreach my $group ( @{$groups} ) {
				if (!addS4Group( $group->[0] )){
					$color='red';
					$message='[Error]';
				};
			print "Inserting group $group->[0] ",colored($message,$color),"\n";
				
			}
		}
		else { print "Backend not implemented\n"; exit 1; }
	}

}

