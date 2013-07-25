package Server::AdbAccount;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema getCurrentYearAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(addAccountAdb getAccountAdb getAccountGroupsAdb getAccountMainGroupAdb  getAccountsAdb );



 
 
#sub addAccountAdb{
# 	my $user=shift;
# 	my $type=shift;
# 	my $account={};
# 	$account->{pristine}=1;
# 	if (doAccountExistAdb($user->{userIdNumber},$type)){
# 		$account->{pristine}=0;
# 		return $account;
# 	}else{
# 		$user->{username}=sanitizeUsername($user->{surname}.$user->{name});
# 		my $userNameCount=doUsernameExistAdb($user->{username});
# 		if($userNameCount>0) {$user->{username}=$user->{username}.$userNameCount;}
# 		
# 		$account->{username}=$user->{username};
# 		$account->{active}='false';
# 		$account->{type}=$type;
# 		$account->{userIdNumber}=$user->{userIdNumber};
#
#
# 		my $query="INSERT INTO account (username,active,type,userIdNumber) VALUES (\'$account->{username}\',$account->{active},\'$account->{type}\',\'$account->{userIdNumber}\')";
# 		my $queryH=$adbDbh->prepare($query);
# 		$queryH->execute();
# 		
# 	}
# 	return $account;
#  }



#ok orm ready
sub getAccountGroupsAdb{
	my $account=shift;
	my $kind=shift;
	my @groups=$schema->resultset('GroupGroup')->search({username=>$account->username,kind=>$kind},
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



#ok orm ready
sub getAccountAdb{
	my $user=shift;
	my $account=$user->account_accounts({kind=>'samba4'},{prefetch=>'backend_id'})->next;
	return $account;
} 
 
  
sub getAccountMainGroupAdb{
	my $account=shift;
	my $backend=shift;
	my $currentYear=getCurrentYearAdb();
	my $allocation=$account->user_id->allocation_allocations({yearId_id=>$currentYear->school_year_id})->next;
	
	my $profile=$schema->resultset('ConfigurationProfile')->search({backendId_id=>$backend->backend_id,role_id=>$allocation->role_id_id})->next;
	
	return $profile->main_group;
		
	
#	my $query="SELECT DISTINCT groupName FROM user 
#			   INNER JOIN account USING(userIdNumber) 
#			   INNER JOIN role USING(role) 
#			   INNER JOIN `group` ON(role.mainGroup=`group`.groupId) 
#			   WHERE username=\'$userName\'";
#	return executeAdbQuery($query);		   

}
  
  