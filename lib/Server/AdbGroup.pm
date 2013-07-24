package Server::AdbGroup;	

use strict;
use warnings;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;



our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAllGroupsAdb);




sub getAllGroupsAdb{
	#my $type=shift;
	#my $query="SELECT DISTINCT groupname FROM policy INNER  JOIN groupPolicy USING(policyId) INNER JOIN `group` g USING(groupId) WHERE type=\"$type\"";
	return $schema->resultset('GroupGroup')->search({name=>'ata'},{prefetch=>['group_grouppolicies']});

#	my $result = $adbDbh->prepare($query);
#	$result->execute();
#	my $matches = $result->fetchall_arrayref();
#	return $matches;
}

#sub getGroupIdAdb{
#	my $groupName=shift;
#	my $query="SELECT DISTINCT groupId FROM `group` WHERE groupName=\'$groupName\'";
#	return executeAdbQuery($query);
#}
#
#sub doGroupExistAdb{
#	my $groupName=shift;
#	my $query="SELECT COUNT(groupId) FROM `group` WHERE groupName=\'$groupName\'";
#	return executeAdbQuery($query);
#}
#
sub addGroupAdb{
	my $groupName=shift;
	my $groupDescription=shift;

#	my $query="INSERT INTO `group` (groupName,groupDescription) VALUES (\'$groupName\',\'$groupDescription\')";
	my $resultSet=$schema->resultset('GroupGroup')->search({name=>$groupName});
	if (!$resultSet->next){
		my $newGroup=$schema->resultset('GroupGroup')->create({name=>$groupName,description=>$groupDescription});
	}

#	if (doGroupExistAdb($groupName) ){print "Group already exists!"; return 0;
#		}else{
#		my $queryH=$adbDbh->prepare($query);
# 		$queryH->execute();
#	}
#	return getGroupIdAdb($groupName);
}



