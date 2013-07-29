package Server::System;

use DBI;
use strict;
use warnings;
use Switch;
use Term::ANSIColor;
use Getopt::Long;
use PDF::Create;
use Data::Dumper;
use Term::Emit ":all", { -color => 1 };
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu getUserBaseDn);
use Server::Samba4
  qw(addS4Group deleteS4Group doS4GroupExist addS4Ou addS4User deleteS4User moveS4User);
use Server::AdbOu qw(getAllOuAdb getUserOuAdb);
use Server::AdbAccount
  qw(getAccountGroupsAdb getAccountMainGroupAdb getAccountAdb);
use Server::AdbGroup qw(getAllGroupsAdb);

use feature "switch";
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
	doOuExist($ou) ? emit_ok : emit_done "NOT PRESENT";
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
	for ($backend) {
		when (/samba4/) {
			while ( my $group = $groups->next ) {
				if ( !doS4GroupExist( $group->name ) ) {
					emit "Inserting group " . $group->name;
					my $result = addS4Group( $group->name );
					for ($result) {
						when (/1/) { emit_ok; }
						when (/0/) { emit_error; }
						when (/2/) { emit_done "PRESENT" }
					}

				}

			}
		}
	}
}

sub removeUser {
	my $user = shift;
	for ($backend) {
		when (/samba4/) {
			emit "Remove user $user->{account}->{username}";
			deleteS4User( $user->{account}->{username} ) ? emit_ok : emit_error;
		}
	}
}

sub simplifyUser {
	my $user   = shift;
	my $result = {};
	my $backend =
	  $schema->resultset('BackendBackend')->search( { kind => $backend } )
	  ->first;
	my $account = $user->account_accounts( { backendId_id => $backend->backend_id } )->first;
	my $ou = join( ',', map { 'ou=' . $_ } @{ getUserOuAdb($user) } );
	$result = {
		name    => $user->name,
		surname => $user->surname,
		account => { username => $account->username, ou => $ou },
		userIdNumber=>$user->sidi_id
	};
	return {
		simpleUser => $result,
		adbaccount => $account,
		adbbackend => $backend
	};
}

sub moveUser {
	my $user       = shift;
	my $simpleUser = simplifyUser($user)->{simpleUser};

	for ($backend) {
		when(/samba4/) {
			emit "Move user $simpleUser->{name} $simpleUser->{surname} to $simpleUser->{account}->{ou}";
			my $oldUserDn = "cn=$simpleUser->{account}->{username},"
			  . getUserBaseDn( $simpleUser->{account}->{username} );
			my $newUserDn = "cn="
			  . $simpleUser->{account}->{username} . ","
			  . $simpleUser->{account}->{ou} . ","
			  . $ldap->{user_base} . ","
			  . $ldap->{'dir_base'};
			if ( moveS4User( $simpleUser, $oldUserDn, $newUserDn ) ) {
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
	  getAccountGroupsAdb( $user->{adbaccount}, $user->{adbbackend} );

	#get adb main group
	my $mainGroup =
	  getAccountMainGroupAdb( $user->{adbaccount}, $user->{adbbackend} )->name;

	#create user

	$user->{simpleUser} =
	  addS4User( $user->{simpleUser}, $mainGroup,
		[ map { ($_)->name } @{$extraGroups} ] );
	
	$user->{adbaccount}->update(
		{
			active => 1,
			backendUidNumber =>
			  $user->{simpleUser}->{account}->{backendUidNumber}
		}
	);

	return $user;
}

sub recordUser {
	my $users    = shift;
	my $filename = shift;
	open FHANDLE, ">$filename" or die("Cannot open $filename");
	print FHANDLE " name,surname,username,password,type,backendUidNumber\n";
	foreach my $fullUser ( @{$users} ) {
		my $user=$fullUser->{simpleUser};
		print FHANDLE "\"$user->{name}\",\"$user->{surname}\",$user->{account}->{username},$user->{account}->{password},$backend,$user->{account}->{backendUidNumber}\n";
	}
	close FHANDLE;
	return 1;
}

sub createUser {
	my $user       = shift;
	my $simpleUser = simplifyUser($user);
	$simpleUser->{simpleUser}->{baseDn} =
	  getUserBaseDn( $simpleUser->{simpleUser}->{account}->{username} );

	emit "Create account for " . $user->name . " " . $user->surname;
	if ( !$simpleUser->{simpleUser}->{baseDn} ) {
		for ($backend) {
			when(/samba4/) {
				$user = createS4User($simpleUser);
				$user->{simpleUser}->{creationStatus}
				  ? emit_ok
				  : emit_error;
				  
			}
			default { emit_error; }
		}
	}
	else {
		emit_done "PRESENT";
	}
	
	return $user;
}

1;
