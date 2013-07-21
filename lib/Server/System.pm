package Server::System;

use DBI;
use strict;
use warnings;
use Switch;
use Term::ANSIColor;
use Getopt::Long;
use PDF::Create;
use Term::Emit ":all", { -color => 1 };
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu getUserBaseDn);
use Server::Samba4
  qw(addS4Group deleteS4Group doS4GroupExist addS4Ou addS4User deleteS4User moveS4User);
use Server::AdbOu qw(getAllOuAdb getOuByUsernameAdb getOuByUserIdAdb);
use Server::AdbAccount
  qw(getAccountGroupsAdb getAccountMainGroupAdb getAccountAdb updateAccountAdb);
use Server::AdbGroup qw(getAllGroupsAdb);

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(checkOu createOu listOu init initGroups createUser removeUser moveUser recordUser);

my $backend;

sub init {
	my $data = shift;
	$backend = $data->{backend};
}

sub checkOu {
	my $ou = shift;
	emit "Ou $ou";
	doOuExist($ou) ? emit_ok : emit_info;

}

sub createOu {
	my $ou = shift;
	switch ($backend) {
		case 'samba4' {
			emit "Create ou $ou";
			if ( addS4Ou( $ou, 'user' ) ) {
				emit_ok;
			}
			else {
				doOuExist($ou) ? emit_done "PRESENT" : emit_error;
			}
		}
	}

}

sub listOu {
	my $action = shift;
	switch ($backend) {
		case 'samba4' {
			my $adbOu = getAllOuAdb('samba4');
			hashNav( $adbOu, '', $action );
		}
	}
}

sub initGroups {

	#Get all backend groups from adb database;
	my $groups = getAllGroupsAdb($backend);
	switch ($backend) {
		case 'samba4' {
			foreach my $group ( @{$groups} ) {
				emit "Inserting group $group->[0]";
				if ( addS4Group( $group->[0] ) ) {
					emit_ok;
				}
				else {
					doS4GroupExist( $group->[0] )
					  ? emit_done "PRESENT"
					  : emit_error;

				}

			}
		}
		else { print "Backend not implemented\n"; exit 1; }
	}
}

sub removeUser {
	my $user = shift;

	switch ($backend) {
		case 'samba4' {
			emit "Remove user $user->{account}->{username}";
			deleteS4User( $user->{account}->{username} ) ? emit_ok : emit_error;
		}
	}
}

sub moveUser {
	my $user = shift;
	switch ($backend) {
		case 'samba4' {

			$user->{account}->{ou} =
			  getOuByUsernameAdb( $user->{account}->{username},
				$user->{role}, $backend );
			emit
"Move user $user->{name} $user->{surname} to $user->{account}->{ou}";
			my $oldUserDn = "cn=$user->{account}->{username},"
			  . getUserBaseDn( $user->{account}->{username} );
			my $newUserDn = "cn="
			  . $user->{account}->{username} . ","
			  . $user->{account}->{ou} . ","
			  . $ldap->{user_base} . ","
			  . $ldap->{'dir_base'};
			if ( moveS4User( $user, $oldUserDn, $newUserDn ) ) {
				emit_ok;
				return 1;
			}
			else {
				emit_error;
				return 0;
			}
		}
	}
}

sub createS4User {
	my $user = shift;
	#get adb groups
	my $extraGroups =
	  getAccountGroupsAdb( $user->{account}->{username}, $backend );

	#get adb main group
	my $mainGroup = getAccountMainGroupAdb( $user->{account}->{username} );
	$user->{account}->{ou} = getOuByUsernameAdb( $user->{account}->{username},
		$user->{role}, $backend );

	#create user
	$user = addS4User( $user, $mainGroup, $extraGroups );
	updateAccountAdb( $user->{account} );
	return $user;
}

sub recordUser {
	my $users    = shift;
	my $filename = shift;
	open FHANDLE, ">$filename" or die("Cannot open $filename");
	print FHANDLE
	  "userIdNumber,name,surname,username,password,type,backendUidNumber\n";
	foreach my $user ( @{$users} ) {

		print FHANDLE "$user->{userIdNumber},\"$user->{name}\",\"$user->{surname}\",$user->{account}->{username},$user->{account}->{password},$user->{account}->{type},$user->{account}->{backendUidNumber}\n";
	}
	close FHANDLE;
return 1;
}

sub createUser {
	my $user = shift;
	#get user account
	$user->{account} = getAccountAdb( $user->{userIdNumber}, $backend );
	#get user base dn
	$user->{baseDn} = getUserBaseDn( $user->{account}->{username} );
	emit "Create account for $user->{name} $user->{surname}";
	if ( !$user->{baseDn} ) {
		switch ($backend) {
			case 'samba4' {
				$user=createS4User($user);
				$user->{creationStatus}
				  ? emit_ok
				  : emit_error;
			}
			else { emit_error; }
		}
	}
	else {
		emit_done "PRESENT";
	}
	return $user;
}

1;
