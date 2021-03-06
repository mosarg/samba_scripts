#!/usr/bin/perl
use strict;
use warnings;
use experimental 'switch';
use Text::CSV;
#use encoding 'utf8', Filter => 1;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
#use Switch;
use Term::Emit ":all", { -color => 1 };
use Server::Configuration qw($ldap $schema);
use Server::Commands qw(hashNav sanitizeSubjectname sanitizeString);
use Server::LdapQuery qw(doOuExist getAllOu getUserBaseDn getUserFromUname);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist addS4Ou updateS4Group updateS4User);
use Server::AdbOu qw(getAllOuAdb);
use Server::AdbUser
  qw(getAllUsersAdb syncUsersAdb doUsersExistAdb getAllUsersByRoleAdb);
use Server::AdbAccount qw(getAccountAdb);
use Server::AisQuery
  qw(getCurrentTeacherClassAis getAisUsers getCurrentClassAis getCurrentYearAis getCurrentSubjectAis getCurrentStudentsClassSubjectAis);
use Server::System
  qw(listOu createOu checkOu  initGroups createUser removeUser moveUser recordUser createFullUser changeUserPassword activateAccount createLocalUser);
use Server::AdbClass qw(syncClassAdb);
use Server::AdbCommon
  qw(getCurrentYearAdb addYearAdb setCurrentYearAdb getActiveSchools getYearAdb);
use Server::AdbSubject qw(syncSubjectAdb);
use Server::Moodle qw(addMoodleCourse defaultEnrol unenrolAll changeMoodlePassword);
use feature "switch";




my $commands = "init,sync,list,syncCourses,add,password,update activate,bulkpassword";

my $backend     = 'samba4';
my $all         = 0;
my $resync		= 0;
my $description = 'generic description';
my $role        = 'student';
my $file        = 'new_users';
my $userRole		= 'visitors';
my $userName		= 'Utente';
my $userSurname		= 'Esterno';
my $systemUserName	= '';
my $newPassword= '';
my $usersNumber		=1;
my $quicksync='';
my $data        = {};
my $container= '';
my $bulkFile='passwords.csv';
my $local = 0;
my $maingroup= '';
my $extragroups='';
my $refYear=0;
my $ou='system';

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s'     => \$backend,
	'all'           => \$all,
	'description=s' => \$description,
	'syncrole=s'    => \$role,
	'users-file=s'  => \$file,
	'role=s'		=> \$userRole,
	'name=s'		=> \$userName,
	'surname=s'		=> \$userSurname,
	'number=i'		=> \$usersNumber,
	'username=s'	=> \$systemUserName,
	'password=s'	=> \$newPassword,
	'container=s'	=> \$container,
	'bulkfile=s'	=> \$bulkFile,
	'quicksync'		=> \$quicksync,
	'resync'		=> \$resync,
	'local'			=> \$local,
	'maingroup=s'			=> \$maingroup,
	'extragroups=s'		=> \$extragroups,
	'ou=s'				=> \$ou,
	'refyear=i'			=> \$refYear
);


$backend or die("You must specify a backend\n");
our $adbBackend =
  $schema->resultset('BackendBackend')->search( { kind => $backend } )->first;

for ( $ARGV[0] ) {

	when(/sync$/) {
		syncUsers();
	}
	when(/list/) {
		listUsers();
	}
	when(/init/) {
		initUsers();
	}
	when(/syncCourses/){
		syncCourses();
	}
	when(/add/){
		addUser();
	}
	when(/^password/){
		changePassword();
	}
	when(/update/){
		updateUser();
	}
	when(/activate/){
		activateUserAccount();
	}
	when(/^bulkpassword$/){
		bulkPasswordChange();
	}
	default { die("$ARGV[0] is not a command!\n"); }
}



sub activateUserAccount{
	my $username=$ARGV[1];
	
	if (!$username){print "You must specify a username\n";return;}
	activateAccount($username,$backend);
	
	
}



sub updateUser{
	my $username=$ARGV[1];
	
	if(!$username){
		print "You must specify exactly one username\n";
		return;
	}
	updateS4User($username,$container);
}







###############################
#
# Add User
#
###############################

sub addUser{
 my $users=[];

 if ($local){
 	
 	my $user={account=>{username=>$systemUserName,password=>$newPassword,ou=>"ou=$ou"},name=>'utente',surname=>'sistema',userIdNumber=>666};
	my @egroups=split(',',$extragroups); 			
 	createLocalUser($user,$maingroup,\@egroups);
 	return;
 }	
 if($usersNumber>1){
		for(my $index=1;$index<=$usersNumber;$index++){	
			push(@{$users},createFullUser($userRole,$userName,$userSurname.$index));
		}
	}else{
		push(@{$users}, createFullUser($userRole,$userName,$userSurname));
	}

 recordUser( $users, 'manualUsers' );
}


