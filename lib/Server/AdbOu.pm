package Server::AdbOu;

use DBI;
use strict;
use Data::Dumper;
use warnings;
use Server::AdbCommon qw(getCurrentYearAdb);
use Server::Configuration qw($schema $server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
use feature "switch";
use Try::Tiny;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(getAllOuAdb getUserOuAdb);

sub getUserOuAdb {
	my $user        = shift;
	my $currentYear = getCurrentYearAdb();

	#get user main current allocation

	my $allocation = $user->allocation_allocations(
		{ yearId_id => $currentYear->school_year_id } )->first;
	for ( $allocation->role_id->role ) {
		when (/student/) {

			#check for possibile student allocation inconsistency
			my $allocationHandle =
			  $allocation->allocation_didacticalallocations(
				{ aggregate => 0 },
				{
					join   => { 'class_id' => 'school_id' },
					select => [
						'class_id.name', 'class_id.ou', 'class_id.schoolId_id'
					],
					distinct => 1
				}
			  );
			if ( $allocationHandle->count > 1 ) {
				print
"Fatal error, a student cannot have more then one structural allocation\n";
				return 0;
			}
			my $currentAllocation = $allocationHandle->first;
			return [
				$currentAllocation->class_id->ou,
				$currentAllocation->class_id->school_id->ou
			];

		}
		when (/teacher/) {
			if ( $allocation->ou eq 'default' ) {
				return [ $allocation->role_id->ou ];
			}
			else { return [ $allocation->ou ]; }
		}
		when (/ata/) {
			if ( $allocation->ou eq 'default' ) {
				return [ $allocation->role_id->ou ];
			}
			else { return [ $allocation->ou ]; }
		}
		
		default {
			if ( $allocation->ou eq 'default' ) {
				return [ $allocation->role_id->ou ];
			}
			else { return [ $allocation->ou ]; }
		}
	}

}

sub getAllOuAdb {
	my $format          = shift;
	my $data            = [];
	my $formattedResult = {};
	my $roles           = [ 'ata', 'teacher' ];
	my $temp;

	#get students ou

	my $adbDbh =
	  DBI->connect( "dbi:mysql:$adb->{'database'}:$adb->{'fqdn'}:3306",
		$adb->{'user'}, $adb->{'password'} );

	my $queries = {
		samba4 => {
			main => "SELECT DISTINCT CONCAT('ou=',cl.ou),CONCAT('ou=',ss.ou)
FROM
    account_account a
        INNER JOIN
    sysuser_sysuser u ON (a.userId_id = u.userId)
        INNER JOIN
    allocation_allocation al ON (al.userId_id = a.userId_id)
        INNER JOIN
    allocation_schoolyear sc ON (al.yearId_id = sc.schoolYearId)
        INNER JOIN
    allocation_didacticalallocation ad ON (al.allocationId = ad.allocationId_id)
        INNER JOIN
    school_class cl ON (cl.classId = ad.classId_id)
        INNER JOIN
    school_school ss ON (cl.schoolId_id = ss.schoolId) ORDER BY ss.ou,cl.ou",
			role => "SELECT DISTINCT CONCAT ('ou=',ou) FROM allocation_role",
			allocation =>
"SELECT DISTINCT CONCAT('ou=',ou) FROM sysuser_sysuser u INNER JOIN allocation_allocation a ON (a.userId_id=u.userId) WHERE ou!='default'"
		},
		moodle=>{
			main=>"SELECT DISTINCT cl.ou,ss.ou
FROM
    account_account a
        INNER JOIN
    sysuser_sysuser u ON (a.userId_id = u.userId)
        INNER JOIN
    allocation_allocation al ON (al.userId_id = a.userId_id)
        INNER JOIN
    allocation_schoolyear sc ON (al.yearId_id = sc.schoolYearId)
        INNER JOIN
    allocation_didacticalallocation ad ON (al.allocationId = ad.allocationId_id)
        INNER JOIN
    school_class cl ON (cl.classId = ad.classId_id)
        INNER JOIN
    school_school ss ON (cl.schoolId_id = ss.schoolId) ORDER BY ss.ou,cl.ou",
			role=>"SELECT DISTINCT  ou FROM allocation_role",
			allocation=>"SELECT DISTINCT ou FROM sysuser_sysuser u INNER JOIN allocation_allocation a ON (a.userId_id=u.userId) WHERE ou!='default'"
				
		},
		django=>{
			main=>"SELECT DISTINCT  ou FROM allocation_role",
			role=>"SELECT DISTINCT  ou FROM allocation_role",
			allocation=>"SELECT DISTINCT ou FROM sysuser_sysuser u INNER JOIN allocation_allocation a ON (a.userId_id=u.userId) WHERE ou!='default'"
		},
		gapps=>{
			main=>"SELECT DISTINCT  ou FROM allocation_role",
			role=>"SELECT DISTINCT  ou FROM allocation_role",
			allocation=>"SELECT DISTINCT ou FROM sysuser_sysuser u INNER JOIN allocation_allocation a ON (a.userId_id=u.userId) WHERE ou!='default'"
		}
		
	};

	my $query  = $queries->{$format}->{main};
	my $result = $adbDbh->prepare($query);
	$result->execute();
	$data   = $result->fetchall_arrayref();
	
	$query  = $queries->{$format}->{role};
	$result = $adbDbh->prepare($query);
	$result->execute();
	$data = [ @{$data}, @{ $result->fetchall_arrayref() } ];

	foreach my $role ( @{$roles} ) {
		$query  = $queries->{$format}->{allocation};
		$result = $adbDbh->prepare($query);
		$result->execute();
		$temp = $result->fetchall_arrayref();
			
		if ( scalar( @{$temp} ) > 0 ) {
			$data = [ @{$data}, @{$temp} ];
		}
	}

	foreach my $element ( @{$data} ) {
		if ( scalar( @{$element} ) > 1 ) {
			if ( !( $formattedResult->{ $element->[1] } ) ) {
				$formattedResult->{ $element->[1] } = {};
			}
			$formattedResult->{ $element->[1] }->{ $element->[0] } = 0;
		}
		else {
			$formattedResult->{ $element->[0] } = 0;
		}

	}

	$adbDbh->disconnect;
	return $formattedResult;
}

return 1;
