package Server::System;

use DBI;
use strict;
use warnings;
use Switch;
use Term::ANSIColor;
use String::MkPasswd qw(mkpasswd);
use Data::Dumper;
use Term::Emit ":all", { -color => 1 };
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema getCurrentYearAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu getUserBaseDn);
use Server::Samba4
  qw(addS4Group deleteS4Group doS4GroupExist addS4Ou addS4User deleteS4User moveS4User);
use Server::AdbOu qw(getAllOuAdb getUserOuAdb);
use Server::AdbAccount
  qw(getAccountGroupsAdb getAccountMainGroupAdb getAccountAdb getRoleAccountTypes);
use Server::AdbGroup qw(getAllGroupsAdb);
use Server::Moodle
  qw(doMoodleUserExist doMoodleGroupExist addMoodleOuElement getMoodleOuId addMoodleOu doMoodleOuExist addMoodleGroup addMoodleUser deleteMoodleUser);

use feature "switch";
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(checkOu createOu listOu  initGroups createUser removeUser moveUser recordUser);

sub checkOu {
	my $backend=shift;
	my $ou = shift;
	print $backend,"\n";
	for ($backend) {
		when (/samba4/) {
			emit "Ou $ou";
			doOuExist($ou) ? emit_ok : emit_done "NOT PRESENT";
		}
		when (/moodle/) {
			emit "Category $ou";
			doMoodleOuExist($ou) ? emit_ok : emit_done "NOT PRESENT";
		}
	}
}

sub createOu {
	my $backend=shift;
	my $ou = shift;
	for ($backend) {
		when (/samba4/) {
			emit "Create ou $ou";
			if ( addS4Ou( $ou, 'user' ) ) {
				emit_ok;
			}
			else {
				doOuExist($ou) ? emit_done "PRESENT" : emit_error;
			}
		}
		when (/moodle/) {
			emit "Create category $ou";
			my $result = addMoodleOu($ou);
			for ($result) {
				when (/1/) { emit_ok; }
				when (/2/) { emit_done "PRESENT"; }
				when (/0/) { emit_error; }
				when (/5/) { emit_fatal; }
				default    { emit_error; }
			}

		}
	}
}

sub listOu {
	my $backend=shift;
	my $action = shift;
	my $adbOu = getAllOuAdb($backend);
	hashNav( $adbOu, '', $action,$backend);
}

sub initGroups {
	
	my $backend=shift;	
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
						default {emit_error;}
					}
				}
			}
		}

		when (/moodle/) {
			my $cohortTypes = [ 'classes', 'groups', 'schools' ];
			foreach my $cohortType ( @{$cohortTypes} ) {
				while ( my $group = $groups->{$cohortType}->next ) {
					if(!doMoodleGroupExist($group->name)){
					emit "Creating Cohort " . $group->name;
					my $result = addMoodleGroup( $group->name );
						for ($result) {
							when (/0/) { emit_error; }
							when (/2/) { emit_done "PRESENT"; }
							when (/1/) { emit_ok; }
							default {emit_error;}
						}
					}
					

				}

			}
		}
	}
}

sub removeUser {
	my $user = shift;
	
	my @accounts = $user->account_accounts->all;
		
	foreach my $account ( @accounts ) {
		my $currentBackend = $account->backend_id->kind;
		emit "Remove user account "
				  . colored($account->username,'green')
				  . " type "
				  . colored($currentBackend,'yellow')
				  . " for user "
				  . $user->name . " "
				  . $user->surname;
	
		for ($currentBackend) {
			when (/samba4/) {
				deleteS4User( $account->username ) ? emit_ok : emit_error;
			}
			when (/moodle/){
				deleteMoodleUser($account->username)? emit_ok : emit_error;				
			}
		}
	}
}

sub simplifyUser {
	my $user    = shift;
	my $result  = {};
	my $backend = shift;
	my $account =$user->account_accounts( { backendId_id => $backend->backend_id } );
	  
	if($account->count==0){
		return {adbbackend=>$backend}
		
	}
	$account=$account->first;
	my $ou = join( ',', map { 'ou=' . $_ } @{ getUserOuAdb($user) } );
	$result = {
		adbUser		=>$user,
		name         => $user->name,
		surname      => $user->surname,
		account      => {backend=>$backend->kind, username => $account->username, ou => $ou },
		userIdNumber => $user->sidi_id
		
	};

	#generate user password
	$result->{account}->{password} = mkpasswd(
		-length     => 8,
		-minlower   => 5,
		-minnum     => 1,
		-minupper   => 2,
		-minspecial => 0
	);
	
	
	return {
		simpleUser => $result,
		adbaccount => $account,
		adbbackend => $backend
	};
}