##########################################
#
# Change User Password
#
##########################################

sub changePassword{
	
	if ($systemUserName && $newPassword){
		changeUserPassword($systemUserName,$newPassword);
	}else{
		print "You must supply at least username and password\n";
	}
	
	
}

#####################################
#
# Sync Users
#
#####################################

sub syncUsers {

	#get db current and ais current year
	my $yearAdb='';
	
	
	
	if ($refYear > 0){
		$yearAdb = getYearAdb($refYear);
		
	}else{
		 $yearAdb = getCurrentYearAdb();
	}
	

	if ($yearAdb eq ''){
		print "Wrong year!\n";
		return 0;
	}
	
	my $newYearAdb;
	my $yearAis = getCurrentYearAis();
	my $updates = {};

	#if there are no users present abort
	if ( !doUsersExistAdb() ) {
		print "System not yet initialized!\n";
		return 0;
	}

	#choose between small update and big update
	if ( $yearAdb->year == $yearAis ) {
		$newYearAdb = $yearAdb;
		emit "Small update for role: " . colored( uc($role), 'green' );

	}
	else {
		emit "Big updated for role: " . colored( uc($role), 'green' );

		emit "Update school year: new school year $yearAis";

		$newYearAdb = addYearAdb($yearAis);
		for ( $newYearAdb->{status} ) {
			when (/1/) { $newYearAdb = $newYearAdb->{data}; emit_ok; }
			when (/2/) {
				$newYearAdb = $newYearAdb->{data};
				emit_done "PRESENT";
			}
			when (/0/) {
				emit_error;
				return;
			}
		}
		setCurrentYearAdb($yearAis);
	}

	if(!$quicksync){

	#sync classes
		emit "Sync classes $yearAis";
		syncClassAdb(getCurrentClassAis())?emit_ok:emit_done "PRESENT";

	#sync subcjects
		emit "Sync subjects $yearAis";
		syncSubjectAdb(getCurrentSubjectAis())?emit_ok:emit_done "PRESENT";
	}


	#get active schools
	my @activeSchools =
	  map { '\'' . $_->meccanographic . '\'' } @{ getActiveSchools() };

	#create adb users
	for ($role) {
		when(/student/) {
			emit "Sync students";
			$updates = syncUsersAdb(
				1,
				getAisUsers( 'student', \@activeSchools ),
				'student',
				$yearAdb->year,
				getCurrentStudentsClassSubjectAis( \@activeSchools )
			);
			$updates->{status} ? emit_ok : emit_error;
		}
		when (/teacher/) {
			emit "Sync teachers";
			
			
			$updates =
			  syncUsersAdb( 1, getAisUsers('teacher',$yearAis), 'teacher',
				$yearAdb->year, getCurrentTeacherClassAis($yearAis) );
			
			$updates->{status} ? emit_ok : emit_error;
		}
		when (/ata/) {
			emit "Sync ata";
			$updates =
			  syncUsersAdb( 1, getAisUsers('ata'), 'ata', $yearAdb->year );
			$updates->{status} ? emit_ok : emit_error;
		}
		default {
			print "Role " . colored( uc($role), 'red' ) . " not defined\n";
			return 0;
		}

	}

	#get all defined backends;

	my @backends = $schema->resultset('BackendBackend')->all;


	
	#sync backend ou
if(!$quicksync){
	foreach my $currentBackend (@backends) {
		emit "Sync ou " . colored( $currentBackend->kind, 'green' );
		listOu( $currentBackend->kind, \&createOu );
		emit_ok;
	}

	#sync base groups in backend
	foreach my $currentBackend (@backends) {
		emit "Sync groups " . colored( $currentBackend->kind, 'green' );
		initGroups( $currentBackend->kind );
		emit_ok;
	}

}


	#remove stale users from all defined backends
	emit "Update backend accounts";
	emit "Remove old users";
	foreach my $removeUser ( @{ $updates->{removedusers} } ) {
		removeUser($removeUser);
	}
	emit_ok;

	#record new users
	emit "Log deleted users data";
	recordUser( $updates->{removedusers} , $role.'_deleted_accounts',1);
	emit_ok;
	

	#add new users into backend
	emit "Create new users";
	my $newUsersData = [];
	foreach my $newUser ( @{ $updates->{newusers} } ) {
		push( @{$newUsersData}, createUser($newUser) );
	}
	emit_ok;



	#update  users backend
	emit "Update users";
	my $possibileNewBackendAccounts = [];

	foreach my $updatedUser ( @{ $updates->{modifiedusers} } ) {
		if ( $updatedUser->{regenerateAccount} ) {
			$updatedUser = createUser($updatedUser);
			my $status;
			foreach my $updateAccount ( @{$updatedUser} ) {
				if ( $updateAccount->{simpleUser} ) {
					$status = 1;
				}
			}
			if ($status) {
				push( @{$possibileNewBackendAccounts}, $updatedUser );
			}
		}

		if ( $updatedUser->{moved} ) {
		
			
			moveUser($updatedUser);
		}

	}
	recordUser( $possibileNewBackendAccounts, $role.'_missingAccounts' );

	emit_ok;

	#record new users
	emit "Log new users data";
	recordUser( $newUsersData, $role."_".$file );
	emit_ok;


	#inverse direction sync
	if ($all) {
		my $regenBackendAccounts = [];
		my $roleAdb =
		  $schema->resultset('AllocationRole')->search( { role => $role } )
		  ->first;
		emit "Check backend account presence";
		my $allCurrentUsers = getAllUsersByRoleAdb( $roleAdb, $newYearAdb );
		
		print Dumper $allCurrentUsers;
		foreach my $currentUser ( @{$allCurrentUsers} ) {
			$currentUser = createUser($currentUser);

			my $status;
			foreach my $currentAccount ( @{$currentUser} ) {
				if ( $currentAccount->{simpleUser} ) {
					$status = 1;
				}
			}
			if ($status) {
				push( @{$regenBackendAccounts}, $currentUser );
			}

		}

		recordUser( $regenBackendAccounts, $role.'_regeneratedAccounts' );
		emit_ok;
	}

	emit_done;
}

