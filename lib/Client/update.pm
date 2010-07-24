package Client::update;

use strict;
use warnings;
use Cwd;
use threads;
use Getopt::Long;
use Net::Ping;
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd);
use Client::configuration qw($wsus_log);
use Client::startstop qw(restart_client turnoff_client);
use Client::ParseWsusLog qw(mustreboot);

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(do_client_update);






sub do_client_update {
	my $client     = shift;
	my $max_cycles = shift;
	my $ping       = Net::Ping->new();
	$ping->port_number('139');
	my $current_cycle = 0;
	my $wakeup_cycle=0;
	
	while ( $current_cycle < $max_cycles ) {
		$wakeup_cycle=0;
		
		execute_shell_client_cmd($client,'%programfiles%\esegui_aggiornamento\update.cmd');

		if ( mustreboot($client) ) {
			print "Rebooting client\n";
			restart_client($client);
		}
		else {
			print "Update complete shutting down \n";
			turnoff_client($client);
			last;
		}
		while ( (!$ping->ping( $client, '4' ))&&($wakeup_cycle<$max_cycles) ) {
			print "Waiting for client to come up\n";
			sleep 60;
			$wakeup_cycle++;
		}
		
		if ($wakeup_cycle>=$max_cycles ){
			print "Wakeup failed";
			$current_cycle=100;
			last;
		} 
		
		$current_cycle++;
	}
	($current_cycle<$max_cycles)?return 1:return 0;
}
