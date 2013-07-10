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
our @EXPORT_OK = qw(setDefaultPolicyAdb addPolicyAdb);


 sub doAccountHasPolicyAdb{
 	my $account=shift;
 	my $policyId=shift;
  	my $query="SELECT COUNT(userIdNumber) FROM assignedPolicy WHERE userIdNumber=$account->{userIdNumber} AND type=\'$account->{type}\' AND policyId=\'$policyId\' ";
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