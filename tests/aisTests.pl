#!/usr/bin/perl
use strict;
use experimental 'switch';
use Server::Configuration qw($schema $ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
#use HTML::Tabulate qw(render);
use Server::AdbCommon qw(getCurrentYearAdb addYearAdb getActiveSchools);

use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentTeacherClassAis getCurrentYearAis getCurrentStudentsClassSubjectAis getStudyPlanSubject getCurrentStudentsAis getCurrentTeachersAis );
no if $] >= 5.018, warnings => "experimental::smartmatch";
no if $] >= 5.018, warnings => "experimental::lexical_subs";





my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];


#print Dumper getCurrentTeacherClassAis(2012);



my $school=getActiveSchools();


my @schools= map {'\''.$_->meccanographic.'\''} @{getActiveSchools()};





my @activeSchools =map { '\'' . $_->meccanographic . '\'' } @{ getActiveSchools() };


print Dumper @activeSchools;

#print Dumper getAisUsers('ata');
#print Dumper getCurrentTeacherClassAis(2013);
#print Dumper  getCurrentStudentsAis(\@schools);
print Dumper getCurrentTeachersAis(2013);