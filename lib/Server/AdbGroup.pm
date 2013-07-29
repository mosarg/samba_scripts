package Server::AdbGroup;	

use strict;
use warnings;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema creationTimeStampsAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);

use feature "switch";
use Try::Tiny;

require Exporter;



our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAllGroupsAdb addGroupAdb);



sub getAllGroupsAdb{
	my $type=shift;
	
	my $backend=$schema->resultset('BackendBackend')->search({kind=>$type});
	return $schema->resultset('GroupGroup')->search( {backendId_id=>$backend->next->backend_id}, {prefetch=>{'group_grouppolicies'=>'policy_id'} });
}

sub addGroupAdb{
	my $groupName=shift;
	my $groupDescription=shift;
	
	my $group=try{
		my $group=$schema->resultset('GroupGroup')->create(creationTimeStampsAdb({name=>$groupName,description=>$groupDescription}));
		return $group;
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



