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
our @EXPORT_OK = qw(doUserExistAdb doAccountExistAdb doClassExistAdb syncUsersAdb syncClassAdb normalizeClassesAdb normalizeUsersAdb getAccountAdb);
  

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
  
  
 sub doStudentAllocationExistAdb{
 	my $userId=shift;
 	my $schoolYear=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM studentAllocation WHERE userIdNumber=$userId AND year=(SELECT year FROM schoolYear WHERE current=true)";
    return executeAdbQuery($query);
  }
  
 sub doAtaAllocationExistAdb{
 	my $userId=shift;
 	my $schoolYear=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM ataAllocation WHERE userIdNumber=$userId AND year=(SELECT year FROM schoolYear WHERE current=true)";
    return executeAdbQuery($query);
 } 
 
 sub doTeacherAllocationExistAdb{
 	my $userId=shift;
 	my $schoolYear=shift;
 	my $classId=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM teacherAllocation WHERE userIdNumber=$userId AND year=(SELECT year FROM schoolYear WHERE current=true) AND classId=\"$classId\" ";
    return executeAdbQuery($query);
 } 
  

   
 sub doClassExistAdb{
 	my $classId=shift;
 	my $meccanographic=shift;
 	my $query="SELECT COUNT(classId) FROM class WHERE classId=\'$classId\' AND meccanographic=\'$meccanographic\'";
    return executeAdbQuery($query);
 }
 
 
 sub doAccountHasPolicyAdb{
 	my $account=shift;
 	my $policyId=shift;
  	my $query="SELECT COUNT(userIdNumber) FROM assignedPolicy WHERE userIdNumber=$account->{userIdNumber} AND type=\'$account->{type}\' AND policyId=\'$policyId\' ";
    return executeAdbQuery($query);
 }
  
 sub addAccountAdb{
 	my $user=shift;
 	my $type=shift;
 	my $account={};
 	
 	if (doAccountExistAdb($user->{userIdNumber},$type)){
 		print "$user->{name} $user->{userIdNumber} has already an account of type $type\n ";
 	}else{
 		$user->{username}=sanitizeUsername($user->{surname}.$user->{name});
 		my $userNameCount=doUsernameExistAdb($user->{username});
 		if($userNameCount>0) {$user->{username}=$user->{username}.$userNameCount;}
 		
 		$account->{username}=$user->{username};
 		$account->{active}='false';
 		$account->{type}=$type;
 		$account->{userIdNumber}=$user->{userIdNumber};
 		
 		print "Adding account $account->{username}\n";
 		my $query="INSERT INTO account (username,active,type,userIdNumber) VALUES (\'$account->{username}\',$account->{active},\'$account->{type}\',\'$account->{userIdNumber}\')";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 		
 	}
 	return $account;
  }


sub normalizeUserAdb{
	my $user=shift;
	my $role=shift;
	$user->{name}=ucfirst(sanitizeString(lc($user->{name})));
	$user->{surname}=ucfirst(sanitizeString(lc($user->{surname})));
	
	if($role eq 'student'){
		$user=normalizeStudentAdb($user);
	}
	if($role eq 'teacher'){
		$user=normalizeTeacherAdb($user);
	}
	if($role eq 'ata'){
		$user=normalizeAtaAdb($user)
	}
		
	return $user;
} 

sub normalizeClassAdb{
	my $class=shift;
	$class->{classLabel}=lc($class->{classLabel});
	$class->{classId}=$class->{classNumber}.$class->{classLabel};
	$class->{ou}="ou=$class->{classId}";
	$class->{description}=ucfirst(lc($class->{description}));
	return $class;
}

sub normalizeStudentAdb{
	my $user=shift;
	$user->{classLabel}=lc($user->{classLabel});
	$user->{classId}=$user->{classNumber}.$user->{classLabel};	
	return $user;
}

sub normalizeAtaAdb{
	my $user=shift;
	$user->{year}=getCurrentYearAdb();
	return $user;
}

sub normalizeTeacherAdb{
	my $user=shift;
	$user->{year}=getCurrentYearAdb();
	return $user;
}



sub normalizeClassesAdb{
	my $classes=shift;
	my $index=0;
	foreach my $class (@{$classes}){
			$classes->[$index]=normalizeClassAdb($classes->[$index]);
			$index++;		
	}
	return $classes;
}


