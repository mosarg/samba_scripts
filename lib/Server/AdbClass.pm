package Server::AdbClass;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($adbDbh executeAdbQuery);
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(syncClassAdb addClassAdb);

sub doClassExistAdb{
 	my $classId=shift;
 	my $meccanographic=shift;
 	my $query="SELECT COUNT(classId) FROM class WHERE classId=\'$classId\' AND meccanographic=\'$meccanographic\'";
    return executeAdbQuery($query);
 }

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
  	
 	if (doClassExistAdb($class->{classId},$class->{meccanographic}) ){
 		return 0;
 	}else{
 		my $query="INSERT INTO class (classId,classDescription,classOu,classCapacity,meccanographic) 
 				VALUES (\'$class->{classId}'\,'Class Description',\'$class->{ou}\',30,\'$class->{meccanographic}\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 		return 1;
 	}
 }
 
sub syncClassAdb{
 	my $classes=shift;
 	my $status=1;
 	#insert empty class
 	addClassAdb({classId=>'0Ext',classDescription=>'Empty class',ou=>'0Ext',classCapacity=>30,meccanographic=>'UDSSC817F0'});	
 	$classes=normalizeClassesAdb($classes);
 	foreach my $class (@{$classes}){
 		$status=addClassAdb($class)*$status;
 	}
 	return $status;
 } 