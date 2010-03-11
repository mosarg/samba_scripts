package Client::startstop;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use DBI;
use DBD::mysql;
use Net::Ping;

require Exporter;


our @ISA       = qw(Exporter Autoloader);
our @EXPORT_OK = qw(wakeup_clients checkclients_up turnoff_clients);

my $database          = 'ocsweb';
my $database_password = 'ocs';
my $database_user     = 'ocs';
my $dsn               = "dbi:mysql:$database:localhost:3306";
my $computers_query =
"SELECT name,ipaddress,macaddr FROM  networks LEFT JOIN hardware ON networks.hardware_id=hardware.id WHERE networks.ipaddress LIKE '%172%' ORDER BY hardware.name";
my $dbh = DBI->connect( $dsn, $database_user, $database_password )
  or die "Can’t connect to the DB\n";
my $all_woken_up   = 0;
my $off_computers  = 1;
my $wait_cycles    = 0;
my $ping_wait_time = 1;
my $broadcast      = '172.16.200.255';

my $computers = $dbh->prepare($computers_query);

sub wakeup_clients {
	my $ping = Net::Ping->new();
	$computers->execute();
	while ( my @computer = $computers->fetchrow_array() ) {

		print "Controllo computer $computer[0]\n";
		if ( $ping->ping( $computer[1], $ping_wait_time ) ) {
			print "Attivo\n";
		}
		else {
			print "Computer $computer[0] $computer[2] in fase di accensione\n";

			system("wakeonlan -i $broadcast $computer[2]");
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
		$computers->execute();
		while ( my @computer = $computers->fetchrow_array() ) {
			if ( !$ping->ping( $computer[1], $ping_wait_time ) ) {
				$off_computers++;
				print "Computer $computer[0] is still sleeping\n";
				system("wakeonlan -i $broadcast $computer[2]")
				  if $wait_cycles > 1;
			}
		}
		$wait_cycles++;
		print "Sleeping for 20 seconds\n";
		sleep 20;
	}
	undef($ping);
}


sub turnoff_clients {
	my $ping = Net::Ping->new();
	$computers->execute();
	while ( my @computer = $computers->fetchrow_array() ) {

		if ( $ping->ping( $computer[1], $ping_wait_time ) ) {
			print "Shutting down $computer[0]";
			system(
"/opt/scripts/samba/winexe --runas URUK/scriptadmin%Samback#666 -U URUK/scriptadmin%Samback#666 //$computer[1] \"shutdown -s -f\""
			);
		}

	}
}

1;
