#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Server::Configuration qw($ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu getUserBaseDn getUserFromUname);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist addS4Ou);
use Server::AdbOu qw(getAllOuAdb getOuByUsernameAdb getOuByUserIdAdb);
use Server::AdbUser qw(getAllUsersAdb syncUsersAdb doUsersExistAdb);
use Server::AdbAccount qw(getAccountAdb updateAccountAdb);
use Server::AisQuery qw(getCurrentTeacherClassAis getAisUsers getCurrentClassAis);
use Server::System qw(listOu createOu checkOu init initGroups createUser);
use Server::AdbClass qw(syncClassAdb);
use Server::AdbCommon qw(getCurrentYearAdb);


my $commands = "init,sync,list";

my $backend     = '';
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
	my $year=getCurrentYearAdb();
	
	if (!doUsersExistAdb){
		print "System not yet initialized!\n";
		return 0;
	}
	
	#sync classes
	syncClassAdb(getCurrentClassAis());
	
	
	#create adb users
	syncUsersAdb(getAisUsers('teacher'),'teacher',getCurrentTeacherClassAis($year));
	syncUsersAdb(getAisUsers('student'),'student');
	syncUsersAdb(getAisUsers('ata'),'ata');
	
	my $users=getAllUsersAdb();
	
	#create backend ou
	listOu( \&createOu );
		
}


sub initUsers{
	my $year=shift;
	
	if (doUsersExistAdb()>0){
		print "System already initialized!\n";
		return 0;
	}
	
	#create classes
	syncClassAdb(getCurrentClassAis());
	
	#create adb users
	syncUsersAdb(getAisUsers('teacher'),'teacher',getCurrentTeacherClassAis($year));
	syncUsersAdb(getAisUsers('student'),'student');
	syncUsersAdb(getAisUsers('ata'),'ata');
	
	#create backend ou
	listOu( \&createOu );
	
	#create base groups in backend
	initGroups();
	
	#get just created users
	my $users=getAllUsersAdb();
	
	foreach my $user (@{$users}){
		
		#get user account
		$user->{account}=getAccountAdb($user->{userIdNumber},$backend);
		#get user base dn
		$user->{baseDn}=getUserBaseDn($user->{account}->{username});
		
		
		if (! $user->{baseDn}){
			$user=createUser($user,$backend);
			updateAccountAdb($user->{account});			
		}else{
			print "Backend account already present error!\n";
		}
	}
}


sub listUsers{
		my $users=getAllUsersAdb();
		foreach my $user (@{$users}){
			$user->{account}=getAccountAdb($user->{userIdNumber},$backend);
			print $user->{name}." ".$user->{surname}." ".$user->{account}->{username}." active:".$user->{account}->{active}." OU ".getOuByUsernameAdb($user->{account}->{username},$user->{role},'samba4').
								"  $backend dn:".getUserBaseDn($user->{account}->{username}) ." $backend user:".getUserFromUname($user->{account}->{username})."\n";
		} 
}
