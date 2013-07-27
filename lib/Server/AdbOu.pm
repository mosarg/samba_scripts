package Server::AdbOu;

use DBI;
use strict;
use warnings;
use Server::AdbCommon qw($schema getCurrentYearAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
use feature "switch";
use Try::Tiny;

require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAllOuAdb getUserOuAdb);

sub getUserOuAdb{
	my $user=shift;
	my $currentYear=getCurrentYearAdb();
	
	#get user main current allocation
	
	my $allocation=$user->allocation_allocations({yearId_id=>$currentYear->school_year_id})->first;
	for($allocation->role_id->role){
		when(/student/){
			#check for possibile student allocation inconsistency
			my $allocationHandle=$allocation->allocation_didacticalallocations( {aggregate=>0},{join=>{'class_id'=>'school_id'}, select=>['class_id.name','class_id.ou','class_id.schoolId_id'],distinct=>1 } );
			if( $allocationHandle->count > 1){
				print "Fatal error, a student cannot have more then one structural allocation\n";
				return 0;
			}
			my	$currentAllocation=$allocationHandle->first;
			return [$currentAllocation->class_id->ou,$currentAllocation->class_id->school_id->ou];
			
		}
		when(/teacher/){
			if ($allocation->ou eq 'default'){
				return [$allocation->role_id->ou];				
			}else
			{return [$allocation->ou];}			
		}
		when(/ata/){
			if ($allocation->ou eq 'default'){
				return [$allocation->role_id->ou];				
			}else
			{return [$allocation->ou];}
		}
	}
	
	

}



sub getAllOuAdb{
	my $format=shift;
	my $data=[];
	my $formattedResult={};
	my $roles=['ata','teacher'];
	my $temp;
	#get students ou
		
	switch($format){
	
	case 'samba4' {
	my $query="SELECT DISTINCT CONCAT('ou=',classOu) AS classOu,CONCAT('ou=',schoolOu) AS schoolOu FROM account 
					   INNER JOIN studentAllocation USING(userIdNumber) 
					   INNER JOIN class USING(classId) 
					   INNER JOIN school USING (meccanographic)
					   WHERE  type=\'$format\' AND year=(SELECT year FROM schoolYear WHERE current=true)";
	my $result = $adbDbh->prepare($query);
	$result->execute();
	$data=$result->fetchall_arrayref();
	$query="SELECT DISTINCT CONCAT('ou=',defaultOu) FROM role";
	$result = $adbDbh->prepare($query);
	$result->execute();
	$data=[@{$data},@{$result->fetchall_arrayref()}];
	
	
	foreach my $role (@{$roles}){
		$query="SELECT DISTINCT CONCAT('ou=',ou) FROM user INNER JOIN $role"."Allocation USING (userIdNumber) WHERE ou!='default'; ";
		$result = $adbDbh->prepare($query);
		$result->execute();
		$temp=$result->fetchall_arrayref();
		if(scalar(@{$temp})>0){
		$data=[@{$data},@{$result->fetchall_arrayref()}];
		}
	}
	}
	
	}
	foreach my $element (@{$data}){
		if(scalar(@{$element})>1){
			if (! ($formattedResult->{$element->[1]}) ){ $formattedResult->{$element->[1]}={};}
			$formattedResult->{$element->[1]}->{$element->[0]}=0;	
		}else{
			$formattedResult->{$element->[0]}=0;
		}	
		
	
	}
	return $formattedResult;
}


return 1;