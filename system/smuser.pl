#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Term::Emit ":all", {-color => 1};
use Server::Configuration qw($ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu getUserBaseDn getUserFromUname);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist addS4Ou);
use Server::AdbOu qw(getAllOuAdb getOuByUsernameAdb getOuByUserIdAdb);
use Server::AdbUser qw(getAllUsersAdb syncUsersAdb doUsersExistAdb);
use Server::AdbAccount qw(getAccountAdb updateAccountAdb);
use Server::AisQuery qw(getCurrentTeacherClassAis getAisUsers getCurrentClassAis getCurrentYearAis getCurrentSubjectAis);
use Server::System qw(listOu createOu checkOu init initGroups createUser removeUser moveUser recordUser);
use Server::AdbClass qw(syncClassAdb);
use Server::AdbCommon qw(getCurrentYearAdb addYearAdb setCurrentYearAdb);
use Server::AdbSubject qw(syncSubjectAdb);


my $commands = "init,sync,list";

my $backend     = 'samba4';
my $all         = 0;
my $description = 'generic description';
my $role	='student';
my $file ='new_users.csv';
my $data={};

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s'     => \$backend,
	'all'           => \$all,
	'description=s' => \$description,
	'role=s'		=> \$role,
	'users-file=s' =>\$file
);
$backend or die("You must specify a backend\n");

$data->{backend}=$backend;

init($data);

switch ( $ARGV[0] ) {

	case 'sync' {
		syncUsers();
	}
	case 'list' {
		listUsers();
	}
	case 'init' {
	initUsers(2012);		
	}
	else { die("$ARGV[0] is not a command!\n"); }
}


sub syncUsers{
	
	#get db current and ais current year
	
	my $yearAdb=getCurrentYearAdb();
	my $yearAis=getCurrentYearAis();
	my $updates={};
	
	#if there are no users present abort
	if (!doUsersExistAdb()){
		print "System not yet initialized!\n";
		return 0;
	}
	
	#choose between small update and big update
	if($yearAdb==$yearAis){
		emit "Small update for role: ".colored(uc($role),'green');
		
	}else{
		emit "Big updated for role: ".colored(uc($role),'green');
		emit "Update school year: new school year $yearAis";
		addYearAdb($yearAis);
		setCurrentYearAdb($yearAis);
		emit_ok;
	}
	
	#sync classes
	emit "Sync classes $yearAis";
	syncClassAdb(getCurrentClassAis())?emit_ok:emit_done "PRESENT";
		
	#sync subcjects
	emit "Sync subjects $yearAis";
	syncSubjectAdb(getCurrentSubjectAis())?emit_ok:emit_done "PRESENT";
	
		
	#create adb users
	switch($role){
		case 'student' {
			emit "Sync students";
			$updates=syncUsersAdb(getAisUsers('student'),'student',$yearAdb);
			$updates->{status}?emit_ok:emit_error;
		}
		case 'teacher' {
			emit "Sync teachers";
			$updates=syncUsersAdb(getAisUsers('teacher'),'teacher',$yearAdb,getCurrentTeacherClassAis($yearAis));
			$updates->{status}?emit_ok:emit_error;
		}
		case 'ata'	   {
			emit "Sync ata";
			$updates=syncUsersAdb(getAisUsers('ata'),'ata',$yearAdb);
			$updates->{status}?emit_ok:emit_error;
		}
		default		   {
			print "Role ".colored(uc($role),'red')." not defined\n";
			return 0;
		}
			
	}

	emit "Sync ou";
	#create backend ou
	listOu( \&createOu );
	emit_ok;
	
	#sync base groups in backend
	emit "Sync groups";
		initGroups();
	emit_ok;
	
	
	#remove stale users from backend
		
	emit "Update backend accounts";	

	emit "Remove old users";		
	foreach my $removeUser (@{$updates->{removedusers}}){
		
		removeUser($removeUser);
	}
	emit_ok;
	#update  users backend
	
	emit "Move users";
	foreach  my $updatedUser (@{$updates->{modifiedusers}}){
		moveUser($updatedUser);

	}
	emit_ok;
	#add new users into backend
	emit "Create new users";
	foreach my $newUser (@{$updates->{newusers}}){
		$newUser=createUser($newUser);
	}
	emit_ok;
	
	#record new users
	emit "Log new users data";
	recordUser($updates->{newusers},$file);
	emit_ok;
	
	emit_done;
}


sub initUsers{
	my $year=shift;
	
	if (doUsersExistAdb()>0){
		print "System already initialized!\n";
		return 0;
	}
	
	#get current school year in school Ais DB
	my $yearAis=getCurrentYearAis();
	
	
	emit "Insert school year $yearAis";
	addYearAdb($yearAis)?emit_ok:emit_error;
	
	emit "Set $year active";
	setCurrentYearAdb($yearAis)?emit_ok:emit_error;
	
	#create classes
	emit "Init classes $year";
	syncClassAdb(getCurrentClassAis())?emit_ok:emit_error;
	
	#create subjects
	emit "Init subjects $year";
	syncSubjectAdb(getCurrentSubjectAis())?emit_ok:emit_error;
	
	
	#create adb users
	emit "Init students $year";
	(syncUsersAdb(getAisUsers('student'),'student',$yearAis))->{status}?emit_ok:emit_error;
	emit "Init teachers $year";
	(syncUsersAdb(getAisUsers('teacher'),'teacher',$yearAis,getCurrentTeacherClassAis($yearAis)))->{status}?emit_ok:emit_error;
	emit "Init ata $year";
	(syncUsersAdb(getAisUsers('ata'),'ata',$yearAis))->{status}?emit_ok:emit_error;
	
	
	#create backend ou
	emit "Init ou";
	listOu( \&createOu );
	emit_ok;
	
	#create base groups in backend
	emit "Init group";
	initGroups();
	emit_ok;
	
	#get just created users
	my $users=getAllUsersAdb($yearAis);
	
	foreach my $user (@{$users}){
		$user=createUser($user);
	}
	
	emit "Log new users data";
		recordUser($users,$file);
	emit_ok;
	
}


sub listUsers{
		my $users=getAllUsersAdb();
		foreach my $user (@{$users}){
			$user->{account}=getAccountAdb($user->{userIdNumber},$backend);
			print $user->{name}." ".$user->{surname}." ".$user->{account}->{username}." active:".$user->{account}->{active}." OU ".getOuByUsernameAdb($user->{account}->{username},$user->{role},'samba4').
								"  $backend dn:".getUserBaseDn($user->{account}->{username}) ." $backend user:".getUserFromUname($user->{account}->{username})."\n";
		} 
}
