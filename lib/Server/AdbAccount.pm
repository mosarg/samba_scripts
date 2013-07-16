package Server::AdbAccount;

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
our @EXPORT_OK = qw(addAccountAdb doAccountExistAdb getAccountAdb getAccountGroupsAdb getAccountMainGroupAdb updateAccountAdb);


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

sub getAccountGroupsAdb{
	my $userName=shift;
	my $type=shift;
	my $data=[];
	my $query="SELECT DISTINCT groupId,groupName 
				FROM account INNER JOIN assignedPolicy USING(userIdNumber) 
				INNER JOIN policy USING(policyId) 
				INNER JOIN groupPolicy USING (policyId) 
				INNER JOIN `group` using(groupId) WHERE account.type=\'$type\' AND account.username=\'$userName\'";
	my $result = $adbDbh->prepare($query);
	$result->execute();
	my $matches = $result->fetchall_arrayref({});
	foreach my $match (@{$matches}){
		push(@{$data},$match->{groupName});
	}
	return $data;
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
 
sub updateAccountAdb{
	my $account=shift;
	my $query="UPDATE account SET active=$account->{active}, backendUidNumber=$account->{backendUidNumber} WHERE userIdNumber=$account->{userIdNumber} AND type=\'$account->{type}\'";
	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
} 
  
sub getAccountMainGroupAdb{
	my $userName=shift;
	my $query="SELECT DISTINCT groupName FROM user 
			   INNER JOIN account USING(userIdNumber) 
			   INNER JOIN role USING(role) 
			   INNER JOIN `group` ON(role.mainGroup=`group`.groupId) 
			   WHERE username=\'$userName\'";
	return executeAdbQuery($query);		   
}
  
  