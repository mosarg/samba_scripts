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
use Server::AdbUser qw(syncUsersAdb addUserAdb deactivateUserAdb getAllUsersAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis getCurrentStudentsClassSubjectAis);
use Server::AdbClass qw(syncClassAdb);
#use Server::AdbAccount qw(getAccountGroupsAdb getUserAccountTypesAdb);


use Server::AdbCommon qw($schema getCurrentYearAdb addYearAdb getActiveSchools);
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

my $data->{backend}='samba4';
init($data);

my $user=$schema->resultset('SysuserSysuser')->search({sidiId=>6280509})->next;



my @activeSchools= map {'\''.$_->meccanographic.'\''} @{getActiveSchools()};
syncUsersAdb(  getAisUsers('student',\@activeSchools),'student',2012,getCurrentStudentsClassSubjectAis(\@activeSchools) );


