package Client::Info;

use strict;
use warnings;
use DBI;
use DBD::mysql;
use Switch;
use WWW::Mechanize;
use Client::ParseLog qw(parseXml);
use Client::configuration qw($database  $client $remote_conf);
use Net::Ping;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK =
  qw(getDirSize incWpkgPkgRev getWpkgPkgRev isClientUp collectClientsPackagesInfo
  getPackageMismatch  get_client_info get_clients_info
  getClientConfig getWpkgConfig showClientConfig);

my $infodb_name = $database->{infodb}->{name};
my $infodb      =
"dbi:mysql:$database->{$infodb_name}->{name}:$database->{$infodb_name}->{host}:3306";
my $dbh_infodb = DBI->connect(
	$infodb,
	$database->{$infodb_name}->{username},
	$database->{$infodb_name}->{password}
  )
  or die "Can’t connect to DB\n";

my $dsn_wpkg =
  "dbi:mysql:$database->{wpkg}->{name}:$database->{wpkg}->{host}:3306";

sub getDirSize {
	my $dir = shift;

	if ( -d $dir ) {
		my $dir_size = `du -sb $dir`;
		if ( $dir_size =~ m/(\d+)/ ) {
			return $1;
		}
	}
	return '';
}

sub getWpkgPkgRev {
	my $package_id = shift;
	my $dbh_wpkg   = DBI->connect(
		$dsn_wpkg,
		$database->{wpkg}->{username},
		$database->{wpkg}->{password}
	  )
	  or die "Can’t connect to  DB\n";

	my $package_query =
	  "SELECT revision FROM packages WHERE id_text=\'$package_id\'";

	my $package_revision = $dbh_wpkg->prepare($package_query);
	$package_revision->execute();
	my @package_revision = $package_revision->fetchrow_array();
	return $package_revision[0];
}

sub incWpkgPkgRev {
	my $package_id = shift;
	my $dbh_wpkg   = DBI->connect(
		$dsn_wpkg,
		$database->{wpkg}->{username},
		$database->{wpkg}->{password}
	  )
	  or die "Can’t connect to DB\n";
	my $package_query =
	  "UPDATE packages SET revision=revision+1 WHERE id_text=\'$package_id\'";
	my $package_revision = $dbh_wpkg->prepare($package_query);
	$package_revision->execute();

}

sub setWpkgPkgRev {
	my $package_id = shift;
	my $revision   = shift;
	my $dbh_wpkg   = DBI->connect(
		$dsn_wpkg,
		$database->{wpkg}->{username},
		$database->{wpkg}->{password}
	  )
	  or die "Can’t connect to DB\n";
	my $package_query =
	  "UPDATE packages SET revision=$revision WHERE id_text=\'$package_id\'";
	my $package_revision = $dbh_wpkg->prepare($package_query);
	$package_revision->execute();
}

sub isClientUp {
	my $ping          = Net::Ping->new("icmp");
	my $currentClient = shift;
	if ( $ping->ping( $currentClient, '3' ) ) {
		print "$currentClient state: up\n";
	}
	else {
		print "$currentClient state: down\n";
	}
}

sub get_client_info {
	my $currentClient  = shift;
	my $computer_query = '';
	switch ($infodb_name) {
		case "ocsng" {
			$computer_query = "SELECT name,ipaddress,macaddr FROM networks LEFT JOIN hardware ON networks.hardware_id=hardware.id WHERE networks.ipaddress LIKE '%".$database->{$infodb_name}->{subnet}."%'
						       AND hardware.name=\'$currentClient\'";
		}
		case "unattended" {$computer_query ="SELECT computername,ip,mac FROM systems WHERE computername=\'$currentClient\'"; }
	}
	my $computer = $dbh_infodb->prepare($computer_query);
	$computer->execute();
	my @matchClients = $computer->fetchrow_array();
	return \@matchClients;
}

sub get_clients_info {
	my $computers_query = '';
	switch ($infodb_name) {
		case "ocsng" {$computers_query =
"SELECT name,ipaddress,macaddr FROM  networks LEFT JOIN hardware ON networks.hardware_id=hardware.id WHERE networks.ipaddress LIKE '%".$database->{$infodb_name}->{subnet}."%' ORDER BY hardware.name";}
		case "unattended"{
			my $lab=shift || die 'You must specify a  computer prefix';
			if ($client->{'tag'} eq 'service'){
				$computers_query ="SELECT computername,ip,mac FROM systems WHERE servicetag LIKE \'%$lab%\' ORDER BY computername";
			}else{
				$computers_query ="SELECT computername,ip,mac FROM systems WHERE computername LIKE \'%$lab%\' ORDER BY computername";
			}
			
		}
	}
	
	
	my $computers      = $dbh_infodb->prepare($computers_query);
	my @computers_list = ();
	$computers->execute();
	while ( my @computer = $computers->fetchrow_array() ) {
		push( @computers_list, \@computer );
	}
	return \@computers_list;
}

sub collectClientsPackagesInfo {
	my $clients  = shift;
	my $log_data = shift;
	my %clientsData;
	foreach my $currentClient ( @{$clients} ) {
		$clientsData{$currentClient} =
		  getPackageMismatch( $currentClient, $log_data );
	}
	return \%clientsData;
}

