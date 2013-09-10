#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server $schema);
use Server::Commands qw(sanitizeString execute);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::AdbUser qw(syncUsersAdb addUserAdb deactivateUserAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis getCurrentStudentsClassSubjectAis);
use Server::AdbClass qw(syncClassAdb);
#use Server::AdbAccount qw(getAccountGroupsAdb getUserAccountTypesAdb);


use Server::AdbCommon qw(getCurrentYearAdb);
use Server::AdbPolicy qw(getAllPoliciesAdb addPolicyAccountAdb setPolicyGroupAdb setDefaultPolicyAdb);
use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb );
use Server::AdbSubject qw(syncSubjectAdb);
use Server::AdbAccount qw(getAccountGroupsAdb getAccountsAdb getAccountMainGroupAdb addAccountAdb);
use Server::System qw(createUser deleteDjangoUser);
use Server::Django qw(addDjangoUser deleteDjangoUser doDjangoUserExist changeDjangoPassword	 ) ;


my $user={account=>{username=>'alansstoneatto',password=>'cajfkjfd'},name=>'Amil5225care',surname=>'B5225endetti'};

print deleteDjangoUser('galdinopater');