package Client::Info;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use DBI;
use DBD::mysql;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(substitute_path get_client_info get_clients_info);

use Client::configuration qw($paths $database $dsn);

my $dbh = DBI->connect( $dsn, $database->{username}, $database->{password} )
  or die "Can’t connect to the DB\n";

sub get_client_info {
	my $client         = shift;
	my $computer_query =
"SELECT name,ipaddress,macaddr FROM networks LEFT JOIN hardware ON networks.hardware_id=hardware.id WHERE networks.ipaddress LIKE '%172%'
						AND hardware.name=\'$client\'";
	my $computer = $dbh->prepare($computer_query);
	$computer->execute();
	my @current_client = $computer->fetchrow_array();
	return \@current_client;
}

sub get_clients_info {
	my $computers_query =
"SELECT name,ipaddress,macaddr FROM  networks LEFT JOIN hardware ON networks.hardware_id=hardware.id WHERE networks.ipaddress LIKE '%172%' ORDER BY hardware.name";
	my $computers      = $dbh->prepare($computers_query);
	my @computers_list = ();
	$computers->execute();
	while ( my @computer = $computers->fetchrow_array() ) {
		push( @computers_list, \@computer );
	}
	return \@computers_list;
}

# substitute_path is used to interpolate [<path>] inside commands


sub substitute_path {
	my $string = shift;
	foreach my $path (keys %{$paths} ) {
	 last if ( $string=~s/\[$path\]/$paths->{$path}/g );
					
	}
	return $string;
}
