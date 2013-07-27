package Server::AdbAllocation;

use DBI;
use strict;
use warnings;
use Data::Dumper;
use Server::AdbCommon qw($schema getCurrentYearAdb creationTimeStampsAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
use feature "switch";
use Try::Tiny;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(addAllocationAdb removeAllocationAdb);

sub removeAllocationAdb {
	my $user = shift;
	my $role = shift;
	if ( $role eq 'student' ) {
		return removeStudentAllocationAdb($user);
	}
	if ( $role eq 'ata' ) {
		return removeAtaAllocationAdb($user);
	}
	if ( $role eq 'teacher' ) {
		return removeTeacherAllocationAdb($user);
	}
}


sub addAllocationAdb {
	my $user                = shift;
	my $role                = shift;
	my $importedAllocations = shift;
	my $currentYear         = getCurrentYearAdb();

	#add role allocation
	my $currentAllocation = try {
		my $currentAllocation = $user->create_related(
			'allocation_allocations',
			creationTimeStampsAdb(
				{
					roleId_id => $role->role_id,
					yearId_id => $currentYear -> school_year_id
				}
			)
		);
		return $currentAllocation;
	}
	catch {
		when (/Can't call method/) {
			return 0;
		}
		when (/Duplicate entry/) {
			return 2;
		}
		default { die $_ }
	}
	
	my $currentRole = $role->role;
	

	for ($currentRole) {
		when (/student|teacher/) {
			foreach my $allocation ( @{$importedAllocations->{$user->sidi_id}} ) {
				try {
					$currentAllocation->create_related(
						'allocation_didacticalallocations',
						creationTimeStampsAdb(
							{
								classId_id   => $allocation->{classId},
								subjectId_id => $allocation->{subjectId}
							}
						)
					);
				return 1;	
				}
				catch {
					when (/Can't call method/) {
						return 0;
					}
					when (/Duplicate entry/) {
						return 2;
					}
					default { die $_ }

				}
			}
		}
		when (/ata/) {
			foreach my $allocation ( @{$importedAllocations} ) {
				try {
					$currentAllocation->create_related(
						'allocation_nondidacticalallocations',
						creationTimeStampsAdb() );
				}
				catch {
					when (/Can't call method/) {
						return 0;
					}
					when (/Duplicate entry/) {
						return 2;
					}
					default { die $_ }
				}
			}

		}
	}
}
