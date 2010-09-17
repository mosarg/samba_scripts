#!/usr/bin/perl


#change users logon script name cmd->vbs

use strict;
use warnings;
use Server::Configuration qw($ldap);
use Data::Dumper;
use Server::Query qw(   getUsers);




my $server_users=getUsers;
my $command='';


foreach my $group (keys %{$server_users}){
	foreach my $current_user (@{$server_users->{$group}}){
		$command="smbldap-usermod --sambaLogonScript $current_user->{uid}.vbs $current_user->{uid}";
		print $command,"\n";
		system($command);
	}	
}

print Dumper getUsers;