sub getPackageMismatch {
	my $currentClient = shift;
	my $log_data      = shift;
	my @clientStatus;

	my $serverPackages =
	  getClientConfig( $currentClient, 'packages', 'server' );
	my $clientPackages =
	  getClientConfig( $currentClient, 'packages', 'client' );

	$log_data->{$currentClient} = [];
	foreach my $package ( keys %{$serverPackages} ) {
		if ( defined( $clientPackages->{$package}->{'revision'} ) ) {
			if (
				!(
					$serverPackages->{$package}->{'revision'} eq
					$clientPackages->{$package}->{'revision'}
				)
			  )
			{
				push(
					@clientStatus,
					{
						"package"        => $package,
						"server_version" =>
						  $serverPackages->{$package}->{'revision'},
						"client_version" =>
						  $clientPackages->{$package}->{'revision'},
						'alert' => 1
					}
				);

				push(
					@{ $log_data->{$currentClient} },
					{
						'error'           => 'mismatch',
						'package'         => $package,
						'server_revision' =>
						  $serverPackages->{$package}->{'revision'},
						'client_revision' =>
						  $clientPackages->{$package}->{'revision'}
					}
				);

			}
			else {
				push(
					@clientStatus,
					{
						"package"        => $package,
						"server_version" =>
						  $serverPackages->{$package}->{'revision'},
						"client_version" =>
						  $clientPackages->{$package}->{'revision'},
						'alert' => 0
					}
				);
			}
			delete $clientPackages->{$package};
		}
		else {
			push(
				@clientStatus,
				{
					"package"        => $package,
					"server_version" =>
					  $serverPackages->{$package}->{'revision'},
					"client_version" => 'undef',
					'alert'          => 1
				}
			);
			push(
				@{ $log_data->{$currentClient} },
				{
					'error'    => 'not_present',
					'package'  => $package,
					'location' => 'client'
				}
			);
		}

	}
	foreach my $package ( keys %{$clientPackages} ) {

		push(
			@clientStatus,
			{
				"package"        => $package,
				"server_version" => 'undef',
				"client_version" => $clientPackages->{$package}->{'revision'},
				'alert'          => 1
			}
		);

		push(
			@{ $log_data->{$currentClient} },
			{
				'error'    => 'not_present',
				'package'  => $package,
				'location' => 'server'
			}
		);
	}
	return \@clientStatus;
}

sub getClientPackages {
	my $xmlData = shift;
	return $xmlData->{'package'};
}

sub showClientConfig {
	my $currentClient = shift;
	my $action        = shift;
	my $source        = shift;
	switch ($action) {
		case 'packages' {
			my $packages = getClientConfig( $currentClient, $action, $source );
			foreach ( keys %{$packages} ) {
				print "Package ", $_, " revision: ",
				  $packages->{$_}->{'revision'}, "\n";
			}
		}
	}
}

sub getClientConfig {
	my $currentClient = shift;
	my $action        = shift;
	my $source        = shift;
	switch ($action) {
		case 'packages' {
			if ( $source eq 'client' ) {
				my $xmlPackagesFile =
				    $client->{wpkg_xml_log_dir} . '/'
				  . $client->{wpkg_xml_log_prefix}
				  . $currentClient . '.xml';
				my $xmlData = parseXml($xmlPackagesFile);
				return getClientPackages($xmlData);
			}
			elsif ( $source eq 'server' ) {
				return getWpkgClientPackages($currentClient);
			}
		}
	}
}

sub getWpkgClientPackages {
	my $currentClient = shift;
	my $wpkgHosts     = getWpkgConfig('hosts');
	my $wpkgProfiles  = getWpkgConfig('profiles');
	my $wpkgPackages  = getWpkgConfig('packages');
	my $wpkgHost;
	my $tempPkg;
	my %clientPackages = ();
	foreach ( keys %{$wpkgHosts} ) {

		if ( $currentClient =~ m/$_/ ) {
			if ( $currentClient eq $_ ) {
				$wpkgHost = $wpkgHosts->{$currentClient};

				#print $_,' matches ', $currentClient,"\n";
				last;
			}
			$wpkgHost = $wpkgHosts->{$_};
		}
	}

	foreach my $profile ( @{ getWpkgHostProfiles($wpkgHost) } ) {
		foreach my $profileElements ( $wpkgProfiles->{$profile}->{'package'} ) {
			if ( ref($profileElements) eq 'HASH' ) {

				#print $profileElements->{'package-id'},"\n";
				$tempPkg =
				  getPackageById( $wpkgPackages,
					$profileElements->{'package-id'} );
				$clientPackages{ $tempPkg->{'long_name'} } = $tempPkg;

			}
			else {

				foreach ( @{$profileElements} ) {
					$tempPkg =
					  getPackageById( $wpkgPackages, $_->{'package-id'} );
					$clientPackages{ $tempPkg->{'long_name'} } = $tempPkg;

					#print $_->{'package-id'},"\n";
				}

			}
		}
	}
	return \%clientPackages;
}

sub getWpkgHostProfiles {
	my $host              = shift;
	my @assigned_profiles = ();
	push( @assigned_profiles, $host->{'profile-id'} );

	#print Dumper  $host->{'profile'};
	foreach ( keys %{ $host->{'profile'} } ) {
		if ( ref( $host->{'profile'}->{$_} ) eq 'HASH' ) {
			push( @assigned_profiles, $_ );
		}
		else {
			push( @assigned_profiles, $host->{'profile'}->{$_} );
		}
	}
	return \@assigned_profiles;
}

sub getWpkgConfig {
	my $config_element = shift;
	my $url            = $remote_conf->{ "wpkg_" . $config_element };
	my $remote_xml     = WWW::Mechanize->new( autocheck => 1 );
	$remote_xml->get($url);
	my $xmlData = parseXml( $remote_xml->content );
	return $xmlData->{ substr( $config_element, 0, -1 ) };
}

sub getPackageById {
	my $packages = shift;
	my $Id       = shift;
	my $currentPackage;
	foreach ( keys %{$packages} ) {

		if ( $packages->{$_}->{'id'} eq $Id ) {
			$currentPackage = $packages->{$_};
			$currentPackage->{'long_name'} = $_;
			last;
		}
	}
	return $currentPackage;
}

1;
