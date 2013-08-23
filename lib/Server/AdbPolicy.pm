package Server::AdbPolicy;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw(creationTimeStampsAdb);
use Server::Configuration qw($schema $server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);

use Try::Tiny;
require Exporter;
use feature "switch";

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(setDefaultPolicyAdb addPolicyAccountAdb getAllPoliciesAdb setPolicyGroupAdb);



#ok orm ready

sub addPolicyAccountAdb{
	my $account=shift;
	my $policy=shift;
		
	my $success=try{
		$policy=$account->create_related('account_assignedpolicies',creationTimeStampsAdb( {policyId_id=>$policy->policy_id} ));
		return 1;
	}catch {
		when (/Can't call method/){
			return 0;
		}
		when ( /Duplicate entry/ ){
			return 2;		
		}
		default {die $_}
	};
		
}


#Ok orm ready
sub getAllPoliciesAdb{
	my $backend=shift;
	my @result=$schema->resultset('AccountPolicy')->search({kind=>$backend},{prefetch=>'backend_id'})->all;
	return \@result;
}

#Ok orm ready
sub setPolicyGroupAdb{
	my $group=shift;
	my $policy=shift;
	my $success=try {
		$group->create_related('group_grouppolicies',creationTimeStampsAdb({policyId_id=>$policy->policy_id} ));
		return 1;
	}catch{
		when (/Can't call method/){
		
			return 0;
		}
		when ( /Duplicate entry/ ){
			
			return 2;		
		}
		default {
			
			die $_}
	};
}

#Ok orm ready
 sub setDefaultPolicyAdb{
 	my $account=shift;
 	my $backend=shift;
 	my $role=shift;
 	my $defaultProfile=$schema->resultset('ConfigurationProfile')->search({role_id=>$role->role_id,backendId_id=>$backend->backend_id})->next;
 	
 	my $policy=$schema->resultset('AccountPolicy')->search({policyId=>$defaultProfile->default_policy_id});
 		
 	if ($policy->count>0){
 		return addPolicyAccountAdb($account,$policy->first);
 	 			
 	}else{
 		return 0;
 	}
  }

return 1;