sub moveUser {
	my $user = shift;
	my $year = getCurrentYearAdb();
	my $adbRole = $user->allocation_allocations( { yearId_id => $year->school_year_id } )->next->role_id;
	my $profiles = getRoleAccountTypes($adbRole);

	foreach my $profile ( @{$profiles} ) {
		
		my $simpleUser = simplifyUser( $user, $profile->backend_id );
		my $backendKind = $profile->backend_id->kind;
		
		for ($backendKind) {
			when (/samba4/) {
				my $currentUser=$simpleUser->{simpleUser};	
				emit "Move user account  $currentUser->{account}->{username} kind ".colored($backendKind,'yellow')." to $currentUser->{account}->{ou}";	
				my $oldUserDn = "cn=$currentUser->{account}->{username},"
				  . getUserBaseDn( $currentUser->{account}->{username} );

				my $newUserDn = "cn="
				  . $currentUser->{account}->{username} . ","
				  . $currentUser->{account}->{ou} . ","
				  . $ldap->{user_base} . ","
				  . $ldap->{'dir_base'};

				if ( moveS4User( $currentUser, $oldUserDn, $newUserDn ) ) {
					emit_ok;
					}
				else {
					emit_error;
				}
			}
			when(/moodle/){
				
				my $defaultGroups =	  getAccountGroupsAdb( $simpleUser->{adbaccount}, $simpleUser->{adbbackend} );
				$defaultGroups = [ map { ($_)->name } @{$defaultGroups} ];
				my $allocationGroups = getUserOuAdb($simpleUser->{simpleUser}->{adbUser});
				my $extraGroups = [ @{$defaultGroups}, @{$allocationGroups} ];
							
				emit "Move user account  $simpleUser->{simpleUser}->{account}->{username} kind ".colored($backendKind,'yellow');
			
								
				my $result=addMoodleUser( $simpleUser->{simpleUser}, $extraGroups );
				for($result->{creationStatus}){
					when(/15/){emit_error;}
					default   {emit_ok;}
				}
			}
		}

	}
}

sub createS4User {
	my $user = shift;

	#get adb groups
	my $extraGroups =getAccountGroupsAdb( $user->{adbaccount}, $user->{adbbackend} );
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

sub createMoodleUser {
	my $user = shift;

	my $defaultGroups =	  getAccountGroupsAdb( $user->{adbaccount}, $user->{adbbackend} );
	$defaultGroups = [ map { ($_)->name } @{$defaultGroups} ];
	my $allocationGroups = getUserOuAdb($user->{simpleUser}->{adbUser});
	my $extraGroups = [ @{$defaultGroups}, @{$allocationGroups} ];
	$user->{simpleUser} = addMoodleUser( $user->{simpleUser}, $extraGroups );
	$user->{simpleUser}->{accounts}->{moodle}=$user->{simpleUser}->{account};
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
	print FHANDLE " name,surname,username,password,ou\n";
	
	
	foreach my $fullUser ( @{$users} ) {
	
		my $userData=$fullUser->[0];
		my $user=$userData->{simpleUser};
		print FHANDLE "\"$user->{name}\",\"$user->{surname}\",$user->{account}->{username},$user->{account}->{password},$user->{account}->{ou}\n";
	
#		foreach  my $userElement (@{$fullUser}){ 
#			my $user = $userElement->{simpleUser};
#				if($user){
#						print FHANDLE "\"$user->{name}\",\"$user->{surname}\",$user->{account}->{username},$user->{account}->{password},$user->{account}->{backend}\n";
#				}
#		
#			}
	}
	close FHANDLE;
	return 1;
}





sub createUser {

	my $user = shift;
	my $year = getCurrentYearAdb();
	my $adbRole =
	  $user->allocation_allocations( { yearId_id => $year->school_year_id } )->next->role_id;
	my $profiles = getRoleAccountTypes($adbRole);
	
	my $simpleUser=$user;
	my $results=[];
	
	foreach my $profile ( @{$profiles} ) {

		my $simpleUser = simplifyUser( $user, $profile->backend_id );
		my $backendKind = $profile->backend_id->kind;
	
		emit "Create "
		  . colored( $backendKind, 'yellow' )
		  . " account for "
		  . $user->name . " "
		  . $user->surname;
		
		if(!$simpleUser->{simpleUser}){
			emit_done "NO ACCOUNT";
			return $user; 
		}
	
		for ($backendKind) {
			when (/samba4/) {
				$simpleUser->{simpleUser}->{baseDn} = getUserBaseDn( $simpleUser->{simpleUser}->{account}->{username} );
				if ( !$simpleUser->{simpleUser}->{baseDn} ) {
					$simpleUser = createS4User($simpleUser);
					push(@{$results},$simpleUser);
					$simpleUser->{simpleUser}->{creationStatus}
					  ? emit_ok
					  : emit_error;
				}
				else {
					emit_done "PRESENT";
				}
			}

			when (/moodle/) {
				if (!doMoodleUserExist( $simpleUser->{simpleUser})) {
					$simpleUser = createMoodleUser($simpleUser);
					push(@{$results},$simpleUser);
					$simpleUser->{simpleUser}->{creationStatus}
					  ? emit_ok
					  : emit_error;
				}else {
					emit_done "PRESENT";
				}
				
			}
			default { emit_error; }
		}
	}
	return $results;
}

1;
