#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Term::Emit ":all", { -color => 1 };
use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist);
use Server::AdbPolicy qw(getAllPoliciesAdb setPolicyGroupAdb);
use Server::System qw(initGroups);
use Server::Moodle qw(doMoodleGroupExist addMoodleGroup);
use Server::Configuration qw($schema);
use feature "switch";

my $commands = "init add,remove,sync,list";

my $backend     = 'samba4';
my $all         = 0;
my $description = 'generic description';
my $data        = {};

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s'     => \$backend,
	'all'           => \$all,
	'description=s' => \$description
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
		initGroups($backend);
	}
	case 'list' {
		listGroup();
	}
	case 'init' {
		initGroups($backend);
	}
	else { die("$ARGV[0] is not a command!\n"); }
}

sub addGroup {
	
	my $groupName  = $ARGV[1];
	my $policyName = $ARGV[2];

	( scalar(@ARGV) > 1 ) || die("You must specify a group name\n");
			if ( ( scalar(@ARGV) > 1 ) && ( scalar(@ARGV) <= 2 ) ) {
				print "possibile policies:\n";
				foreach my $policy ( @{ getAllPoliciesAdb($backend) } ) {
					print "Name: ".colored($policy->name,'green'). " Description: ", $policy->description, "\n";
				}
				die("You must select a policy\n");
			}
			emit "Inserting group " . $groupName;
			my $group = addGroupAdb( $groupName, $description );
			
			if($group==2){
				$group=$schema->resultset('GroupGroup')->search({name=>$groupName})->next;
			}
			
			my $adbBackend=$schema->resultset('BackendBackend')->search({kind=>$backend})->next;
			my $policy =$schema->resultset('AccountPolicy')->search({name=>$policyName,backendId_id=>$adbBackend->backend_id});
			if($policy->count==0){
				emit_error;
				return 0;
			}
			
			
			my $policyResult=setPolicyGroupAdb( $group, $policy->next);
			for($policyResult){
				when(/0/){emit_error; return 0;}
			}

	for ($backend) {
		when (/samba4/) {
			
			my $result = addS4Group( $groupName );
			for ($result) {
				when (/1/) { emit_ok; }
				when (/0/) { emit_error; }
				when (/2/) { emit_done "PRESENT" }
			}
		}
		when (/moodle/){
			my $result=addMoodleGroup($groupName);
				for ($result){
					when (/0/){emit_error;}
					when(/2/){emit_done "PRESENT";}
					when(/1/){emit_ok;}
				}
		
		}
		default {print "$backend not implemented\n";}
	}
}

#Remove a single group or all groups defined in database

sub removeGroup {
	for ($backend) {
		when (/samba4/) {
			if ($all) {
				my $groups = getAllGroupsAdb($backend);

				while ( my $group = $groups->next ) {
					emit "Remove group " . $group->name;
					my $result = deleteS4Group( $group->name );
					for ($result) {
						when (/0/) { emit_error; }
						when (/1/) { emit_ok; }
						when (/3/) { emit_done 'NOT EMPTY'; }
						when (/4/) { emit_done 'NOT PRESENT'; }
					}

				}

			}
			else {
				( scalar(@ARGV) > 1 ) || die("You must specify a group");
				emit "Remove group $ARGV[1]";
				my $result = deleteS4Group( $ARGV[1] );
				for ($result) {
					when (/0/) { emit_error; }
					when (/1/) { emit_ok; }
					when (/3/) { emit_done 'NOT EMPTY'; }
					when (/4/) { emit_done 'NOT PRESENT'; }

				}
			}
		}
		when(/moodle/){print "Not Implemented\n";}
	}
}

#list backend groups
sub listGroup {
	my $groups = getAllGroupsAdb($backend);
	for ($backend) {
		when (/samba4/) {
			my $groupTypes=['automatic','userdef'];	
		foreach my $groupType (@{$groupTypes}){
		while ( my $group = $groups->{$groupType}->next ) {
				emit "Samba4 group " . $group->name;
				if   ( !doS4GroupExist( $group->name ) ) { emit_done "NOT PRESENT"; }
				else                                     { emit_ok; }
			}
		}
			
			
			
			

		}
		when(/moodle/){
			my $cohortTypes=['classes','groups','schools'];
			foreach my $cohortType (@{$cohortTypes}){
			while(my $group=$groups->{$cohortType}->next){
				emit "Moodle Cohort ".$group->name;
				if   ( !doMoodleGroupExist( $group->name ) ) { emit_done "NOT PRESENT"; }
				else                                     { emit_ok; }
				}
			}
			
		}
	}
}

