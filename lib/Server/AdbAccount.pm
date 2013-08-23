package Server::AdbAccount;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw(getCurrentYearAdb creationTimeStampsAdb);
use Server::Configuration qw($schema $server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
use feature "switch";
use Try::Tiny;

require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(addAccountAdb getAccountAdb getAccountGroupsAdb getAccountMainGroupAdb  getAccountsAdb getRoleAccountTypes );
 
#ok orm ready

sub addAccountAdb{
 	my $user=shift;
 	my $backend=shift;
 	my $result={pristine=>1};
 	try{
 		my $username=sanitizeUsername($user->name.$user->surname);
 		#check for username uniqueness
 		my $usernameCount=$schema->resultset('AccountAccount')->search({username=>{like=>"$username%"},backendId_id=>$backend->backend_id },{columns=>[qw/username/],distinct=>1})->count;
 		$username=$usernameCount?$username.$usernameCount:$username;
 		my $account=$user->create_related('account_accounts',creationTimeStampsAdb({username=>$username,active=>'false',backendId_id=>$backend->backend_id}));
 		return 1;		
 	}catch{
 		when (/Can't call method/){
 			return 0;
		}
		when ( /Duplicate entry/ ){
			return 2;		
		}
		default {die $_}
 	};

  }



#ok orm ready
sub getAccountGroupsAdb{
	my $account=shift;
	my $backend=shift;
	my $backendType=$backend->kind;
	
	my @groups=$schema->resultset('GroupGroup')->search({username=>$account->username,kind=>$backendType},
						{prefetch=>{'group_grouppolicies'=>[
															{'policy_id'=>'backend_id'},
															{'policy_id'=>{'account_assignedpolicies'=>'account_id'}  }]  } } )->all;
	return \@groups;
}

#ok Orm ready
sub getAccountsAdb{
	my $user=shift;
	my @accounts=$user->account_accounts->all;
	return \@accounts;
}


sub getRoleAccountTypes{
	my $role=shift;
	my @roleProfiles=$schema->resultset('ConfigurationProfile')->search({role_id=>$role->role_id})->all;
	return \@roleProfiles;
}



#ok orm ready
sub getAccountAdb{
	my $user=shift;
	my $backend=shift;
	my $account=$user->account_accounts({kind=>$backend->kind},{prefetch=>'backend_id'})->next;
	return $account;
} 
 

#ok orm ready  
sub getAccountMainGroupAdb{
	my $account=shift;
	my $backend=shift;
	my $currentYear=getCurrentYearAdb();
	my $allocation=$account->user_id->allocation_allocations({yearId_id=>$currentYear->school_year_id})->next;
	my $profile=$schema->resultset('ConfigurationProfile')->search({backendId_id=>$backend->backend_id,role_id=>$allocation->role_id_id})->next;
	return $profile->main_group;
}

return 1;
  