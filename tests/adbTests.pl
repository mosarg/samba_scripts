#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Text::Capitalize;


use Text::Autoformat;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::AdbUser qw(syncUsersAdb addUserAdb deactivateUserAdb getAllUsersAdb addUserAccountsAdb getAllUsersByRoleAdb addFullUserAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis getCurrentStudentsClassSubjectAis);
use Server::AdbClass qw(syncClassAdb);
#use Server::AdbAccount qw(getAccountGroupsAdb getUserAccountTypesAdb);
use Server::AdbCommon qw($schema getCurrentYearAdb addYearAdb getActiveSchools);
use Server::AdbPolicy qw(getAllPoliciesAdb addPolicyAccountAdb setPolicyGroupAdb setDefaultPolicyAdb);
use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb );
use Server::AdbSubject qw(syncSubjectAdb);
use Server::AdbAccount qw(getAccountGroupsAdb getAccountsAdb getAccountMainGroupAdb addAccountAdb getRoleAccountTypes);
use Server::System qw(createUser createFullUser);
use Server::AdbOu qw(getUserOuAdb getAllOuAdb);



my $extraGroups=['lavoro1','lavoro2'];

sub _dumper_hook {
    $_[0] = bless {
      %{ $_[0] },
      result_source => undef,
    }, ref($_[0]);
  }
$Data::Dumper::Freezer = '_dumper_hook';

my $role=$schema->resultset('AllocationRole')->search({role=>'teacher'})->first;
my $user=$schema->resultset('SysuserSysuser')->search({sidiId=>1000265})->first;
my $class=$schema->resultset('SchoolClass')->search({name=>'4al'})->first;
my $year=getCurrentYearAdb();
my @activeSchools= map {'\''.$_->meccanographic.'\''} @{getActiveSchools()};
my $yearAdb=getCurrentYearAdb();


my $aisUser={userIdNumber=>10056,origin=>'auto',name=>'Giorgiona',surname=>'Asparagona',insertOrder=>'2',allocations=>{10056=>[{
	'classLabel' => 'ao',
    'classId' => '4ao',
    'classNumber' => '4',
    'subjectId' => 1000140,
    'userIdNumber' => 10056
}]}};

my @allocations=$class->allocation_didacticalallocations({'allocation_id.yearId_id'=>$year->school_year_id},{join=>'allocation_id',select=>['allocation_id.yearId_id','subjectId_id'],distinct=>1})->all;

my $currentMaxId=$schema->resultset('SysuserSysuser')->search({syncModel=>'manual'})->get_column('sidiId')->max();
	$currentMaxId=$currentMaxId?$currentMaxId+1:666666;

createFullUser('visitors','Ennoia','Gorletti');


	
	