package Server::AdbQuery;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );

use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(doUserExistAdb doAccountExistAdb doClassExistAdb syncUsersAdb syncClassAdb);
  

#open user account database connections
my $adbDbh = DBI->connect( "dbi:mysql:$adb->{'database'}:$adb->{'fqdn'}:3306",
	$adb->{'user'}, $adb->{'password'} )
  or die "Can’t connect to Administrative data base\n";
   
  
 sub executeAdbQuery{
 	my $query=shift;
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 } 
  
 sub doUserExistAdb{
  	my $userId=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM user WHERE userIdNumber=$userId";
 	return executeAdbQuery($query);
 	 } 
  
 sub doAccountExistAdb{
 	my $userId=shift;
 	my $accountType=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM account WHERE userIdNumber=$userId AND type=\'$accountType\'";
 	return executeAdbQuery($query);
 }
 
 
 sub doUsernameExistAdb{
 	my $username=shift;
 	my $query="SELECT DISTINCT COUNT(username) FROM account WHERE username=\'$username\'";
 	return executeAdbQuery($query);
 }
  
  
 sub doUserClassExistAdb{
 	my $userId=shift;
 	my $schoolYear=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM studentAllocation WHERE userIdNumber=$userId AND year=(SELECT year FROM schoolYear WHERE current=true)";
    return executeAdbQuery($query);
  }
   
 sub doClassExistAdb{
 	my $classId=shift;
 	my $meccanographic=shift;
 	my $query="SELECT COUNT(classId) FROM class WHERE classId=\'$classId\' AND meccanographic=\'$meccanographic\'";
    return executeAdbQuery($query);
 }
  
 sub addAccountAdb{
 	my $user=shift;
 	my $type=shift;
 	
 	if (doAccountExistAdb($user->{userIdNumber},$type)){
 		print "$user->{name} $user->{userIdNumber} has already an account of type $type\n ";
 	}else{
 		$user->{username}=sanitizeUsername($user->{surname}.$user->{name});
 		my $userNameCount=doUsernameExistAdb($user->{username});
 		if($userNameCount>0) {$user->{username}=$user->{username}.$userNameCount;}
 		print "Adding account $user->{username}\n";
 		my $query="INSERT INTO account (username,active,type,userIdNumber) VALUES (\'$user->{username}\',false,\'$type\',\'$user->{userIdNumber}\')";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 		
 	}
  }


sub normalizeUserAdb{
	my $user=shift;
	$user->{name}=ucfirst(sanitizeString(lc($user->{name})));
	$user->{surname}=ucfirst(sanitizeString(lc($user->{surname})));
	return $user;
} 

sub normalizeClassAdb{
	my $class=shift;
	$class->{classLabel}=lc($class->{classLabel});
	$class->{classId}=$class->{classNumber}.$class->{classLabel};
	$class->{ou}="ou=$class->{classId}";
	
}

 
sub addUserAdb{
 	my $user=shift;
 	my $role=shift;
   	
 	if (doUserExistAdb( $user->{userIdNumber} ) ){
 			print " $user->{userIdNumber} $user->{name} $user->{surname} user already inserted \n";
 			
 			addUserClassAdb($user);
 			#Update Samba 4 account ou
 			
 	}else{
 			my $query="INSERT INTO user (userIdNumber,name,surname,role) VALUES ($user->{userIdNumber},\'$user->{name}\',\'$user->{surname}\',\'$role\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 			addAccountAdb($user,$role);
 			addUserClassAdb($user);
 			#Create samba4 account into correct ou
 		}
  	return 1;
 }
 


 sub addUserClassAdb{
 	my $user=shift;
 	my $class=shift;

 	if (doUserClassExistAdb($user->{userIdNumber},$user->{year} )){
 		print "User map already exists\n";
 	}else{
 		my $query="INSERT INTO studentAllocation (userIdNumber,classId,year) VALUES ($user->{userIdNumber},\'$class->{classId}\',$user->{year})";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	
 }
 
 
 
 sub addClassAdb{
 	
 	my $class=shift;
  	
 	if (doClassExistAdb($class->{classId},$class->{meccanographic}) ){
 		print "Class $class->{classId},$class->{meccanographic} already inserted\n";
 	}else{
 		my $query="INSERT INTO class (classId,classDescription,classOu,classCapacity,meccanographic) 
 				VALUES (\'$class->{classId}'\,'Class Description',\'$class->{ou}\',30,\'$class->{meccanographic}\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 	}
 }
 
 
 sub setDefaultPolicyAdb{
 	my $account=shift;
 	my $role=shift;
 	if (doAccountExist($account->{userIdNumber},$account->{type} )){
 		my $query="INSERT INTO assignedPolicy (userIdNumber,type,policyId) VALUES ($account->{userIdNumber},$account->{type},$ldap->{default_policy}->{$role})";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 		return 1; 		
 	}else{
 		return 0;
 	}
 	
 }
 
 
 
sub getPolicyAdb{
 	
 }
 
 
 sub addSchoolAdb{
 	
 	
 }
 
 
 sub syncClassAdb{
 	#my $classes=getCurrentClassAis();
 	my $classes=shift;
 	foreach my $class (@{$classes}){
 		addClassAdb($class);
 	}
 	
 } 
   
 sub syncUsersAdb{
 	#my $users=getCurrentStudentsAis();
 	my $users=shift;
 	foreach my $user (@{$users}){
 		addUserAdb($user);
  	}
 	
 }
 
  1; 
  