#!/usr/bin/perl

use strict;
use warnings;
use Server::Configuration qw($ldap);

use Net::LDAP;
use Data::Dumper;
use HTML::Tabulate qw(render);
use Server::Query qw(   getUsers getUserFromHumanName getUserHome);


use Server::Actions qw(cleanupDir);

print getUserFromHumanName('deborah','grillo');

print getUserHome(getUserFromHumanName('deborah','grillo'));

#use Server::Mail qw(countMessages getNewMessages dumpNewMessages);
#print Dumper getUsers;
#cleanupDir('/tmp/test');
#print Dumper $ldap;
#print Dumper getGroupMembers('professori');
#print getUserFromUid(1000);
#print Dumper getClassHomes('2005bl','liceo');
#print  Dumper getUsersHome();
#cleanupPublicFolders();
#cleanupDustbins();
#getNewMessages('=Inbox');
#print dumpNewMessages('global_mail_folder','Inbox');
#unbindLdap;