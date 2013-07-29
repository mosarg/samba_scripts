#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::AdbUser qw(syncUsersAdb addUserAdb deactivateUserAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis getCurrentStudentsClassSubjectAis);
use Server::AdbClass qw(syncClassAdb);
#use Server::AdbAccount qw(getAccountGroupsAdb getUserAccountTypesAdb);


use Server::AdbCommon qw($schema getCurrentYearAdb);
use Server::AdbPolicy qw(getAllPoliciesAdb addPolicyAccountAdb setPolicyGroupAdb setDefaultPolicyAdb);
use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb );
use Server::AdbSubject qw(syncSubjectAdb);
use Server::AdbAccount qw(getAccountGroupsAdb getAccountsAdb getAccountMainGroupAdb addAccountAdb);
use Server::System qw(createUser init);

#use Server::AdbOu qw(getOuByUsernameAdb);

#my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];





sub _dumper_hook {
    $_[0] = bless {
      %{ $_[0] },
      result_source => undef,
    }, ref($_[0]);
  }
$Data::Dumper::Freezer = '_dumper_hook';

my $role=$schema->resultset('AllocationRole')->search({role=>'student'})->first;

my $aisUser={userIdNumber=>10056,origin=>'auto',name=>'Giorgiona',surname=>'Asparagona',insertOrder=>'2',allocations=>{10056=>[{
	'classLabel' => 'ao',
    'classId' => '4ao',
    'classNumber' => '4',
    'subjectId' => 1000140,
    'userIdNumber' => 10056
}]}};


#addUserAdb($aisUser,$role);

#my @result=$schema->resultset('SysuserSysuser')->search({roleId_id=>$role->role_id,yearId_id=>$year->school_year_id},{join=>'allocation_allocations'})->all;

#syncSubjectAdb(getCurrentSubjectAis());
#syncClassAdb(getCurrentClassAis());

syncUsersAdb(getAisUsers('student'),'student',2012,getCurrentStudentsClassSubjectAis());



#
#my $backend=$schema->resultset('BackendBackend')->search({kind=>'samba4'})->next;
#
#my $account=$user->account_accounts({backendId_id=>$backend->backend_id})->next;
#



#deactivateUserAdb($user);


#my $school=$schema->resultset('SchoolSchool')->search({meccanographic=>'UDPS011015'})->next;

#print "School name ".$school->name,"\n";
  
#my $account=$schema->resultset('AccountAccount')->search({username=>'carlgonz'})->next; 
#
#my $currentYear=getCurrentYearAdb();
#

#print $role->role;
#my $year=getCurrentYearAdb();


#


#my @data=$schema->resultset('SysuserSysuser')->search({roleId_id=>$role->role_id,yearId_id=>$year->school_year_id},{join=>'allocation_allocations'})->all;

#foreach my $tet (@data){
#	print $tet->name,"\n";
#}

#print $schema->resultset('SysuserSysuser')->count;
#print $schema->resultset('SysuserSysuser')->get_column('insertOrder')->max+1;


#my $allocation=$user->allocation_allocations({yearId_id=>$currentYear->school_year_id})->first;



#my $handle=$allocation->allocation_didacticalallocations( {aggregate=>0},{ {columns=>[qw(/name/)],group_by=>[qw(/name/)]} , {prefetch=>'class_id'} });                   

##my $allocationHandle=$allocation->allocation_didacticalallocations( {aggregate=>0},{join=>[qw(class_id)], select=>['class_id.name'],distinct=>1 } );
#my $allocationHandle2=$allocation->allocation_didacticalallocations( {aggregate=>0},{join=>{'class_id'=>'school_id'}, select=>['class_id.name','class_id.schoolId_id'],distinct=>1 } );
#
##print $handle->count;
#print $allocationHandle2->count;
#
#my $class= $allocationHandle2->first->class_id;
#
#print $class->school_id->name;


#print $allocationHandle->first->class_id->school_id;

#print $allocationHandle->first->class_id->name;
#print $handle->first->class_id->school_id->ou;
#my $ou=getOuByUsernameAdb($user);


#print Dumper join(',',map{'ou='.$_} @{$ou});




#my $username='carlgonz';
#my $count=$schema->resultset('AccountAccount')->search({username=>{like=>"$username%"} },{columns=>[qw/username/],distinct=>1})->count;

#print $count;

#print addAccountAdb($user,$backend);


# print $main_group->name;
 
#my $s4_account= $user->account_accounts({kind=>'samba4'},{prefetch=>'backend_id'})->next;

#print $s4_account->backend_id->kind,"\n";



#my $query="SELECT DISTINCT groupId,groupName 
#				FROM account INNER JOIN assignedPolicy USING(userIdNumber) 
#				INNER JOIN policy USING(policyId) 
#				INNER JOIN groupPolicy USING (policyId) 
#				INNER JOIN `group` using(groupId) WHERE account.type=\'$type\' AND account.username=\'$userName\'";


#my $groups=$schema->resultset('GroupGroup')->search({username=>$account->username,kind=>'samba4'},
#						{prefetch=>{'group_grouppolicies'=>[
#															{'policy_id'=>'backend_id'},
#															{'policy_id'=>{'account_assignedpolicies'=>'account_id'}  }]  } } );


#my $groups=getAccountGroupsAdb($account,'samba4');

#my $accounts=getAccountsAdb($user);
#
#foreach my $group (@{$accounts}){
#	print $group->username," ",$group->backend_id->kind,"\n";
#}




#print addPolicyAccountAdb($account,'baseLiceo');
#my $group=$schema->resultset('GroupGroup')->search({name=>'test2'})->next;

#print $group->name,"\n";

#print setPolicyGroupAdb($group,'prova');

#print setDefaultPolicyAdb($account,'student');

#my $policy=$schema->resultset('AccountPolicy')->search({name=>'baseLiceo',username=>'carlgonz'},{prefetch=>{'account_assignedpolicies'=>'account_id'}})->next;


#print "cane ",$policy->name,"\n";

#my $assigned=$account->account_assignedpolicies;
#
#while (my $ss=$assigned->next){
#	print $ss->policy_id->name,"\n";
#}

 
 
 

#my $data=getAllPoliciesAdb('samba4');
#
#foreach my $policy (@{getAllPoliciesAdb('samba4')} ){
#	print $policy->name,"\n";
#}




#print addGroupAdb('pensionati2','gruppo dei pensionati');


#my $data=getAllGroupsAdb('samba4');
 


#while (my $group=$data->next){
	#print $group->name,"\n";	
#}






#print Dumper getUserAccountTypesAdb({userIdNumber=>6632872});

#print Dumper getAccountGroupsAdb('troianipie','samba4');


#

#print Dumper getCurrentSubjectAis();



#


#print Dumper getAccountAdb(617143,'samba4');


#syncClassAdb(normalizeClassesAdb(getCurrentClassAis()));


#print Dumper getCurrentTeacherClassAis(2012);
 
#print Dumper getAisUsers('teacher');

#syncUsersAdb(getAisUsers('teacher'),'teacher',getCurrentTeacherClassAis(2012));

#syncUsersAdb(getAisUsers('student'),'student');

#syncUsersAdb(getAisUsers('ata'),'ata');

#print Dumper normalizeClassesAdb(getCurrentClassAis());

#normalizeUsersAdb(getCurrentStudentsAis());