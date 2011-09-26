package Server::Query;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Net::LDAP;
use Data::Dumper;

use Data::Structure::Util qw( unbless );

use Server::Configuration qw($server $ldap $ldap_users);
require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK =
  qw(getUserFromUname getUsersDiskProfiles getUserFromHumanName getUsers getUsersHome getUserHome getClassHomes getGroupMembers getUserFromUid unbindLdap);

my $ldapConnection = Net::LDAP->new( $ldap->{'server'} )
  || print "can't connect to !: $@";

sub getUsers {

	my $dn;
	my $userObjects;
	my %current_users;
	
	foreach my $group ( @{ $ldap_users->{ou} } ) {

	$dn = "ou=$group," . $ldap->{'user_base'} . ',' . $ldap->{'dir_base'};

		$userObjects = $ldapConnection->search(
			base   => "$dn",
			scope  => 'sub',
			filter => "objectclass=posixAccount",
		);
				
		$current_users{$group}=[];
		foreach ($userObjects->entries()){
				
			push(@{$current_users{$group}},{uid=>$_->get_value('uid'),script=>$_->get_value('sambaLogonScript')||'empty' });
		}
	}
	return \%current_users;
}



sub getUserHome {
	my $user       = shift;
	
	if (!$user){ return '';}
	
	my $dn         = $ldap->{'user_base'} . ',' . $ldap->{'dir_base'};
	my $userObject = $ldapConnection->search(
		base   => "$dn",
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) (uid=$user)",
	);
	return ( $userObject->entries() )[0]->get_value('homeDirectory');
}

sub getUserLdapProfile{
	
}

sub getUsersHome {
	my $dn = $ldap->{'user_base'} . ',' . $ldap->{'dir_base'};
	my @homes;
	my $userObjects = $ldapConnection->search(
		base   => "$dn",
		scope  => 'sub',
		filter => "objectclass=posixAccount",
	);

	$userObjects->code && die $userObjects->error;
	foreach my $entry ( $userObjects->entries ) {
		push( @homes, $entry->get_value('homeDirectory') );
	}
	return \@homes;

}

sub getUsersDiskProfiles{
	
	
	my @profiles= `find $server->{'profiles_dir'}`;
	shift @profiles;
	chomp @profiles;
	
	return \@profiles;
}

sub getClassHomes {
	my $class  = shift;
	my $school = shift;
	my @homes;
	my @attrs = [ 'dn', 'homeDirectory', 'sn', 'uid' ];
	my $dn =
	    "ou=$class,ou=$school,"
	  . $ldap->{'user_base'} . ','
	  . $ldap->{'dir_base'};

	$ldapConnection->bind;
	my $userObjects = $ldapConnection->search(
		base   => "$dn",
		scope  => 'sub',
		filter => "objectclass=posixAccount"
	);

	$userObjects->code && die $userObjects->error;
	foreach my $entry ( $userObjects->entries ) {
		push( @homes, $entry->get_value('homeDirectory') );
	}
	return \@homes;
}

sub getGroupMembers {
	$ldapConnection->bind;
	my $group = shift;
	my @members;
	my $mesg = $ldapConnection->search(
		base   => $ldap->{'group_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixGroup) (cn=$group)"
	);
	$mesg->code && die $mesg->error;
	my $i = 0;
	foreach my $entry ( $mesg->entries ) {

		push( @members, $entry->get_value('memberuid') );
	}
	return \@members;
}

sub getUserFromUid {
	my $uid = shift;
	$ldapConnection->bind;
	my $data = $ldapConnection->search(
		base   => $ldap->{'user_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) (uidNumber=$uid)"
	);
	$data->code && die $data->error;
	my @output = $data->entries();
	if (@output) {
		return $output[0]->get_value('uid');
	}
	else {
		return '';
	}
}

sub getUserFromUname{
	my $uname = shift;
	$ldapConnection->bind;
	my $data = $ldapConnection->search(
		base   => $ldap->{'user_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) (uid=$uname)"
	);
	$data->code && die $data->error;
	my @output = $data->entries();
	if (@output) {
		return $output[0]->get_value('uid');
	}
	else {
		return '';
	}
}


sub getUserFromHumanName {
	my $name = shift;
	my $surname= shift;
	$ldapConnection->bind;
	my $data = $ldapConnection->search(
		base   => $ldap->{'user_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) (cn=$name $surname)"
	);
	$data->code && die $data->error;
	my @output = $data->entries();
	if (@output) {
		return $output[0]->get_value('uid');
	}
	else {
		return '';
	}
}


sub unbindLdap {
	$ldapConnection->unbind;
}

1;
