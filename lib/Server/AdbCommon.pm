package Server::AdbCommon;

use DBI;
use strict;
use warnings;
use experimental 'switch';
use Cwd;
use Getopt::Long;
use Data::Dumper;
use DateTime;
use feature "switch";
use Try::Tiny;
use Data::Structure::Util qw( unbless );
use Server::Configuration qw( $schema $server $adb);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;



our @ISA = qw(Exporter);

our @EXPORT_OK = qw(getCurrentYearAdb setCurrentYearAdb addYearAdb creationTimeStampsAdb getActiveSchools getYearAdb);

#open user account database connections





#$schema->storage->debug(1);



sub setCurrentYearAdb{
	my $year=shift;
	$schema->resultset('AllocationSchoolyear')->update({active=>0});
	return $schema->resultset('AllocationSchoolyear')->find({year=>$year})->update({active=>1});	
}

sub getActiveSchools{
	my @schools=$schema->resultset('SchoolSchool')->search({active=>1})->all;
	return \@schools;
}

sub addYearAdb{
	my $aisYear=shift;
	
	my $adbYear=try{
		my $year=$schema->resultset('AllocationSchoolyear')->create(creationTimeStampsAdb({year=>$aisYear,description=>'Auto insert',active=>0}));
		return {data=>$year,status=>1};
	}catch{
		when (/Can't call method/){
			return {status=>0}
			
		}
		when ( /Duplicate entry/ ){
			return {data=>$schema->resultset('AllocationSchoolyear')->search({year=>$aisYear})->next,status=>2};		
		}
		default {die $_}
	};
}

sub creationTimeStampsAdb{
	my $data=shift;
	$data->{created}=DateTime->now;
	$data->{modified}=DateTime->now;
	return $data;
	
}

sub getCurrentYearAdb{
	my $currentYear=$schema->resultset('AllocationSchoolyear')->search({active=>1})->next;
    return $currentYear;
} 

sub getYearAdb{
	my $year=shift;
	my $adbyear=$schema->resultset('AllocationSchoolyear')->search({year=>$year})->next;
    return $adbyear;
} 


return 1;
