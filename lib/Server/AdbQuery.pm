package Server::AdbQuery;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );

use Server::Configuration qw($server $adb);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(doUserExistAdb doAccountExistAdb doClassExistAdb syncUsersAdb syncClassAdb);
  

#open user account database connections
my $adbDbh = DBI->connect( "dbi:mysql:$adb->{'database'}:$adb->{'fqdn'}:3306",
	$adb->{'user'}, $adb->{'password'} )
  or die "Can’t connect to Administrative data base\n";
  
  
  sub doUserExistAdb{
  	my $userId=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM user WHERE userIdNumber=$userId";
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 } 
  
 sub doAccountExistAdb{
 	my $userId=shift;
 	my $accountType=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM account WHERE userIdNumber=$userId AND type=\'$accountType\'";
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 }
 
 
 sub doUsernameExistAdb{
 	my $username=shift;
 	my $query="SELECT DISTINCT COUNT(username) FROM account WHERE username=\'$username\'";
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 }
 
  
  
 sub doUserClassExistAdb{
 	my $userId=shift;
 	my $schoolYear=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM attends WHERE userIdNumber=$userId AND year=$schoolYear";
    my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];	
  }
 
  
 sub doClassExistAdb{
 	my $classId=shift;
 	my $meccanographic=shift;
 	my $query="SELECT COUNT(classId) FROM class WHERE classId=\'$classId\' AND meccanographic=\'$meccanographic\'";
    my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 }
  
 
 sub addAccountAdb{
 	my $userIdNumber=shift;
 	my $userName=shift;	
 	my $type=shift;
 	
 	if (doAccountExistAdb($userIdNumber,$type)){
 		print "$userName $userIdNumber has already an account of type $type\n ";
 	}else{
 		my $userName=sanitizeUsername($userName);
 		my $userNameCount=doUsernameExistAdb($userName);
 		if($userNameCount>0) {$userName=$userName.$userNameCount;}
 		print "Adding account $userName\n";
 		my $query="INSERT INTO account (username,activity,type,userIdNumber) VALUES (\'$userName\',false,\'$type\',\'$userIdNumber\')";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	}
  }
 
   
 sub addUserAdb{
 	my $user=shift;
   	my $userId=$user->[0];
 	my $userName=ucfirst(sanitizeString(lc($user->[1])));
 	my $userSurname=ucfirst(sanitizeString(lc($user->[2])));	
 	
 	if (doUserExistAdb( $userId ) ){
 			print " $userId $userName $userSurname user already inserted \n";
 			addUserClassAdb($user);
 			#Update Samba 4 account ou
 			
 	}else{
 			my $query="INSERT INTO user (userIdNumber,name,surname) VALUES ($userId,\'$userName\',\'$userSurname\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 			addAccountAdb($userId,$userSurname.$userName,'Samba4');
 			addUserClassAdb($user);
 			#Create samba4 account into correct ou
 		}
  	return 1;
 }
 

 sub addUserClassAdb{
 	my $userId=$_[0]->[0];
 	my $classYear=$_[0]->[4];
 	my $classLabel=$_[0]->[5];
 	my $classId=$classYear.$classLabel;
 	my $schoolYear=$_[0]->[7];

 	if (doUserClassExistAdb($userId,$schoolYear)){
 		print "User map already exists\n";
 	}else{
 		my $query="INSERT INTO attends (userIdNumber,classId,year) VALUES ($userId,\'$classId\',$schoolYear)";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	
 }
 
 
 sub addClassAdb{
 	my $chronologicalYear=$_[0]->[0];
 	my $classLabel=lc($_[0]->[1]);
 	my $meccanographic=$_[0]->[2];
 	if (doClassExistAdb($chronologicalYear.$classLabel,$meccanographic) ){
 		print "Class $chronologicalYear$classLabel,$meccanographic already inserted\n";
 	}else{
 		my $query="INSERT INTO class (classId,classDescription,classOu,classCapacity,meccanographic) 
 				VALUES (\'$chronologicalYear$classLabel'\,'Class Description',\'ou=$chronologicalYear$classLabel\',30,\'$meccanographic\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 	}
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
  