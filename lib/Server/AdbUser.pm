package Server::AdbUser;

use DBI;
use strict;
use warnings;
use Cwd;
use List::UtilsBy qw(extract_by);
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery getCurrentYearAdb);
use Server::AdbAccount qw(addAccountAdb doAccountExistAdb getAccountAdb updateAccountAdb getUserAccountTypesAdb getAccountsAdb);
use Server::AdbPolicy qw(setDefaultPolicyAdb);
use Server::AdbAllocation qw(addAllocationAdb removeAllocationAdb);
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



sub getUserOrderAdb{
	my $query="SELECT MAX(insertOrder)+1 AS newOrder FROM user";
	my $result=executeAdbQuery($query);
	return $result?$result:0;
}








sub getAllUsersByRoleAdb{
	my $role=shift;
	my $year=shift;
	my $query={};
	$query->{student}="SELECT DISTINCT user.userIdNumber,user.name,user.surname,user.role,meccanographic  
				FROM user INNER JOIN studentAllocation USING(userIdNumber) 
				INNER JOIN class USING(classId) INNER JOIN school USING(meccanographic) 
				WHERE YEAR=$year 
				AND meccanographic IN (SELECT meccanographic FROM school WHERE active=true)";
	$query->{teacher}="SELECT DISTINCT  user.userIdNumber,user.name,user.surname,user.role,meccanographic  
				FROM user INNER JOIN teacherAllocation USING(userIdNumber) 
				INNER JOIN class USING(classId)
				INNER JOIN school USING(meccanographic) 
				WHERE YEAR=$year 
				AND meccanographic IN (SELECT meccanographic FROM school WHERE active=true) GROUP BY userIdNumber";
	$query->{ata}="SELECT DISTINCT  user.userIdNumber,user.name,user.surname,user.role,meccanographic  
				FROM user INNER JOIN ataAllocation USING(userIdNumber) 
				INNER JOIN school USING(meccanographic) 
				WHERE YEAR=$year
				AND meccanographic IN (SELECT meccanographic FROM school WHERE active=true)";
	my $result = $adbDbh->prepare($query->{$role});
	$result->execute();
	return $result->fetchall_arrayref({});			
}




sub getAllUsersAdb{
	my $year=shift;
	return [@{getAllUsersByRoleAdb('student',$year)},@{getAllUsersByRoleAdb('ata',$year)},@{getAllUsersByRoleAdb('teacher',$year)}];
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
	
	#Check status;
	$userStatus->{user}=doUserExistAdb( $user->{userIdNumber});
	$userStatus->{account}=doAccountExistAdb($user->{userIdNumber},$accountType);
	$user->{pristine}=0;
	$user->{modified}=0;
	
	
	if(!$userStatus->{user}){
				my $query =
"INSERT INTO user (userIdNumber,name,surname,role,origin,creation,insertOrder) VALUES ($user->{userIdNumber},\'$user->{name}\',\'$user->{surname}\',\'$user->{role}\',\'$origin\',localtime,$user->{insertOrder})";
		my $queryH = $adbDbh->prepare($query);
		$queryH->execute();
		$user->{pristine}=1;
	}
	if(!$userStatus->{account}){
		$user->{account} = addAccountAdb( $user, $accountType);
		$user->{modified}=1;
	}else{
		$user->{account} = getAccountAdb($user->{userIdNumber},$accountType);
	}
	
	if (!addAllocationAdb( $user, $role ) ) {
			$user->{allocation}=0;
	}else{
		$user->{modified}=1;
	}
	if(setDefaultPolicyAdb( $user->{account}, $user->{role} )){$user->{modified}=1};
	
	return $user;
}

sub deactivateUserAdb{
	my $user=shift;
	my $role=shift;
	removeAllocationAdb($user,$role);
	my $accounts=getAccountsAdb($user->{userIdNumber});
	$user->{account}=$accounts->[0];
	foreach my $account (@{$accounts}){
		$account->{active}=0;	
		updateAccountAdb($account);	
	}
	return $user;
}


sub syncUsersAdb{
	my $users          = shift;
	my $role           = shift;
	my $year		   = shift;
	
	my $allocationList = '';
	
	my @modifiedUsers;
	my @newUsers;

	if ( $role eq 'teacher' ) {
		$allocationList = shift;
	}
	
	$users = normalizeUsersAdb( $users, $role, $allocationList );
	
	my $removedUsers=getAllUsersByRoleAdb($role,$year);
			
	my $insertOrder=getUserOrderAdb();
	
	
	foreach my $user ( @{$users} ) {
		#set sync status
		$user->{sync}=1;
		#set insertion order
		$user->{insertOrder}=$insertOrder;
		addUserAdb( $user, $role ,'automatic');
		extract_by {$_->{userIdNumber}==$user->{userIdNumber}} @{$removedUsers};
		if ($user->{modified}){push(@modifiedUsers,$user);}
		if ($user->{pristine}){push(@newUsers,$user);}
	}
	#deactivate  user accounts
	my $currentYear=getCurrentYearAdb();
	foreach my $oldUser (@{$removedUsers}){
		$oldUser->{year}=$currentYear;
		$oldUser=deactivateUserAdb($oldUser,$role);
	}
	
return {'newusers'=>\@newUsers,"removedusers"=>$removedUsers,"modifiedusers"=>\@modifiedUsers,"status"=>1};
}

1;

