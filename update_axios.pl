#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use threads;
use Client::startstop
  qw(wakeup_client wakeup_clients turnoff_clients turnoff_client);
use Client::commands qw(execute_command);
use Client::Info qw(incWpkgPkgRev getDirSize get_clients_info);
use Client::configuration qw($paths $log_info);
use Client::Log qw(transportMail doLog);
use Client::update qw( doAxiosUpdate );
use Switch;


my @work_machines;

my $updater      = 'wilos';
my $axios_pkg_id = 'axios';
my $group        = '';
my $all          = '';
my $client       = '';

GetOptions(
	'all'       => \$all,
	'group=s'   => \$group,
	'updater=s' => \$updater,
	'client=s'  => \$client
);

wakeup_client($updater);

sleep(20);

my $pre_update_size =getDirSize( $paths->{wpkg_server_dir} . "/data/axios/axiosupdate" );
print "Current axios updates dir size is $pre_update_size\n";
print "I'm going to download axios updated from internet\n";



execute_command( $updater, 'update_axios' );

sleep(10);

if ( getDirSize( $paths->{wpkg_server_dir} . "/data/axios/axiosupdate" ) >
	$pre_update_size )
{

	my @threads_array = ();

	foreach my $user_recipient ( @{ $log_info->{axios}->{email_recipient} } ) {
		transportMail(
			$user_recipient, $log_info->{'email_sender'},
			'Aggiornamento Axios',
'I programmi Axios sono stati aggiornati, potrebbe essere necessario effettuare un allineamento
	manuale del database'
		);
	}

	print "New updates present I'm going to install them\n";

	#spawn an update thread per client


	print "Waking up clients\n";
	
	wakeup_clients($group);
	
	sleep(360);
	
	if ($all){
		foreach (@{get_clients_info($group)}){
			push(@work_machines,$_->[1]);
		}
		
	}else{
	switch($client){
		case 'localhost'{print "No axios here!\n";}
		case /,/{
		@work_machines=	split( /,/, $client);
		}
		case /\|/{print "Use , as client separator\n";}
		
		else{
			push(@work_machines,$client)
		}
	}
	}

	foreach my $computer ( @work_machines ) {
		push( @threads_array,
			threads->create( \&doAxiosUpdate, $computer, 10 ) );
	}

	#join all threads
	foreach ( threads->list() ) {
		print $_->join() . "\n";
	}
	
}
else {
	doLog( 'mail', 'Axios update', 'Nessun nuovo aggiornamento presente' );
}

turnoff_clients($group);
