package Server::System;

use DBI;
use strict;
use warnings;
use Switch;
use Term::ANSIColor;
use Getopt::Long;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist addS4Ou addS4User);
use Server::AdbOu qw(getAllOuAdb getOuByUsernameAdb getOuByUserIdAdb);
use Server::AdbAccount qw(getAccountGroupsAdb getAccountMainGroupAdb);
use Server::AdbGroup qw(getAllGroupsAdb);

require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(checkOu createOu listOu init initGroups createUser);

my $backend;

sub init{
	my $data=shift;
	$backend=$data->{backend};
}

sub checkOu {
	my $ou = shift;
	my $format = { ok => 'green', unsynced => 'red' };
	
	my $status = doOuExist($ou) ? 'ok' : 'unsynced';

	switch ($backend) {
		case 'samba4' {
			print $ou
			  . " [".colored(uc($status) , $format->{$status} ) . "]\n";
		}
	}
}

sub createOu {
	my $ou     = shift;
	my $format = { ok => 'green', unsynced => 'red','already synced'=>'yellow' };
	my $status = doOuExist($ou) ? 'ok' : 'unsynced';
	switch ($backend) {
		case 'samba4' {
			if ( $status eq 'unsynced' ) {
				$status=addS4Ou( $ou, 'user' )?'ok':'unsynced';
			}else{
				$status='already synced';
			}
		print $ou." [".colored(uc($status),$format->{$status})."]\n";
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
	my $color='green';
	my $message='[OK]';
	#Get all backend groups from adb database;
	my $groups = getAllGroupsAdb($backend);
	switch ($backend) {
		case 'samba4' {
			foreach my $group ( @{$groups} ) {
				if (!addS4Group( $group->[0] )){
					$color='red';
					$message='[Error]';
				};
			print "Inserting group $group->[0] ",colored($message,$color),"\n";
				
			}
		}
		else { print "Backend not implemented\n"; exit 1; }
	}

}


sub createUser{
	
	my $user=shift;
	
	
		
	switch($backend){
		case 'samba4' {
			#get adb groups
			my $extraGroups=getAccountGroupsAdb($user->{account}->{username},$backend);
			#get adb main group
			my $mainGroup=getAccountMainGroupAdb($user->{account}->{username});
		
			$user->{account}->{ou}=getOuByUsernameAdb($user->{account}->{username},$user->{role},$backend);
			#create user
			return addS4User($user,$mainGroup,$extraGroups);
		}
	}
}

1;