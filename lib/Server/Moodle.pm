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
  qw(doMoodleUserExist addMoodleOuElement getMoodleOuId addMoodleOu doMoodleOuExist doMoodleGroupExist addMoodleGroup addMoodleUser getUserCohorts deleteMoodleUser addMoodleCourse defaultEnrol unenrolAll changeMoodlePassword);


my $moosh = "moosh --moodle-path /var/www/moodle";

my $backendId="moodle";

sub getUserCohorts {
	my $user    = shift;
	my @results = execute(
"$moosh sql-run \\\"select distinct name,c.id from {user}  u inner join {cohort_members} m on\\(u.id=m.userid\\) inner join {cohort} c on \\(m.cohortid=c.id\\) where username=\\\'$user\\\'\\\"|grep \'\\\[name\\\]\\\|\\\[id\\\]\'",$backendId
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


sub changeMoodlePassword{
	
	my $username=shift;
	my $password=shift;
	
	my $command="$moosh user-mod --password \\\"$password\\\" $username";
	
	execute($command,$backendId);
	
	
}


sub addMoodleCourse{
	my $course=shift;

	my $category=getMoodleOuId($course->{category});
		
	my $result=execute("$moosh course-create --category $category->{id} --fullname \\\"$course->{fullname}\\\" --description \\\"$course->{description}\\\" --idnumber \\\"$course->{id}\\\" --format \\\"topics\\\" $course->{shortname}",$backendId);

	for ($result){
		when(/^\d+$/){$course->{creation}=1;$course->{message}='Course created succesfully';$course->{id}=$result; return $course;}
		when(/Short name|Il titolo abbreviato/){
			my $id=execute("$moosh sql-run \\\"select id from {course} where shortname=\\\'$course->{shortname}\\\'\\\"|grep id|cut -d \"\>\" -f2",$backendId);	
			chomp($id);
			$course->{id}=$id;
			$course->{creation}=2;
			$course->{message}='Duplicate short name';
			return $course;
		}
		when(/Error code: idnumbertaken/){$course->{creation}=3;$course->{message}='Duplicate course id number'; return $course;}
		when(/Error code: invalidrecord/){$course->{creation}=4;$course->{message}='Category Id doesn\'t exist'; return $course;}
		default {$course->{creation}=0;$course->{message}='Unknown error';  return $course;}
	}

}

sub addMoodleUser {
	my $user   = shift;
	my $groups = shift;
	my $userId = 0;
	$user->{creationStatus} = 1;
	my $result;
	
	my $userPresence=doMoodleUserExist($user);
	for($userPresence){
		when($_==0){
			my $command="$moosh user-create --password \\\"$user->{account}->{password}\\\"";
			$command.=" --firstname \\\"$user->{name}\\\" --lastname \\\"$user->{surname}\\\"";
			$command.=" --email \\\"$user->{account}->{username}\@".$ldap->{default_mail}."\\\"";
			$command.=" --country=IT --city=".$ldap->{city};
			$command.=" --auth manual $user->{account}->{username}";
						
			$result = execute($command,$backendId);
			for ($result) {
				when (/^\d+/) {
					chomp($result);
					$userId = $result;
					$user->{creationStatus} = 1;
				}
				when (/Duplicate entry/) { $user->{creationStatus} =  2; }
				when(/authpluginnotfound/){$user->{creationStatus} =  15;}
				default                  { $user->{creationStatus} =   0; }
			}
	
		}
		when($_==-5){
			$user->{creationStatus} =  0;
				return $user;
		}
		when($_==-15){
			$user->{creationStatus} =  15;
				return $user;
		}
		when($_>0){
			$user->{creationStatus} =  2;
		}
	}
	
	
	

	$user->{account}->{backendUidNumber} =
	  execute("$moosh user-getidbyname $user->{account}->{username}",$backendId);
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
			my $enrolStatus = execute("$moosh cohort-enrol -u $user->{account}->{backendUidNumber} $group",$backendId);
			for ($enrolStatus) {
				when (/Cohort does not exist/) { $user->{account}->{error}=1; }
				when (/Notice:: not found/){print "Group not found\n"; $user->{account}->{error}=1;}
				
			}

		}
	}
	foreach my $removeGroup ( keys(%{$currentGroups} ) ){
		my $unenrolStatus = execute("$moosh cohort-unenrol  $currentGroups->{$removeGroup} $user->{account}->{backendUidNumber}",$backendId
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
	  execute("$moosh user-getidbyname $user->{account}->{username}",$backendId);
	chomp($result);
	for ($result) {
		when (/^\d+$/)               { return $result; }
		when (/PHP Notice/)          { return 0; }
		when (/No command provided/) { return -5; }
		default                      { return -15; }
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
"\'echo -n \$\($moosh category-list |egrep \'^[0-9]*[[:space:]]*".$ou."[[:space:]]\'\)\'",$backendId
	);
	
	
	chomp($data);
	
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
		  execute("$moosh category-create -p $parentId -v 1  $ouElement",$backendId);
	}
	else {
		$result = execute("$moosh category-create  -v 1  $ouElement",$backendId);
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
	my $result = execute("$moosh cohort-enrol $cohort",$backendId);
	for ($result) {
		when (/Not enough arguments/)  { return 1 }
		when (/Cohort does not exist/) { return 0 }
		default                        { return 0; }
	}
}

sub addMoodleGroup {
	my $cohort = shift;
	my $result = execute("$moosh cohort-create $cohort",$backendId);
	for ($result) {
		when (/\d+/)                           { return 1 }
		when (/Not enough arguments provided/) { return 0; }
		when (/Cohort already exists/)         { return 2; }
		default                                { return 0; }
	}
}


sub deleteMoodleUser{
	
	my $username=shift;
	my $result=execute("$moosh user-delete $username",$backendId);
	for ($result){
		when(/User not found/){return 0;}
		default {return 1;}
	}
	
}


sub unenrolAll{
	my $course=shift;
	
	my $result=execute("$moosh course-unenrol --role editingteacher,teacher --cohort 1 $course->{id}",$backendId);
	
	for($result){
		when(/Can not find data record in database table course/){return $course->{result}=0;}
		default{return $course->{result}=1;}
	}
	
}


sub defaultEnrol{
	my $teachers=shift;
	my $cohort=shift;
	my $course=shift;
	
	#enrol teacher to course
	
	
	
	foreach my $teacher (@{$teachers}){	
		my $teacherResult=execute("$moosh course-enrol  -r editingteacher $course->{id}  $teacher ",$backendId);
	
		for ($teacherResult){
			when(/Error code: invaliduser/){return {error=>1,message=>'Invalid user'};}
		}
		
	}
	
	#enrol cohort to course

	my $cohortError=execute("$moosh cohort-enrol -c $course->{id} $cohort",$backendId);
	
	
	
	
}


return 1;
