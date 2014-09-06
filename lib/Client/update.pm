package Client::update;

use strict;
use warnings;
use Cwd;
use threads;
use Net::Ping;
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd);
use Client::configuration qw($wsus_log $log_info);
use Client::startstop qw(restart_client turnoff_client);
use Client::ParseLog qw(checkAxiosUpdateState otherUpdatesRunning mustreboot);
use Client::commands qw(execute_command);
use Client::Log qw(transportMail doLog);
require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(do_client_update doAxiosUpdate);

sub doAxiosUpdate{
	my $client     = shift;
	my $max_cycles = shift;
	my $current_cycle = 0;
	my $wakeup_cycle=0;
	my $running_cycle=0;
	
	print "$client: preparing axios update\n";
	
	while ( (otherUpdatesRunning($client))&&($running_cycle<$max_cycles)){
			print "$client: other update processes running. I'll be waiting for 60 seconds\n";
			sleep 60;
			$running_cycle++;
		}
	if ($running_cycle>=$max_cycles ){
			return "$client: an Update process is stuck\n";
		} 
	
	print "$client: starting axios update\n";
	execute_command($client,'upgrade_axios');
	
	if (checkAxiosUpdateState($client)){
	print "$client: axios update procedure failed!\n";
			transportMail($log_info->{'email_recipient'}, $log_info->{'email_sender'},
			'Axios update error',"I couldn't update  client $client");
	return '';	
	}else{
		print "$client: axios update procedure succesfully executed\n";
	}
	
}




sub do_client_update {
	my $client     = shift;
	my $max_cycles = shift;
	my $ping       = Net::Ping->new("icmp");
	$ping->port_number('139');
	my $current_cycle = 0;
	my $wakeup_cycle=0;
	my $running_cycle=0;
	
	print "$client: preparing windows update\n";
	
	while ( $current_cycle < $max_cycles ) {
	
		$wakeup_cycle=0;
		$running_cycle=0;
					
#		while ( (otherUpdatesRunning($client))&&($running_cycle<$max_cycles)){
#			print "$client: other update processes running. I'll be waiting for 60 seconds\n";
#			sleep 60;
#			$running_cycle++;
#		}
#		if ($running_cycle>=$max_cycles ){
#			print "$client: an Update process is stuck\n";
#			$current_cycle=100;
#			last;
#		} 	
		
		print "$client: start Windows update\n";		
		execute_command($client,'update_client');
		
		
		if ( mustreboot($client) ) {
			print "$client: Rebooting client\n";
			restart_client($client);
		}
		else {
			print "$client: update complete, shutting down \n";
			turnoff_client($client);
			last;
		}
		
		while ( (!$ping->ping( $client, '4' ))&&($wakeup_cycle<$max_cycles) ) {
			print "$client: waiting for client to come up\n";
			sleep 60;
			$wakeup_cycle++;
		}
		
		if ($wakeup_cycle>=$max_cycles ){
			print "$client: wakeup failed\n";
			$current_cycle=100;
			last;
		} 
		$current_cycle++;
	}
	($current_cycle<$max_cycles)?return 1:return 0;
}
