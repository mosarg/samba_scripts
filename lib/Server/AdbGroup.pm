 package Server::AdbGroup;	

use strict;
use warnings;
use experimental 'switch';
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw(creationTimeStampsAdb);
use Server::Configuration qw($schema $server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);

use feature "switch";
use Try::Tiny;

require Exporter;



our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAllGroupsAdb addGroupAdb);



sub getAllGroupsAdb{
	my $type=shift;
	
	my $backend=$schema->resultset('BackendBackend')->search({kind=>$type})->next;
	
	my $currentBackend=$backend->kind;
	
	for($currentBackend){
		
	when(/samba4/){
		my $result;
		$result->{automatic}=$schema->resultset('SchoolSchool');
		$result->{userdef}=$schema->resultset('GroupGroup')->search( {backendId_id=>$backend->backend_id}, {prefetch=>{'group_grouppolicies'=>'policy_id'} });
		return $result;
	}
	when(/moodle/){
		my $result;
		$result->{classes}=$schema->resultset('SchoolClass');
		$result->{groups}=$schema->resultset('GroupGroup')->search( {backendId_id=>$backend->backend_id}, {prefetch=>{'group_grouppolicies'=>'policy_id'} });
		$result->{schools}=$schema->resultset('SchoolSchool');
		return $result;
		}
	}
	
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



