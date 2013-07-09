#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);

use Server::AdbQuery qw(doUserExistAdb doAccountExistAdb doClassExistAdb  syncUsersAdb syncClassAdb normalizeClassesAdb normalizeUsersAdb getAccountAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis);






my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];


#print Dumper getAccountAdb(617143,'samba4');


#syncClassAdb(normalizeClassesAdb(getCurrentClassAis()));



syncUsersAdb(getAisUsers('ata'),'ata');



#print Dumper normalizeClassesAdb(getCurrentClassAis());

#normalizeUsersAdb(getCurrentStudentsAis());