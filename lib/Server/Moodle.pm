package Server::Moodle;

use strict;
use warnings;
use Data::Dumper;
use String::MkPasswd qw(mkpasswd);
use Cwd;
use Server::Configuration qw($server $ldap);
use Server::Commands qw(execute doFsObjectExist sanitizeString);
use Server::Actions qw(moveDir);
use feature "switch";
use Try::Tiny;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(doMoodleUserExist addMoodleOuElement getMoodleOuId addMoodleOu doMoodleOuExist doMoodleGroupExist addMoodleGroup addMoodleUser getUserCohorts);

my $moosh = "moosh --moodle-path /var/www/moodle";

sub getUserCohorts {
	my $user    = shift;
	my @results = execute(
"$moosh sql-run \\\"select distinct name,c.id from {user}  u inner join {cohort_members} m on\\(u.id=m.userid\\) inner join {cohort} c on \\(m.cohortid=c.id\\) where username=\\\'$user\\\'\\\"|grep \'\\\[name\\\]\\\|\\\[id\\\]\'"
	);

	chomp(@results);

	my $cohorts;
	for(my $index=0;$index<scalar(@results);$index+=2){
		my ($name) = $results[$index] =~ m/=>\s+(\w+)$/;
		my ($id)=$results[$index+1]=~ m/=>\s+(\w+)$/;
		$cohorts->{$name}=$id;
	}
	
	
	return $cohorts;

}

sub addMoodleUser {
	my $user   = shift;
	my $groups = shift;
	my $userId = 0;
	

	my $result = execute("$moosh user-create --password $user->{account}->{password} --firstname $user->{name} --lastname $user->{surname} $user->{account}->{username}");

	for ($result) {
		when (/^\d+/) {
			chomp($result);
			$userId = $result;
			$user->{creationStatus} = 1;
		}
		when (/Duplicate entry/) { $user->{creationStatus} = 2; }
		default                  { $user->{creationStatus} = 0; }
	}

	$user->{account}->{backendUidNumber} =
	  execute("$moosh user-getidbyname $user->{account}->{username}");
	chomp( $user->{account}->{backendUidNumber} );

	my $currentGroups = {};

	if ( $user->{creationStatus} == 2 ) {
		$currentGroups = getUserCohorts( $user->{account}->{username} );
	}

	foreach my $group ( @{$groups} ) {
		if ( $group ~~ $currentGroups ) {
			delete($currentGroups->{$group});
		}
		else {
			my $enrolStatus = execute(
"$moosh cohort-enrol -u $user->{account}->{backendUidNumber} $group"
			);
			for ($enrolStatus) {
				when (/Cohort does not exist/) { print "Cohort $group not present\n"; }
			}

		}
	}


	foreach my $removeGroup ( keys(%{$currentGroups} ) ){
		
		my $unenrolStatus = execute(
"$moosh cohort-unenrol  $currentGroups->{$removeGroup} $user->{account}->{backendUidNumber}"
		);
		for ($unenrolStatus) {
			when (/Cohort does not exist/) { print "Cohort $removeGroup not present\n"; }
		}
	}
	return $user;
}

sub doMoodleUserExist {
	my $user = shift;
	my $result =
	  execute("$moosh user-getidbyname $user->{account}->{username}");
	chomp($result);
	for ($result) {
		when (/^\d+$/)               { return $result; }
		when (/PHP Notice/)          { return 0; }
		when (/No command provided/) { return 2; }
		default                      { return 15; }
	}
	return 0;
}

sub doMoodleOuExist {
	my $ou     = shift;
	my @ous    = split( ',', $ou );
	my $result = getMoodleOuId( $ous[0] );
	return !$result->{error};
}

sub getMoodleOuId {
	my $ou     = shift;
	my $result = { error => 0 };
	my $data   = execute(
"\'echo -n \$\($moosh category-list |egrep \'^[0-9]*[[:space:]]*$ou\'\)\'"
	);
	for ($data) {
		when (/^\d+/) {
			my @elements = split( ' ', $data );
			$result->{id}     = $elements[0];
			$result->{name}   = $elements[1];
			$result->{parent} = $elements[-1];
			return $result;
		}
		default {
			$result->{error} = 1;
			return $result;
		}
	}
}

sub addMoodleOu {
	my $ou             = shift;
	my @ou             = split( ',', $ou );
	my $elementsNumber = scalar(@ou);

	if ( $elementsNumber - 1 > 0 ) {
		my $parent = getMoodleOuId( $ou[1] );
		if ( !$parent->{error} ) {
			return addMoodleOuElement( $ou[0], $parent->{id} );
		}
		else {
			return 0;
		}
	}
	else {
		return addMoodleOuElement($ou);
	}
}

sub addMoodleOuElement {
	my $ouElement = shift;
	my $parentId  = shift;

	my $result;

	if ( !( getMoodleOuId($ouElement) )->{error} ) {
		return 2;
	}

	if ($parentId) {

		$result =
		  execute("$moosh category-create -p $parentId -v 1  $ouElement");
	}
	else {
		$result = execute("$moosh category-create  -v 1  $ouElement");
	}

	chomp($result);

	for ($result) {
		when (/^\d+$/)               { return 1; }
		when (/PHP Notice/)          { return 0; }
		when (/PHP Fatal/)           { return 0; }
		when (/No command provided/) { return 5; }
		default                      { return 15; }
	}

	return 0;
}

sub doMoodleGroupExist {
	my $cohort = shift;
	my $result = execute("$moosh cohort-enrol $cohort");
	for ($result) {
		when (/Not enough arguments/)  { return 1 }
		when (/Cohort does not exist/) { return 0 }
		default                        { return 0; }
	}
}

sub addMoodleGroup {
	my $cohort = shift;
	my $result = execute("$moosh cohort-create $cohort");
	for ($result) {
		when (/\d+/)                           { return 1 }
		when (/Not enough arguments provided/) { return 0; }
		when (/Cohort already exists/)         { return 2; }
		default                                { return 0; }
	}
}

return 1;
