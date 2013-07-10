package Server::AdbSubject;

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
our @EXPORT_OK = qw(syncSubjectAdb addSubjectAdb);


sub doSubjectExistAdb{
	my $subjectId=shift;
	my $query="SELECT DISTINCT COUNT(subjectId) FROM subject WHERE subjectId=\'$subjectId\'";
	return executeAdbQuery($query);
}

sub addSubjectAdb{
	my $subject=shift;
	my $query="INSERT INTO subject (subjectId,description,shortDesc) VALUES ($subject->{subjectId},\"$subject->{description}\",\"$subject->{shortDesc}\")";
	if (doSubjectExistAdb($subject->{subjectId}) ){print "Subject already inserted"; return 0;}else{
		my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
	}
}

sub normalizeSubjectAdb{
	my $subject=shift;
	$subject->{description}=ucfirst(lc($subject->{description}));
	$subject->{shortDesc}=ucfirst(lc($subject->{shortDesc}));
	return $subject;
}

sub normalizeSubjectsAdb{
	my $subjects=shift;
	my $index=0;
	foreach my $subject (@{$subjects}){
		$subjects->[$index]=normalizeSubjectAdb($subjects->[$index]);
		$index++;
	}
	return $subjects;
}

 sub syncSubjectAdb{
 	my $subjects=shift;
 	$subjects=normalizeSubjectsAdb($subjects);
 	foreach my $subject (@{$subjects}){
 		addSubjectAdb($subject);
 	}
 	
 } 	