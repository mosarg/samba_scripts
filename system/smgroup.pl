#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Term::Emit ":all", {-color => 1};
use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist);
use Server::AdbPolicy qw(getAllPoliciesAdb setPolicyGroupAdb);
use Server::System qw(initGroups init);


my $commands = "init add,remove,sync,list";

my $backend = 'samba4';
my $all     = 0;
my $description='generic description';
my $data={};

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s' => \$backend,
	'all'       => \$all,
	'description=s'=>\$description
);


$backend or die("You must specify a backend\n");

$data->{backend}=$backend;

init($data);

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
					emit "Remove group $group->[0]";
						if(deleteS4Group($group->[0])){emit_ok}else{emit_fatal;}
					
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
			
				emit "Samba4 group $group->[0]";
				if (!doS4GroupExist($group->[0])){
					emit_error;}else{
						emit_ok;
					}
				
			}
		}
	}
}





