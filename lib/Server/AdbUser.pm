package Server::AdbUser;

use DBI;
use strict;
use warnings;
use Data::Dumper;
use List::UtilsBy qw(extract_by);
use Server::AdbCommon
  qw($schema getCurrentYearAdb creationTimeStampsAdb getActiveSchools);
use Text::Capitalize;
use Server::AdbAccount qw(addAccountAdb  getAccountAdb   getAccountsAdb);
use Server::AdbPolicy qw(setDefaultPolicyAdb);
use Server::AdbAllocation qw(syncAllocationAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername today);
use feature "switch";
use Try::Tiny;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(syncUsersAdb addUserAdb getAllUsersAdb doUsersExistAdb deactivateUserAdb);

sub doUsersExistAdb {
	my $usersNumber = $schema->resultset('SysuserSysuser')->count;
	return $usersNumber;
}

sub getUserOrderAdb {
	my $newInsertOrder =
	  $schema->resultset('SysuserSysuser')->get_column('insertOrder')->max;
	$newInsertOrder = $newInsertOrder ? $newInsertOrder + 1 : 0;
	return $newInsertOrder;
}

sub getAllUsersByRoleAdb {
	my $role        = shift;
	my $year        = shift;
	my $currentRole = $role->role;
	my @result;
	for ($currentRole) {
		when (/ata/) {
			@result = $schema->resultset('SysuserSysuser')->search(
				{
					roleId_id => $role->role_id,
					yearId_id => $year->school_year_id
				},
				{ join => 'allocation_allocations' }
			)->all;
		}
		when (/student/) {
			@result = $schema->resultset('SysuserSysuser')->search(
				{ roleId_id => 1, yearId_id => 1, 'school_id.active' => 1 },
				{
					join => {
						'allocation_allocations' => {
							'allocation_didacticalallocations' =>
							  { 'class_id' => 'school_id' }
						}
					},
					distinct => 1
				}
			)->all;
		}
		default {
			@result = $schema->resultset('SysuserSysuser')->search(
				{
					roleId_id => $role->role_id,
					yearId_id => $year->school_year_id
				},
				{ join => 'allocation_allocations' }
			)->all;
		}
	}

	return \@result;

}

sub getAllUsersAdb {
	my $year = shift;
	my $ata =
	  $schema->resultset('AllocationRole')->search( { role => 'ata' } )->first;
	my $student =
	  $schema->resultset('AllocationRole')->search( { role => 'student' } ) ->first;
	my $teacher =
	  $schema->resultset('AllocationRole')->search( { role => 'teacher' } ) ->first;
	return [
		@{ getAllUsersByRoleAdb( $student, $year ) },
		@{ getAllUsersByRoleAdb( $teacher, $year ) },
		@{ getAllUsersByRoleAdb( $ata, $year ) }
	];
}

sub normalizeUserAdb {
	my $user          = shift;
	my $role          = shift;
	my $allocationMap = shift;
	$user->{name}    =   sanitizeString( capitalize(lc($user->{name}) ) );
	$user->{surname} =   sanitizeString( capitalize( lc($user->{surname})) );

	if ( $role eq 'student' ) {
		$user = normalizeStudentAdb( $user, $allocationMap );
	}
	if ( $role eq 'teacher' ) {
		$user = normalizeTeacherAdb( $user, $allocationMap );
	}
	if ( $role eq 'ata' ) {
		$user = normalizeAtaAdb($user);
	}

	return $user;
}

sub normalizeStudentAdb {
	my $user        = shift;
	my $allocations = shift;
	my $allocation  = $allocations->{ $user->{userIdNumber} };
	$user->{classLabel}  = lc( $user->{classLabel} );
	$user->{classId}     = $user->{classNumber} . $user->{classLabel};
	$user->{allocations} = $allocation;
	return $user;
}

sub normalizeAtaAdb {
	my $user = shift;

	return $user;
}

sub normalizeTeacherAdb {
	my $user        = shift;
	my $allocations = shift;
	my $allocation  = $allocations->{ $user->{userIdNumber} };
	if ( !$allocation ) {
		$allocation = [ { classId => '0Ext', subjectId => 1000666 } ];
	}
	$user->{allocations} = $allocation;
	return $user;
}

sub normalizeUsersAdb {
	my $users         = shift;
	my $role          = shift;
	my $allocationMap = shift;
	my $index         = 0;
	foreach my $user ( @{$users} ) {
		$users->[$index] =
		  normalizeUserAdb( $users->[$index], $role, $allocationMap );
		$index++;
	}
	return $users;
}

