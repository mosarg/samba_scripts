package Server::AdbAllocation;

use DBI;
use strict;
use warnings;
use Data::Dumper;
use List::UtilsBy qw(extract_by);
use Server::AdbCommon qw(getCurrentYearAdb creationTimeStampsAdb);
use Server::Configuration qw($schema $server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
use feature "switch";
use Try::Tiny;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(addAllocationAdb syncAllocationAdb);

sub syncAllocationAdb {
	my $user                = shift;
	my $role                = shift;
	my $importedAllocations = shift;

	if ( $user->{sync} ) {
		return updateAllocationAdb( $user, $role, $importedAllocations );
	}
	else {
		return addAllocationAdb( $user, $role, $importedAllocations );
	}
}

sub updateAllocationAdb {
	my $user                = shift;
	my $role                = shift;
	my $importedAllocations = shift;

	#empty execution status
	my $status = {
		main_allocation_created  => 0,
		main_allocation_modified => 0,
		sub_allocations_modified => 0,
		sub_allocations_created  => 0
	};

	my $currentYear = getCurrentYearAdb();
	
	#if user has no primary allocation, update allocation is useless call add allocation
	if (
		$user->allocation_allocations(
			{ yearId_id => $currentYear->school_year_id }
		)->count == 0
	  )
	{
		$status->{main_allocation_modified}=1;
		return addAllocationAdb( $user, $role, $importedAllocations,$status);
	}
	
	
	
	my $currentAllocation = $user->allocation_allocations(
		{ yearId_id => $currentYear->school_year_id } )->first;
	
	# update role 

	if ( $currentAllocation->role_id_id != $role->role_id ) {
		$currentAllocation->update( { roleId_id => $role->role_id } );
		$status->{main_allocation_modified} = 1;
	}

	my $currentRole = $role->role;

	for ($currentRole) {
		when (/ata/) {

#for now ata users do not change allocation after creation just check for allocation presence
			if (
				$currentAllocation->allocation_nondidacticalallocations->count() ==
				0 )
			{
				$status->{sub_allocations_modified} = 1;
				return createSubAllocations( $role, $currentAllocation,
					$importedAllocations, $status );
			}
		}
		when (/student|teacher/) {
								  
			#get current allocations	
			my @didacticalAllocations =
				$currentAllocation->allocation_didacticalallocations->all;
			
			#if there are no didactical allocations create them
			
		
		
			if (scalar(@didacticalAllocations)==0) {
					
				
				$status->{sub_allocations_modified} = 1;
				return createSubAllocations( $role, $currentAllocation,
					$importedAllocations, $status );
			}
		
			#remove from current adb allocations current ais allocations
			#all remaining allocations must be removed
			foreach my $aisAllocation ( @{$importedAllocations} ) {
			
				
				extract_by {
					( $_->class_id->name eq $aisAllocation->{classId} )
					  && (
						$_->subject_id->code eq $aisAllocation->{subjectId} );
				}
				@didacticalAllocations;
			}
			
			
		
			#if there are stale allocations remove them all and recreate them according to ais db
			if ( scalar(@didacticalAllocations) > 0 ) {

				$currentAllocation->delete_related(
					'allocation_didacticalallocations');
				$status->{sub_allocations_modified} = 1;
				return createSubAllocations( $role, $currentAllocation,
					$importedAllocations, $status );
			}

		}
	}

	return $status;
}

sub addAllocationAdb {
	my $user                = shift;
	my $role                = shift;
	my $importedAllocations = shift;
	my $currentYear         = getCurrentYearAdb();
	my $status=shift;
	
	if (!$status){
	
		 $status              = {
			main_allocation_created  => 0,
			main_allocation_modified => 0,
			sub_allocations_modified => 0,
			sub_allocations_created  => 0
	};
	}
	
	#add role allocation
	my $currentAllocation = try {
		my $currentAllocation = $user->create_related(
			'allocation_allocations',
			creationTimeStampsAdb(
				{
					roleId_id => $role->role_id,
					yearId_id => $currentYear->school_year_id,
					ou        => 'default'
				}
			)
		);
		$status->{main_allocation_created} = 1;
		return $currentAllocation;
	}
	catch {
		when (/Can't call method/) {
			return 0;
		}
		when (/Duplicate entry/) {
			$status->{main_allocation_present} = 1;
			return 2;
		}
		default { die $_ }
	};

	if ( $status->{main_allocation_created} ) {
		return createSubAllocations( $role, $currentAllocation,
			$importedAllocations, $status );
	}
	else { 
		return $status; }
}

sub createSubAllocations {

	my $role                = shift;
	my $currentAllocation   = shift;
	my $importedAllocations = shift;
	my $status              = shift;

	my $currentRole = $role->role;

	for ($currentRole) {
		when (/student|teacher/) {

			foreach my $allocation ( @{$importedAllocations} ) {

				my $class =
				  $schema->resultset('SchoolClass')
				  ->search( { name => $allocation->{classId} } )->first;
				my $subject =
				  $schema->resultset('SchoolSubject')
				  ->search( { code => $allocation->{subjectId} } )->first;
				
				


				try {
					$currentAllocation->create_related(
						'allocation_didacticalallocations',
						creationTimeStampsAdb(
							{
								classId_id   => $class->class_id,
								subjectId_id => $subject->subject_id
							}
						)
					);
					$status->{sub_allocations_created} = 1;
					return 1;
				}
				catch {
					when (/Can't call method/) {
						return 0;
					}
					when (/Duplicate entry/) {
						$status->{sub_allocations_present} = 1;
						return 2;
					}
					default { die $_ }

				};
			}
		}

		#for now all atas are automatically allocated inside main school
		when (/ata/) {

			#get main school
			my $school = $schema->resultset('SchoolSchool')->first;
			try {
				$currentAllocation->create_related(
					'allocation_nondidacticalallocations',
					creationTimeStampsAdb(
						{ schoolId_id => $school->school_id }
					)
				);
				$status->{sub_allocations_created} = 1;
				return 1;
			}
			catch {
				when (/Can't call method/) {
					return 0;
				}
				when (/Duplicate entry/) {
					$status->{sub_allocations_modified} = 1;
					return 2;
				}
				default { die $_ }
			};

		}
	}

	return $status;

}

