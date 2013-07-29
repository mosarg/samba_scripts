package Server::AdbClass;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema creationTimeStampsAdb);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
use feature "switch";
use Try::Tiny;


require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(syncClassAdb addClassAdb);


sub normalizeClassAdb{
	my $class=shift;
	$class->{classLabel}=lc($class->{classLabel});
	$class->{classId}=$class->{classNumber}.$class->{classLabel};
	$class->{ou}="$class->{classId}";
	$class->{description}=ucfirst(lc($class->{description}));
	return $class;
}

sub normalizeClassesAdb{
	my $classes=shift;
	my $index=0;
	foreach my $class (@{$classes}){
			$classes->[$index]=normalizeClassAdb($classes->[$index]);
			$index++;		
	}
	return $classes;
}

sub addClassAdb{
  	my $class=shift;
  	my $dbClass={name=>$class->{classId},ou=>$class->{ou},description=>$class->{description},capacity=>30};
  	
  	#get school object
  	my $school=$schema->resultset('SchoolSchool')->search({meccanographic=>$class->{meccanographic} })->next;
  	
  	try{
  		$school->create_related('school_classes',creationTimeStampsAdb($dbClass) );
		return 1;
  	}catch{
  			when (/Can't call method/){
			return 0;
		}
		when ( /Duplicate entry/ ){
			return 2;		
		}
		default {die $_}
  		
  	}

 }
 
sub syncClassAdb{
 	my $classes=shift;
 	my $status=1;
 	$classes=normalizeClassesAdb($classes);
 	foreach my $class (@{$classes}){
 		$status=addClassAdb($class)*$status;
 	}
 	return $status;
 }
  