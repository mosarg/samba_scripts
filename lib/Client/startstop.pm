package Client::startstop;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Net::Ping;
use Client::RemoteExecution qw(execute_client_cmd);
use Client::Info qw(get_client_info get_clients_info);
use Client::configuration qw($client);
require Exporter;
use threads;


our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(wakeup_client wakeup_clients checkclients_up turnoff_clients restart_client turnoff_client);

 
my $all_woken_up   = 0;
my $off_computers  = 1;
my $wait_cycles    = 0;
my $ping_wait_time = 1;


sub wakeup_client{
	my $current_client=shift;
	my $ping = Net::Ping->new();
	my $wait_cycles=0;
	my $tmp_broadcast='';
	my @current_client = @{get_client_info($current_client)};
	
	if (!$current_client[0]) {
		print "$current_client: is not registered\n";
		return
	} 
	$tmp_broadcast=$current_client[1];
	$tmp_broadcast=~s/\d+$/255/;
	print "$current_client[0]: waking up\n";
	system("wakeonlan -i $tmp_broadcast $current_client[2]");
	while ((!$ping->ping( $current_client, $ping_wait_time ) )&&($wait_cycles<20)){
		print "$current_client: waking up\n";
		sleep 10;
		$wait_cycles++;
	}
	print "$current_client[0] ($current_client[1]): up\n";
}
sub wakeup_clients {
	my $group=shift||'';
	my $tmp_broadcast='';
	my $ping = Net::Ping->new();
	foreach  my $computer (@{get_clients_info($group)}) {
		print "Controllo computer $computer->[0]\n";
		$tmp_broadcast=$computer->[1];
	    $tmp_broadcast=~s/\d+$/255/;

		if ( $ping->ping( $computer->[1], $ping_wait_time ) ) {
			print "Active\n";
		}
		else {
			print "Computer $computer->[0] $computer->[2] wake up phase\n";
			system("wakeonlan -i $tmp_broadcast $computer->[2]");
		}
	}
	undef($ping);
}
sub checkclients_up {
	my $group=shift||'';
	my $ping          = Net::Ping->new();
	my $off_computers = 1;
	my $tmp_broadcast='';
	$ping->port_number('139');
	while ( ( $off_computers > 0 ) && ( $wait_cycles < 10 ) ) {
		$off_computers = 0;
		print "wait cycle $wait_cycles/10\n";
		foreach my $computer (@{get_clients_info($group)}) {
			$tmp_broadcast=$computer->[1];
	    	$tmp_broadcast=~s/\d+$/255/;
			
			if ( !$ping->ping( $computer->[1], $ping_wait_time ) ) {
				$off_computers++;
				print "$computer->[0]: still sleeping\n";
				system("wakeonlan -i $tmp_broadcast $computer->[2]")
				  if $wait_cycles > 1;
			}
		}
		$wait_cycles++;
		print "sleeping for 20 seconds\n";
		sleep 20;
	}
	undef($ping);
}
sub turnoff_client{
	my $ping          = Net::Ping->new();
	my $current_client=shift;
	my $wait_cycles=0;

	print "$current_client: shutting down\n";
	execute_client_cmd($current_client,"shutdown -s -f  -t $client->{shutdown_time}");
	while (( $ping->ping( $current_client, $ping_wait_time ) )&&($wait_cycles<20)){
		print "$current_client: shutdown fase\n";
		sleep 10;
		$wait_cycles++;
	}
	print "$current_client: state down\n";
}
sub restart_client{
	my $ping          = Net::Ping->new();
	my $current_client=shift;
	my $wait_cycles=0;
	print "$current_client: restarting\n";
	execute_client_cmd($current_client,'shutdown -r -f');
	while ( ($ping->ping( $current_client, $ping_wait_time ))&&($wait_cycles<20) ){
		print "$current_client: rebooting\n";
		$wait_cycles++;
		sleep 10;
	}
	
}
sub turnoff_clients {
	my $group=shift||'';
	
	my @threads_array = ();
	foreach my $computer (@{get_clients_info($group)} ) {
		push( @threads_array,
		threads->create( \&turnoff_client, $computer->[1]) );
	
	}
	foreach ( threads->list() ) {
	print $_->join() . "\n";
	}
}

1;
