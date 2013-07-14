package Server::AdbOu;

use DBI;
use strict;
use warnings;
use Switch;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAllOuAdb getOuByUsernameAdb getOuByUserIdAdb);

sub getOuByUsernameAdb{
	my $userName=shift;
	my $format=shift;
	switch($format){
		case 'samba4' {
			my $query="SELECT DISTINCT username,CONCAT('ou=',classOu),CONCAT('ou=',schoolOu) FROM account 
					   INNER JOIN studentAllocation USING(userIdNumber) 
					   INNER JOIN class USING(classId) 
					   INNER JOIN school USING (meccanographic)
					   WHERE  type=\'$format\' AND year=(SELECT year FROM schoolYear WHERE current=true) AND username=\'$userName\'";
			return executeAdbQuery($query);		   
		}
		default {return 0;}
	}
	
	
}

sub getOuByUserIdAdb{
	my $userIdNumber=shift;
	my $format=shift;
	switch($format){
		case 'samba4' {
			my $query="SELECT DISTINCT username,CONCAT('ou=',classOu),CONCAT('ou=',schoolOu) FROM account 
					   INNER JOIN studentAllocation USING(userIdNumber) 
					   INNER JOIN class USING(classId) 
					   INNER JOIN school USING (meccanographic)
					   WHERE  type=\'$format\' AND year=(SELECT year FROM schoolYear WHERE current=true) AND userIdNumber=$userIdNumber";
			return executeAdbQuery($query);		   
		}
		default {return 0;}
	}
}

sub getAllOuAdb{
	my $format=shift;
	my $data=[];
	my $formattedResult={};
	my $roles=['ata','teacher'];
	my $temp;
	#get students ou
		
	switch($format){
	
	case 'samba4' {
	my $query="SELECT DISTINCT CONCAT('ou=',classOu) AS classOu,CONCAT('ou=',schoolOu) AS schoolOu FROM account 
					   INNER JOIN studentAllocation USING(userIdNumber) 
					   INNER JOIN class USING(classId) 
					   INNER JOIN school USING (meccanographic)
					   WHERE  type=\'$format\' AND year=(SELECT year FROM schoolYear WHERE current=true)";
	my $result = $adbDbh->prepare($query);
	$result->execute();
	$data=$result->fetchall_arrayref();
	$query="SELECT DISTINCT CONCAT('ou=',defaultOu) FROM role";
	$result = $adbDbh->prepare($query);
	$result->execute();
	$data=[@{$data},@{$result->fetchall_arrayref()}];
	
	
	foreach my $role (@{$roles}){
		$query="SELECT DISTINCT CONCAT('ou=',ou) FROM user INNER JOIN $role"."Allocation USING (userIdNumber) WHERE ou!='default'; ";
		$result = $adbDbh->prepare($query);
		$result->execute();
		$temp=$result->fetchall_arrayref();
		if(scalar(@{$temp})>0){
		$data=[@{$data},@{$result->fetchall_arrayref()}];
		}
	}
	}
	
	}
	foreach my $element (@{$data}){
		if(scalar(@{$element})>1){
			if (! ($formattedResult->{$element->[1]}) ){ $formattedResult->{$element->[1]}={};}
			$formattedResult->{$element->[1]}->{$element->[0]}=0;	
		}else{
			$formattedResult->{$element->[0]}=0;
		}	
		
	
	}
	return $formattedResult;
	
}

sub setDefaultOu{
	my $ou=shift;
	my $role=shift;
	switch($role){
		case 'student' {
		}
		case 'teacher'{
			
		}
		case 'ata'{
			
		}
		default {
			
		}
	}	
}