######################################################
#
# Init users
#
######################################################

sub initUsers {


	#get all defined backends;
	my @backends = $schema->resultset('BackendBackend')->all;

	my @planeBackends =
	  map {$_->kind } @backends;


	if ( doUsersExistAdb() > 0 ) {
		print "System already initialized!\n";
		return 0;
	}

	
	if('samba4'~~@planeBackends){
	#Posixify Domain Users group (in case no one did it before)
		updateS4Group('Domain\\\\ Users');
	}

	#get current school year in school Ais DB
	my $yearAis = getCurrentYearAis();

	emit "Insert school year $yearAis";
	my $yearAdb = addYearAdb($yearAis);

	for ( $yearAdb->{status} ) {
		when (/1/) { $yearAdb = $yearAdb->{data}; emit_ok; }
		when (/2/) { $yearAdb = $yearAdb->{data}; emit_done "PRESENT"; }
		when (/0/) { emit_error; return; }
	}

	emit "Set $yearAis active";
	setCurrentYearAdb($yearAis);
	emit_ok;

	#create classes
	emit "Init classes $yearAis";
	syncClassAdb( getCurrentClassAis() ) ? emit_ok : emit_error;

	#create subjects
	emit "Init subjects $yearAis";
	syncSubjectAdb( getCurrentSubjectAis() ) ? emit_ok : emit_error;

	#get active schools
	emit "Get active schools";
	my @activeSchools =
	  map { '\'' . $_->meccanographic . '\'' } @{ getActiveSchools() };
	emit_ok;
	
	#create adb users
	emit "Init students $yearAis";
	(
		syncUsersAdb(
			0, getAisUsers( 'student', \@activeSchools ),
			'student', $yearAis,
			getCurrentStudentsClassSubjectAis( \@activeSchools )
		)
	)->{status} ? emit_ok : emit_error;
	emit "Init teachers $yearAis";
	(
		syncUsersAdb(
			0, getAisUsers('teacher'), 'teacher', $yearAis,
			getCurrentTeacherClassAis($yearAis)
		)
	)->{status} ? emit_ok : emit_error;
	emit "Init ata $yearAis";
	( syncUsersAdb( 0, getAisUsers('ata'), 'ata', $yearAis ) )->{status}
	  ? emit_ok
	  : emit_error;

	

	#Init backend ou

	foreach my $currentBackend (@backends) {
		emit "Init ou ou " . colored( $currentBackend->kind, 'green' );
		listOu( $currentBackend->kind, \&createOu );
		emit_ok;
	}

	#create base groups in backend
	foreach my $currentBackend (@backends) {
		emit "Init groups " . colored( $currentBackend->kind, 'green' );
		initGroups( $currentBackend->kind );
		emit_ok;
	}

	#get just created users
	my $users = getAllUsersAdb($yearAdb);

	#create users accounts
	my $usersData = [];
	foreach my $user ( @{$users} ) {
		push( @{$usersData}, createUser($user) );
	}

	emit "Log new users data";
	recordUser( $usersData, $file );
	emit_ok;

}

