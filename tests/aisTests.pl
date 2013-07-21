#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);

use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentTeacherClassAis getCurrentYearAis);





my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];


#print Dumper getCurrentTeacherClassAis(2012);


print getCurrentYearAis();

#print Dumper getCurrentClassAis();
#print Dumper getCurrentStudentsAis(); 
#print Dumper getCurrentTeachersAis();