sub addUserAdb {
	my $user       = shift;
	my $role       = shift;
	my $userStatus = {};
	my $adbAccount;
	my $accountType =
	  $schema->resultset('BackendBackend')->search( { kind => 'samba4' } )
	  ->first;
	my $adbUser =
	  $schema->resultset('SysuserSysuser')
	  ->search( { sidiId => $user->{userIdNumber} } );
	$userStatus->{user} = $adbUser->count;
	if ( $userStatus->{user} ) {
		$adbUser    = $adbUser->first;
		$adbAccount = $schema->resultset('AccountAccount')->search(
			{
				userId_id    => $adbUser->user_id,
				backendId_id => $accountType->backend_id
			}
		);
		$userStatus->{account} = $adbAccount->count;
	}
	$user->{pristine} = 0;
	$user->{modified} = 0;

	if ( !$userStatus->{user} ) {
		$adbUser = try {
			$adbUser = $schema->resultset('SysuserSysuser')->create(
				creationTimeStampsAdb(
					{
						sidiId      => $user->{userIdNumber},
						name        => $user->{name},
						surname     => $user->{surname},
						origin      => $user->{origin},
						insertOrder => $user->{insertOrder}
					}
				)
			);
			$user->{pristine} = 1;
			return $adbUser;
		}
		catch {
			when (/Can't call method/) {
				$adbUser->{error} = 1;
				return 0;
			}
			default { die $_ }
		};
	}

	if ( $adbUser->{error} ) {
		return { result => $user, data => $adbUser };
	}

	if ( !$userStatus->{account} ) {
		addAccountAdb( $adbUser, $accountType );
		if ( !$user->{pristine} ) { $user->{modified} = 1; }
	}

	my $allocationStatus =
	  syncAllocationAdb( $adbUser, $role, $user->{allocations} );

	if (   $allocationStatus->{sub_allocations_modified}
		|| $allocationStatus->{main_allocation_modified} )
	{
		$user->{modified} = 1;
	}

	$adbAccount =
	  $adbUser->account_accounts( { backendId_id => $accountType->backend_id } )
	  ->first;

	if ( setDefaultPolicyAdb( $adbAccount, $role ) == 1 ) {
		if ( !$user->{pristine} ) { $user->{modified} = 1 }
	}

	return { result => $user, data => $adbUser };
}

sub deactivateUserAdb {
	my $user = shift;

	my @allocations = $user->allocation_allocations->all;

	foreach my $allocation (@allocations) {
		$allocation->delete_related('allocation_didacticalallocations');
		$allocation->delete_related('allocation_nondidacticalallocations');
		$allocation->delete;
	}

	my @accounts = $user->account_accounts->all;

	foreach my $account (@accounts) {
		$account->update( { active => 0 } );
	}
	return $user;
}

sub syncUsersAdb {
	my $users = shift;
	my $role  = shift;
	my $year  = shift;

	my $allocationList = '';

	my @modifiedUsers;
	my @newUsers;

	if ( scalar(@_) ) {
		$allocationList = shift;
	}

	my $yearAdb =
	  $schema->resultset('AllocationSchoolyear')->search( { year => $year } )
	  ->first;
	my $roleAdb =
	  $schema->resultset('AllocationRole')->search( { role => $role } )->first;

	$users = normalizeUsersAdb( $users, $role, $allocationList );

	my $removedUsers = getAllUsersByRoleAdb( $roleAdb, $yearAdb );

	my $insertOrder = getUserOrderAdb();

	foreach my $user ( @{$users} ) {

		#set sync status
		$user->{sync}   = 1;
		$user->{origin} = 'automatic';

		#set insertion order
		$user->{insertOrder} = $insertOrder;
		my $result = addUserAdb( $user, $roleAdb, 'automatic' );

		extract_by { $_->sidi_id == $user->{userIdNumber} } @{$removedUsers};

		if ( $user->{modified} ) { push( @modifiedUsers, $result->{data} ); }
		if ( $user->{pristine} ) { push( @newUsers,      $result->{data} ); }
	}

	#deactivate  user accounts
	

	foreach my $oldUser ( @{$removedUsers} ) {
		print "remove user ", $oldUser->name, "\n";
		$oldUser = deactivateUserAdb($oldUser);
	}

	return {
		'newusers'      => \@newUsers,
		"removedusers"  => $removedUsers,
		"modifiedusers" => \@modifiedUsers,
		"status"        => 1
	};
}

1;

