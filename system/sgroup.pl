#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist);
use Server::AdbPolicy qw(getAllPoliciesAdb setPolicyGroupAdb);


my $commands = "init add,remove,sync,list";

my $backend = '';
my $all     = 0;
my $description='generic description';

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s' => \$backend,
	'all'       => \$all,
	'description=s'=>\$description
);
$backend or die("You must specify a backend\n");

switch ( $ARGV[0] ) {
	case 'add' {
		  addGroup();
	}
	case 'remove' {
		
		removeGroup();
	}
	case 'sync' {
		initGroups();
	}
	case 'list' {
		listGroup();
	}
	case 'init' {
		initGroups();
	}
	else { die("$ARGV[0] is not a command!\n"); }

}


sub addGroup{
		switch($backend){
			case 'samba4' {
			
			(	scalar(@ARGV)>1)||die("You must specify a group name\n");
			if((scalar(@ARGV)>1) && (scalar(@ARGV)<=2)){  
				print "possibile policies:\n";
				foreach my $policy (@{getAllPoliciesAdb($backend)}){
					print $policy->{policyId}," ",$policy->{description},"\n";
				}
				die("You must select a policy\n");
			}
				my $groupId=addGroupAdb($ARGV[1],$description);		
				setPolicyGroupAdb($groupId,$ARGV[2]);
				addS4Group( $ARGV[1]);
			}
		}
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
				}else{
					$color='green';
					$message='[OK]';
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

