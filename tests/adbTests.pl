#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
#use Server::AdbUser qw(syncUsersAdb syncUsersAdb);
use Server::AisQuery qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis);
#use Server::AdbClass qw(syncClassAdb);
#use Server::AdbAccount qw(getAccountGroupsAdb getUserAccountTypesAdb);

use Server::AdbGroup qw(getAllGroupsAdb addGroupAdb);
use Server::AdbSubject qw(syncSubjectAdb);


my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];




sub _dumper_hook {
    $_[0] = bless {
      %{ $_[0] },
      result_source => undef,
    }, ref($_[0]);
  }
  local $Data::Dumper::Freezer = '_dumper_hook';
  
 



print addGroupAdb('pensionati2','gruppo dei pensionati');


my $data=getAllGroupsAdb('samba4');



while (my $group=$data->next){
	print $group->name,"\n";	
}






#print Dumper getUserAccountTypesAdb({userIdNumber=>6632872});

#print Dumper getAccountGroupsAdb('troianipie','samba4');


#print syncClassAdb(getCurrentClassAis());

#print Dumper getCurrentSubjectAis();



#print Dumper syncSubjectAdb(getCurrentSubjectAis());


#print Dumper getAccountAdb(617143,'samba4');


#syncClassAdb(normalizeClassesAdb(getCurrentClassAis()));


#print Dumper getCurrentTeacherClassAis(2012);
 
#print Dumper getAisUsers('teacher');

#syncUsersAdb(getAisUsers('teacher'),'teacher',getCurrentTeacherClassAis(2012));

#syncUsersAdb(getAisUsers('student'),'student');

#syncUsersAdb(getAisUsers('ata'),'ata');

#print Dumper normalizeClassesAdb(getCurrentClassAis());

#normalizeUsersAdb(getCurrentStudentsAis());