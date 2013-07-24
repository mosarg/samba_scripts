package Server::AdbSubject;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::AdbCommon qw($schema);
use Db::Django;
use Server::Configuration qw($server $adb $ldap);
use Server::Commands qw(execute sanitizeString sanitizeUsername);

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(syncSubjectAdb);


sub normalizeSubjectAdb {
	my $subject = shift;
	$subject->{description} = ucfirst( lc( $subject->{description} ) );
	$subject->{shortDescription}   = ucfirst( lc( $subject->{shortDescription} ) );
	$subject->{created}="localtime";
	$subject->{modified}="localtime";
	return $subject;
}

sub normalizeSubjectsAdb {
	my $subjects = shift;
	my $index    = 0;
	foreach my $subject ( @{$subjects} ) {
		$subjects->[$index] = normalizeSubjectAdb( $subjects->[$index] );
		$index++;
	}
	return $subjects;
}

sub addSubjectAdb{
	
	my $subject=shift;
	my $resultSet=$schema->resultset('SchoolSubject')->search({code=>$subject->{code}});
	if(!$resultSet->next){
		$schema->resultset('SchoolSubject')->create($subject);
		return 1;
	}
	return 0;
}

sub syncSubjectAdb {
	my $subjects = shift;
	my $status   = 1;
	$subjects = normalizeSubjectsAdb($subjects);
	my $emptySubject = {
		code   => 1000666,
		description => "Nessuna Materia",
		shortDescription   => "Nessuna materia",
		niceName    => "No subject",
		created =>"localtime",
		modified=>"localtime"
	};
	
	
	addSubjectAdb($emptySubject);
	
	foreach my $subject ( @{$subjects} ) {
		$status=addSubjectAdb($subject)*$status;
	}
	return $status;
}
