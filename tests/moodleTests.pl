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
use Server::System qw(createUser);
use Server::Moodle qw(doMoodleUserExist addMoodleOuElement getMoodleOuId addMoodleOu doMoodleOuExist addMoodleUser getUserCohorts addMoodleCourse defaultEnrol);

my $moosh = "moosh --moodle-path /var/www/moodle";

my $user={name=>'Mattia',surname=>'Bassi',account=>{username=>'mattiabassi',password=>'Samv@dfdf'}};
my $groups=['1acr','studenti'];
my $course={categoryid=>10,fullname=>'Matematica e fisica',description=>'tatata tata bla bla',idnumber=>1022,shortname=>'matefis3a4',id=>13};



addMoodleUser($user,$groups);



