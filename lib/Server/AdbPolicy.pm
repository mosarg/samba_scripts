package Server::AdbPolicy;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery);
use Server::AdbAccount qw(doAccountExistAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;



our @ISA = qw(Exporter);
our @EXPORT_OK = qw(setDefaultPolicyAdb addPolicyAdb getAllPoliciesAdb setPolicyGroupAdb);


 sub doAccountHasPolicyAdb{
 	my $account=shift;
 	my $policyId=shift;
  	my $query="SELECT COUNT(userIdNumber) FROM assignedPolicy WHERE userIdNumber=$account->{userIdNumber} AND type=\'$account->{type}\' AND policyId=\'$policyId\' ";
    return executeAdbQuery($query);
 }
 
 sub doPolicyHasGroupAdb{
 	my $groupId=shift;
 	my $policyId=shift;
 	my $query="SELECT COUNT(policyId) FROM groupPolicy WHERE policyId=\'$policyId\' AND groupId=\'$groupId\'";
 	return executeAdbQuery($query);
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



sub getAllPoliciesAdb{
	my $backend=shift;
	my $query="SELECT policyId,description FROM policy WHERE type=\'$backend\'";
	my $result = $adbDbh->prepare($query);
	$result->execute();
	my $matches = $result->fetchall_arrayref({});
	return $matches;
}

sub setPolicyGroupAdb{
	my $groupId=shift;
	my $policyId=shift;
	my $query="INSERT INTO groupPolicy (policyId,groupId,start) VALUES ($policyId,$groupId,localtime)";
	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
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
  
   
sub getPolicyAdb{
 	
 }