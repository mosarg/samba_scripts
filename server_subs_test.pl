#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString today);
use Net::LDAP;


use Data::Dumper;
use HTML::Tabulate qw(render);
#use Server::Samba4 qw(doS4UserExist getNewUid posixifyUser addS4User getNewGid posixifyGroup setS4PrimaryGroup getGid getRid getS4UnixHomeDir deleteS4User getGroupCard addS4Group setS4GroupMembership);
use Server::LdapQuery qw(doOuExist);
use Server::AdbOu qw(getAllOuAdb);


use Server::Actions qw(cleanupDir cleanupOldProfiles);



my $user={uName=>'chtulu5',password=>'Samback@999',name=>'Test',surname=>'Test',ou=>'ou=liceo,ou=Users',idNumber=>'78999',meccanographic=>'USSP999999'};
my $extraGroups=['lavoro1','lavoro2'];

#if(doOuExist('idtc','ou=Users') ){
#	print "Ok\n";
#}

#print Dumper getAllOuAdb('samba4');

my $homeDir="ou=liceo";
$homeDir=~s/ou=//g;
$homeDir=(reverse(split(',',$homeDir)))[0];
print $homeDir;

print today();

#addS4Group('lavoro2');

#setS4GroupMembership('chtulu2',$extraGroups);

#deleteS4User('chtulu3');


#print getS4UnixHomeDir('chtulu2');

#print getGid('scuola');

#setS4PrimaryGroup($user,'scuola');

#print getGroupCard('bind');

#addS4User($user,'scuola',$extraGroups );

#posixifyGroup('lavoro',getNewGid('lavoro'));

#print getNewUid('zuzu');

#posixifyUser("cn=pippo,ou=liceo,ou=Users",getNewUid('pippo'),20513,'\home\pippo');

#addS4User('test12', 'Samback@999', 'Matteo','Mosangini','ou=liceo,ou=Users',10000,'UDSP00009');

#if(doS4UserExist('zuzu')){print "cane\n";}else{ print "gatto\n";}

#print sanitizeString('a\' a');
#syncUsersAdb();
#syncClassAdb();
#print getFreeDiskSpace('/home');

#print Dumper @{getUsersDiskProfiles()};

#cleanupOldProfiles();

#print getUserFromHumanName('','grillo');

#print getUserHome(getUserFromHumanName('deborah','grillo'));

#use Server::Mail qw(countMessages getNewMessages dumpNewMessages);
#print Dumper getUsers;
#cleanupDir('/tmp/test');
#print Dumper $ldap;
#print Dumper getGroupMembers('professori');
#print getUserFromUid(1000);
#print Dumper getClassHomes('2005bl','liceo');


#print  getUserHome('zuzu');

#print Dumper getCurrentStudentsAis();

#if (doClassExistAdb('1AL')) {
#	print "ip";
#}else{
#	print "op";
#}




#print getUserFromUid(3000020);

#print Dumper getGroupMembers('scuola');

#cleanupPublicFolders();
#cleanupDustbins();
#getNewMessages('=Inbox');
#print dumpNewMessages('global_mail_folder','Inbox');
#unbindLdap;