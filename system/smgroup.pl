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
use Server::System qw(initGroups init);
use Server::AdbCommon qw($schema);
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

$data->{backend} = $backend;

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

sub addGroup {

	my $groupName  = $ARGV[1];
	my $policyName = $ARGV[2];

	for ($backend) {
		when (/samba4/) {

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
			my $policy =$schema->resultset('AccountPolicy')->search({name=>$policyName});
			if($policy->count==0){
				emit_error;
				return 0;
			}
			
			if($group){
				setPolicyGroupAdb( $group, $policy->next);
			}else{
				emit_error;
				return 0;
			}
			my $result = addS4Group( $ARGV[1] );
			for ($result) {
				when (/1/) { emit_ok; }
				when (/0/) { emit_error; }
				when (/2/) { emit_done "PRESENT" }
			}
		}
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

	}
}

#list backend groups
sub listGroup {
	for ($backend) {
		when (/samba4/) {
			my $groups = getAllGroupsAdb($backend);

			while ( my $group = $groups->next ) {
				emit "Samba4 group " . $group->name;
				if   ( !doS4GroupExist( $group->name ) ) { emit_error; }
				else                                     { emit_ok; }
			}

		}
	}
}