sub normalizeUsersAdb{
	my $users=shift;
	my $role=shift;
	my $index=0;
	foreach my $user (@{$users}){
			$users->[$index]=normalizeUserAdb($users->[$index],$role);
			$index++;		
	}
	return $users;
}




 
sub addUserAdb{
 	my $user=shift;
 	my $role=shift;
 	$user->{role}=$role;
   	
 	if (doUserExistAdb( $user->{userIdNumber} ) ){
 			print " $user->{userIdNumber} $user->{name} $user->{surname} user already inserted \n";
			addAllocationAdb($user,$role);
			
 			
 			#Update Samba 4 account ou
 			
 	}else{
 			my $query="INSERT INTO user (userIdNumber,name,surname,role) VALUES ($user->{userIdNumber},\'$user->{name}\',\'$user->{surname}\',\'$user->{role}\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 			my $account=addAccountAdb($user,'samba4');
 			addAllocationAdb($user,$role);	
 			setDefaultPolicyAdb($account,$user->{role});
 			#Create samba4 account into correct ou
 		}
  	return 1;
 }
 

sub addPolicyAdb{
	my $account=shift;
	my $policyId=shift;
	
	if(!(doAccountHasPolicyAdb($account,$policyId))){
		my $query="INSERT INTO assignedPolicy (userIdNumber,type,policyId,start) VALUES ($account->{userIdNumber},\'$account->{type}\',$policyId,localtime)";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
	}else{
		print "policy alread assigned!\n";
	}
 	
 	return 1; 		
	
}


 sub addStudentAllocationAdb{
 	my $user=shift;
 	
 	if (doStudentAllocationExistAdb($user->{userIdNumber},$user->{year} )){
 		print "Student map already exists\n";
 	}else{
 		my $query="INSERT INTO studentAllocation (userIdNumber,classId,year) VALUES ($user->{userIdNumber},\'$user->{classId}\',$user->{year})";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	
 }
 
 
 sub addAtaAllocationAdb{
	my $user=shift;
	if (doAtaAllocationExistAdb($user->{userIdNumber},$user->{year} )){
 		print "Ata map already exists\n";
 	}else{
 		my $query="INSERT INTO ataAllocation (userIdNumber,meccanographic,year) VALUES ($user->{userIdNumber},\'$user->{meccanographic}\',$user->{year})";
 		
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	 	
 	
 }
 
 
  
 sub addTeacherAllocationAdb{
 	my $user=shift;
	if (doTeacherAllocationExistAdb($user->{userIdNumber},$user->{year},$user->{classId} )){
 		print "Teacher map already exists\n";
 	}else{
 		my $query="INSERT INTO teacherAllocation (userIdNumber,meccanographic,year) VALUES ($user->{userIdNumber},\'$user->{classId}\',$user->{year})";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	 	
 	
 }
 
 sub addAllocationAdb{
	my $user=shift;
	my $role=shift;
	if ($role eq 'student'){
 				addStudentAllocationAdb($user);
		}
		if($role eq 'ata'){
			addAtaAllocationAdb($user);
		}
		if($role eq 'teacher'){
				addTeacherAllocationAdb($user);
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
 	if (doAccountExistAdb($account->{userIdNumber},$account->{type} )){
 	 		addPolicyAdb($account,$ldap->{default_policy}->{$role});
 	 		return 1; 		
 	}else{
 		return 0;
 	}
  }



sub getAccountAdb{
	my $userIdNumber=shift;
	my $type=shift;
	my $query="SELECT * FROM account WHERE userIdNumber=$userIdNumber AND type=\'$type\'";
	my $result = $adbDbh->prepare($query);
	$result->execute();
	my $matches = $result->fetchrow_hashref();
	return $matches;
} 

 
sub getCurrentYearAdb{
	my $query="SELECT YEAR FROM schoolYear WHERE current=true";
    return executeAdbQuery($query);
} 
 
sub getPolicyAdb{
 	
 }
 
 
 sub addSchoolAdb{
 	
 	
 }
  
 sub syncClassAdb{
 	my $classes=shift;
 	$classes=normalizeClassesAdb($classes);
 	foreach my $class (@{$classes}){
 		addClassAdb($class);
 	}
 	
 } 
   
 sub syncUsersAdb{
 	my $users=shift;
 	my $role=shift;
 	$users=normalizeUsersAdb($users,$role);
 	foreach my $user (@{$users}){
 		addUserAdb($user,$role);
  	}
 	
 }
 
  1; 
  