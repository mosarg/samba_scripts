package Server::AdbCommon;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::Configuration qw($server $adb);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;



our @ISA = qw(Exporter);
our @EXPORT_OK = qw($adbDbh executeAdbQuery getCurrentYearAdb setCurrentYearAdb addYearAdb);

#open user account database connections
our $adbDbh = DBI->connect( "dbi:mysql:$adb->{'database'}:$adb->{'fqdn'}:3306",
	$adb->{'user'}, $adb->{'password'} )
  or die "Can’t connect to Administrative data base\n";
  
 sub executeAdbQuery{
 	my $query=shift;
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	my @result=$queryH->fetchrow_array();
 	return @result?$result[0]:0;
 } 


sub setCurrentYearAdb{
	my $year=shift;
	my $query="UPDATE schoolYear SET current=(IF(year=$year,1,0));";
	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
}


sub doYearExistAdb{
	my $year=shift;
	my $query="SELECT COUNT(year) FROM schoolYear WHERE year=$year";
	return executeAdbQuery($query);
}

sub addYearAdb{
	my $year=shift;
	if (!doYearExistAdb($year)){	
		my $query="INSERT INTO schoolYear (year,description,current) VALUES($year,'Auto insert',0)";
		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();	
		return 1;
	}
	return 0;
}

sub getCurrentYearAdb{
	my $query="SELECT YEAR FROM schoolYear WHERE current=true";
    return executeAdbQuery($query);
} 


