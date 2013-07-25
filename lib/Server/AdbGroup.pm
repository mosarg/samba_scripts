package Server::AdbGroup;	

use strict;
use warnings;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema creationTimeStampsAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;



our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAllGroupsAdb addGroupAdb);



sub getAllGroupsAdb{
	my $type=shift;
	
	my $backend=$schema->resultset('BackendBackend')->search({kind=>$type});
	return $schema->resultset('GroupGroup')->search( {backendId_id=>$backend->next->backend_id}, {prefetch=>{'group_grouppolicies'=>'policy_id'} }  );
}

sub addGroupAdb{
	my $groupName=shift;
	my $groupDescription=shift;
	my $resultSet=$schema->resultset('GroupGroup')->search({name=>$groupName});
	my $newGroup=$resultSet->next;
	if (!$newGroup){
		$newGroup=$schema->resultset('GroupGroup')->create(creationTimeStampsAdb({name=>$groupName,description=>$groupDescription}));
	}
	return $newGroup;
}



