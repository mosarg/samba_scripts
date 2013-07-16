package Server::AdbUser;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery getCurrentYearAdb);
use Server::AdbAccount qw(addAccountAdb doAccountExistAdb getAccountAdb);
use Server::AdbPolicy qw(setDefaultPolicyAdb);
use Server::AdbAllocation qw(addAllocationAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername today);
require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(syncUsersAdb addUserAdb getAllUsersAdb doUsersExistAdb);




sub doUsersExistAdb{
	my $query =
	  "SELECT COUNT(userIdNumber) FROM user";
	return executeAdbQuery($query);
}

sub doUserExistAdb {
	my $userId = shift;
	my $query =
	  "SELECT COUNT(userIdNumber) FROM user WHERE userIdNumber=$userId";
	return executeAdbQuery($query);
}



sub getAllUsersAdb{

	my $query="SELECT DISTINCT user.userIdNumber,user.name,user.surname,user.role,meccanographic  
				FROM user INNER JOIN studentAllocation USING(userIdNumber) 
				INNER JOIN class USING(classId) INNER JOIN school USING(meccanographic) 
				WHERE YEAR=(SELECT year FROM schoolYear WHERE current=true) 
				AND meccanographic IN (SELECT meccanographic FROM school WHERE active=true)";
	$query.=" UNION SELECT DISTINCT  user.userIdNumber,user.name,user.surname,user.role,meccanographic  
				FROM user INNER JOIN ataAllocation USING(userIdNumber) 
				INNER JOIN school USING(meccanographic) 
				WHERE YEAR=(SELECT year FROM schoolYear WHERE current=true) 
				AND meccanographic IN (SELECT meccanographic FROM school WHERE active=true)";
	$query.=" UNION SELECT DISTINCT  user.userIdNumber,user.name,user.surname,user.role,meccanographic  
				FROM user INNER JOIN teacherAllocation USING(userIdNumber) 
				INNER JOIN class USING(classId)
				INNER JOIN school USING(meccanographic) 
				WHERE YEAR=(SELECT year FROM schoolYear WHERE current=true) 
				AND meccanographic IN (SELECT meccanographic FROM school WHERE active=true) GROUP BY userIdNumber";						
	my $result = $adbDbh->prepare($query);
	$result->execute();
	return $result->fetchall_arrayref({});
}


sub normalizeUserAdb {
	my $user          = shift;
	my $role          = shift;
	my $allocationMap = shift;
	$user->{name}    = ucfirst( sanitizeString( lc( $user->{name} ) ) );
	$user->{surname} = ucfirst( sanitizeString( lc( $user->{surname} ) ) );

	if ( $role eq 'student' ) {
		$user = normalizeStudentAdb($user);
	}
	if ( $role eq 'teacher' ) {
		$user = normalizeTeacherAdb( $user, $allocationMap );
	}
	if ( $role eq 'ata' ) {
		$user = normalizeAtaAdb($user);
	}

	return $user;
}

sub normalizeStudentAdb {
	my $user = shift;
	$user->{classLabel} = lc( $user->{classLabel} );
	$user->{classId}    = $user->{classNumber} . $user->{classLabel};
	return $user;
}

sub normalizeAtaAdb {
	my $user = shift;
	$user->{year} = getCurrentYearAdb();
	return $user;
}

sub normalizeTeacherAdb {
	my $user        = shift;
	my $allocations = shift;
	$user->{year} = getCurrentYearAdb();
	my $allocation = $allocations->{ $user->{userIdNumber} };
	if (!$allocation){
		$allocation=[{classId=>'0Ext',subjectId=>1000666}];
	}
	$user->{allocations} = $allocation;
	return $user;
}

sub normalizeUsersAdb {
	my $users         = shift;
	my $role          = shift;
	my $allocationMap = shift;
	my $index         = 0;
	foreach my $user ( @{$users} ) {
		$users->[$index] =
		  normalizeUserAdb( $users->[$index], $role, $allocationMap )
		  ;
		$index++;
	}
	return $users;
}

sub addUserAdb {
	my $user = shift;
	my $role = shift;
	my $origin=shift;
	$user->{role} = $role;
	my $userStatus={};
	my $accountType='samba4';
	my $account='';
	#Check status;
	$userStatus->{user}=doUserExistAdb( $user->{userIdNumber});
	$userStatus->{account}=doAccountExistAdb($user->{userIdNumber},$accountType);
	
	
	if(!$userStatus->{user}){
				my $query =
"INSERT INTO user (userIdNumber,name,surname,role,origin,creation) VALUES ($user->{userIdNumber},\'$user->{name}\',\'$user->{surname}\',\'$user->{role}\',\'$origin\',\'".today()."\')";
		my $queryH = $adbDbh->prepare($query);
		$queryH->execute();
		
	}
	if(!$userStatus->{account}){
		$account = addAccountAdb( $user, $accountType);
	}else{
		$account=getAccountAdb($user->{userIdNumber},$accountType);
	}
	
	if ( !addAllocationAdb( $user, $role ) ) {
			$user->{allocation}=0;
			print "Cannot allocate user!\n";
	}
	setDefaultPolicyAdb( $account, $user->{role} );
	return $account;
}

sub syncUsersAdb {
	my $users          = shift;
	my $role           = shift;
	my $allocationList = '';

	if ( $role eq 'teacher' ) {
		$allocationList = shift;
	}
	$users = normalizeUsersAdb( $users, $role, $allocationList );
	foreach my $user ( @{$users} ) {
		addUserAdb( $user, $role ,'automatic');
	}
}

1;