sub syncCourses {

	my $year = getCurrentYearAdb();
	my $teacherRole=$schema->resultset("AllocationRole")->search({role=>'teacher'});
	my $role=$schema->resultset('AllocationRole')->search({role=>'teacher'})->first;
	my $backend=$schema->resultset("BackendBackend")->search({kind=>'moodle'})->first;
	#get all courses
	my @classes = $schema->resultset('SchoolClass')->all;
	foreach my $class (@classes) {

		my @allocations = $class->allocation_didacticalallocations(
			{ 'allocation_id.yearId_id' => $year->school_year_id },
			{
				join     => 'allocation_id',
				select   => [ 'allocation_id.yearId_id', 'subjectId_id' ],
				distinct => 1
			}
		)->all;
	
		my $cohort=$class->name;
		
		foreach my $allocation (@allocations) {

		#get subject teacher(s)
		
		my @currentTeachers=$schema->resultset('SysuserSysuser')->search({'allocation_allocations.yearId_id'=>$year->school_year_id,
																	  'allocation_allocations.roleId_id'=>$role->role_id,
																	'allocation_didacticalallocations.classId_id'=>$class->class_id,
																	'allocation_didacticalallocations.subjectId_id'=>$allocation->subject_id->subject_id},{join=>{'allocation_allocations'=>'allocation_didacticalallocations'} })->all;
		my @teacherAccounts;
		
		foreach my $currentTeacher (@currentTeachers){
			push(@teacherAccounts,$currentTeacher->account_accounts({backendId_id=>$backend->backend_id})->first->username);
		}
				
		
		my $courseName=sanitizeString($allocation->subject_id->short_description)." $cohort";
		
		if ( !($courseName=~m/Condotta|Nessuna Materia/) ){
			emit "Create Course  ".colored($cohort,'green')." ".sanitizeString($allocation->subject_id->description);
			my $result=addMoodleCourse({category=>$cohort, description=>sanitizeString($allocation->subject_id->description),
					     fullname=>$courseName,id=>$cohort."@".$allocation->subject_id->code,
					     shortname=>$cohort."_".sanitizeSubjectname($allocation->subject_id->short_description)});
			for ($result->{creation}){
				when($_==2){emit_done "PRESENT";}
				when($_==1){emit_ok;}
				when($_==3){emit_error;}
				when($_==4){emit_error;}
				when($_==0){emit_fatal;}
			
			}
		
			if(  ($result->{creation}==2) && ($resync) ){
					emit "Unenrol all users";
						unenrolAll($result);
					emit_ok;
				}
		
		
			if( ($result->{creation}==1) || ($result->{creation}==2) ){	
				
				emit "Enrol $cohort to $courseName";
				my $enrolStatus=defaultEnrol(\@teacherAccounts,$cohort,$result);
					if($enrolStatus->{error}){emit_error}else{emit_ok;}	
				}
			}

		}
	}

}

sub listUsers {

	my $year = getCurrentYearAdb();
	if ( !$year ) {
		print "System not initialized\n";
		return 0;
	}
	my $users = getAllUsersAdb($year);
	foreach my $user ( @{$users} ) {
		my $account =
		  $user->account_accounts( { backendId_id => $adbBackend->backend_id } )
		  ->first;
		print $user->name . " "
		  . $user->surname . " "
		  . colored( $account->username, 'yellow' )
		  . " active:"
		  . $account->active . " OU "
		  . "  $backend dn:"
		  . getUserBaseDn( $account->username ) . "\n";
	}
}

sub bulkPasswordChange{
		my @columns;
		my $csvParser=Text::CSV->new();
		
		open (CSVDATA, "<", $bulkFile) or die "Cannot open input file\n";
		while(<CSVDATA>){
			next if($.==1);
			if ($csvParser->parse($_)){
				@columns=$csvParser->fields();
				emit "Change Moodle Password for $columns[2]";
					changeMoodlePassword($columns[2],$columns[3]);
				emit_ok;
			}
		}
		close CSVDATA;
}




