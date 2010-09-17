#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Client::startstop
  qw(wakeup_client wakeup_clients turnoff_clients turnoff_client);
use Client::commands qw(execute_command);
use Client::Info qw(incWpkgPkgRev getDirSize);
use Client::configuration qw($paths $log_info);
use Client::Log qw(transportMail doLog);

my $updater      = 'wilos';
my $axios_pkg_id = 'axios';

GetOptions( 'updater=s' => \$updater);

wakeup_client($updater);
sleep(20);

my $pre_update_size =
  getDirSize( $paths->{wpkg_server_dir} . "/data/axios/axiosupdate" );
print "Current axios updates dir size is $pre_update_size\n";
print "I'm going to download axios updated from interner\n";

execute_command( $updater, 'update_axios' );

sleep(10);

if ( getDirSize( $paths->{wpkg_server_dir} . "/data/axios/axiosupdate" ) >
	$pre_update_size )
{

	foreach my $user_recipient ( @{ $log_info->{axios}->{email_recipient} } ) {
		transportMail($user_recipient, $log_info->{'email_sender'},
			'Aggiornamento Axios',
'I programmi Axios sono stati aggiornati, potrebbe essere necessario effettuare un allineamento
	manuale del database'
		);
	}

	print "New updates present I'm going to install them\n";
	turnoff_clients();
	sleep(20);
	incWpkgPkgRev($axios_pkg_id);
	print "Wpkg axios package revision incremented\n";
	wakeup_clients();
	print "Waiting for wpkg to do its job:)\n";
	sleep(1800);
	print "Turning off clients\n";
	turnoff_clients();
}else{
	doLog('mail','Axios update','Nessun nuovo aggiornamento presente');
}

