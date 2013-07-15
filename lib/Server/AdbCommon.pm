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
our @EXPORT_OK = qw($adbDbh executeAdbQuery getCurrentYearAdb);

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

sub getCurrentYearAdb{
	my $query="SELECT YEAR FROM schoolYear WHERE current=true";
    return executeAdbQuery($query);
} 