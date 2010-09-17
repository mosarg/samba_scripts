#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Client::commands qw(execute_command);
use Client::Info qw(get_clients_info collectClientsPackagesInfo);
use Client::configuration qw($reports $paths $client);
use Client::Output qw(htmlOut);
use Client::Log qw(doLog);
use File::Copy;
use Switch;
use Data::Dumper;

my $clients    = 'localhost';
my $command    = 'notepad';
my $all        = '';
my $reportonly ='';
my $group	   ='';
my $reportsDir = $client->{'wpkg_xml_log_dir'};
my @givenClients=();

my $log_data={};

open FILE, ">", $reports->{'wpkg'} or die $!;

GetOptions(
	'clients=s' => \$clients,
	'all'       => \$all,
	'reportonly'=> \$reportonly,
	'group=s'   => \$group
);

if ($all) {
	foreach my $computer ( @{ get_clients_info($group) } ) {
		print "Current computer ", $computer->[0], " \n";
		if (!$reportonly){
		execute_command( $computer->[1], 'get_packages' );
		move( $reportsDir . '/wpkg.xml',
			$reportsDir . '/wpkg_' . lc($computer->[0]). '.xml' );
		sleep 5;	
		}
		
		push( @givenClients, lc($computer->[0]));
		
	}

}
else {
	@givenClients = split( /,/, $clients );
	if ( scalar(@givenClients) > 1 ) {
		foreach my $computer ( split( /,/, $clients ) ) {
			print "Current computer ", $computer, " \n";
			if (!$reportonly){
			print execute_command( $computer, 'get_packages' ), "\n";
			move( $reportsDir . '/wpkg.xml',
				$reportsDir . '/wpkg_' . $computer . '.xml' );
			 sleep 5;
			}
			
		}

	}
	else {
		
		if (!$reportonly){
		print execute_command( $clients, 'get_packages' ), "\n";
		move( $reportsDir . '/wpkg.xml',
			$reportsDir . '/wpkg_' . $clients . '.xml' );
		}
	}
}


print FILE htmlOut( collectClientsPackagesInfo( \@givenClients,$log_data) );

doLog('mail','Test Log',Dumper $log_data);
