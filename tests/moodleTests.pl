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
use Server::Moodle qw(doMoodleUserExist addMoodleOuElement getMoodleOuId addMoodleOu doMoodleOuExist addMoodleUser getUserCohorts);



my $user={name=>'Matteo',surname=>'Mosangini',account=>{username=>'mosas',password=>'Samv@dfdf'}};



addMoodleUser($user,['1acr','1als','1apar','1apsc','1ate']);






#print doMoodleUserExist($user);
#print addMoodleOuElement('cosa');



#print Dumper getMoodleOuId('liceo');

#print addMoodleOu('1acr,ipsia');


#print doMoodleOuExist('3al,liceo');


