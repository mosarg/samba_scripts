#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::AdbUser qw(syncUsersAdb syncUsersAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis);
use Server::AdbClass qw(syncClassAdb);

my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];


#syncClassAdb(getCurrentClassAis());

#syncSubjectAdb(getCurrentSubjectAis());


#print Dumper getAccountAdb(617143,'samba4');


#syncClassAdb(normalizeClassesAdb(getCurrentClassAis()));


#print Dumper getCurrentTeacherClassAis(2012);
 
#print Dumper getAisUsers('teacher');

syncUsersAdb(getAisUsers('teacher'),'teacher',getCurrentTeacherClassAis(2012));

syncUsersAdb(getAisUsers('student'),'student');

syncUsersAdb(getAisUsers('ata'),'ata');

#print Dumper normalizeClassesAdb(getCurrentClassAis());

#normalizeUsersAdb(getCurrentStudentsAis());