package Client::startstop;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Net::Ping;
use Client::RemoteExecution qw(execute_client_cmd);
use Client::Info qw(get_client_info get_clients_info);
require Exporter;


our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(wakeup_client wakeup_clients checkclients_up turnoff_clients restart_client turnoff_client);



  
my $all_woken_up   = 0;
my $off_computers  = 1;
my $wait_cycles    = 0;
my $ping_wait_time = 1;
my $broadcast      = '172.16.200.255';




sub wakeup_client{
	my $client=shift;
	my $ping = Net::Ping->new();
	my $wait_cycles=0;
	my @current_client = @{get_client_info($client)};
	
	if (!$current_client[0]) {
		print "Client $client is not registered\n";
		return
	} 
	
	print "Waking up $current_client[0]\n";
	system("wakeonlan -i $broadcast $current_client[2]");
	while ((!$ping->ping( $client, $ping_wait_time ) )&&($wait_cycles<20)){
		print "Waiking up\n";
		sleep 10;
		$wait_cycles++;
	}
	print "Client $current_client[0] is now up\n";
}


sub wakeup_clients {
	my $ping = Net::Ping->new();
	foreach  my $computer (@{get_clients_info()}) {
		print "Controllo computer $computer->[0]\n";
		if ( $ping->ping( $computer->[1], $ping_wait_time ) ) {
			print "Attivo\n";
		}
		else {
			print "Computer $computer->[0] $computer->[2] in fase di accensione\n";

			system("wakeonlan -i $broadcast $computer->[2]");
		}
	}
	undef($ping);
}

sub checkclients_up {
	my $ping          = Net::Ping->new();
	my $off_computers = 1;
	$ping->port_number('139');
	while ( ( $off_computers > 0 ) && ( $wait_cycles < 10 ) ) {
		$off_computers = 0;
		print "Wait cycle n.$wait_cycles\n";
		foreach my $computer (@{get_clients_info()}) {
			if ( !$ping->ping( $computer->[1], $ping_wait_time ) ) {
				$off_computers++;
				print "Computer $computer->[0] is still sleeping\n";
				system("wakeonlan -i $broadcast $computer->[2]")
				  if $wait_cycles > 1;
			}
		}
		$wait_cycles++;
		print "Sleeping for 20 seconds\n";
		sleep 20;
	}
	undef($ping);
}
sub turnoff_client{
	my $ping          = Net::Ping->new();
	my $client=shift;
	my $wait_cycles=0;
	print "Shutting down $client\n";
	execute_client_cmd($client,'shutdown -s -f');
	while (( $ping->ping( $client, $ping_wait_time ) )&&($wait_cycles<20)){
		print "Shutting down\n";
		sleep 10;
		$wait_cycles++;
	}
	print "Client $client is now down\n";
}
sub restart_client{
	my $ping          = Net::Ping->new();
	my $client=shift;
	my $wait_cycles=0;
	print "Restarting $client\n";
	execute_client_cmd($client,'shutdown -r -f');
	while ( ($ping->ping( $client, $ping_wait_time ))&&($wait_cycles<20) ){
		print "Rebooting\n";
		$wait_cycles++;
		sleep 10;
	}
	
}
sub turnoff_clients {
	foreach my $computer (@{get_clients_info()} ) {
	turnoff_client($computer->[1]);
	}
}

1;
