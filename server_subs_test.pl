#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap $server);
use Server::Commands qw(sanitizeString);
use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::Samba4 qw(doS4UserExist getNewUid posixifyUser addS4User getNewGid posixifyGroup);
use Server::Query qw(getCurrentStudentsAis getCurrentTeachersAis getAisUsers getUserFromUid getGroupMembers 
getFreeDiskSpace getUsers getUserFromHumanName getUserHome getUsersDiskProfiles getUsersHome 
doUserExistAdb doAccountExistAdb doClassExistAdb  syncUsersAdb syncClassAdb);


use Server::Actions qw(cleanupDir cleanupOldProfiles);





posixifyGroup('lavoro',getNewGid('lavoro'));
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