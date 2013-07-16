package Server::AdbAllocation;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(addAllocationAdb);

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
 	my $subjectId=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM teacherAllocation WHERE userIdNumber=$userId AND year=(SELECT year FROM schoolYear WHERE current=true) AND classId=\"$classId\" AND subjectId=\"$subjectId\" ";
    return executeAdbQuery($query);
 } 

 sub addStudentAllocationAdb{
 	my $user=shift;
 	
 	if (doStudentAllocationExistAdb($user->{userIdNumber},$user->{year} )){
 		print "Student map already exists\n";
 		return 0;
 	}else{
 		my $query="INSERT INTO studentAllocation (userIdNumber,classId,year) VALUES ($user->{userIdNumber},\'$user->{classId}\',$user->{year})";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 		print $query."\n";
 	} 
 	return 1;	
 }

 sub addAtaAllocationAdb{
	my $user=shift;
	if (doAtaAllocationExistAdb($user->{userIdNumber},$user->{year} )){
 		print "Ata map already exists\n";
 		return 0;
 	}else{
 		my $query="INSERT INTO ataAllocation (userIdNumber,meccanographic,year) VALUES ($user->{userIdNumber},\'$user->{meccanographic}\',$user->{year})";
 		
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	 	
 	return 1;
 }
  
 sub addTeacherAllocationAdb{
 	my $user=shift;
	
	if (!$user->{allocations}){print "No allocations defined"; return 0;}
	
	foreach my $allocation (@{$user->{allocations}}){
	
	if (doTeacherAllocationExistAdb($user->{userIdNumber},$user->{year},$allocation->{classId},$allocation->{subjectId})){
 		print "Teacher map already exists\n";
 	}else{
 				
 			my $query="INSERT INTO teacherAllocation (userIdNumber,classId, year,subjectId) VALUES ($user->{userIdNumber},\'$allocation->{classId}\',$user->{year},$allocation->{subjectId})";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 		
 		} 	 	
	}
	return 1;
}
 
 sub addAllocationAdb{
	my $user=shift;
	my $role=shift;
	if ($role eq 'student'){
 				return addStudentAllocationAdb($user);
		}
		if($role eq 'ata'){
			return addAtaAllocationAdb($user);
		}
		if($role eq 'teacher'){
				return addTeacherAllocationAdb($user);
		}
}