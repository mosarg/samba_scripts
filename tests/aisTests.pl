#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($schema $ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::AdbCommon qw(getCurrentYearAdb addYearAdb getActiveSchools);

use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentTeacherClassAis getCurrentYearAis getCurrentStudentsClassSubjectAis getStudyPlanSubject);





my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];


#print Dumper getCurrentTeacherClassAis(2012);



my $school=getActiveSchools();


my @schools= map {'\''.$_->meccanographic.'\''} @{getActiveSchools()};



print Dumper  getCurrentTeacherClassAis(2013);

