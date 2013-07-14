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
 		print "Class $class->{classId},$class->{meccanographic} already inserted\n";
 	}else{
 		my $query="INSERT INTO class (classId,classDescription,classOu,classCapacity,meccanographic) 
 				VALUES (\'$class->{classId}'\,'Class Description',\'$class->{ou}\',30,\'$class->{meccanographic}\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 	}
 }
 
sub syncClassAdb{
 	my $classes=shift;
 	$classes=normalizeClassesAdb($classes);
 	foreach my $class (@{$classes}){
 		addClassAdb($class);
 	}
 } 