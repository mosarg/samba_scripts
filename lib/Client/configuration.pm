package Client::configuration;
use strict;
use warnings;
use YAML::XS qw(LoadFile);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK =qw($log_info $reports $paths $remote_share $remote_executer
				   $domain $network_user $remote_user $remote_password 
				   $database $wsus_log $client $remote_conf);

my %Config = %{ LoadFile('/opt/samba_scripts/configuration.yaml') };

our $remote_executer = $Config{remote_executer};
our $domain          = $Config{domain};
our $network_user    = $Config{network_user};
our $remote_user     = $Config{remote_user};
our $remote_password = $Config{remote_password};
our $database        = $Config{database};
our $remote_share    = $Config{remote_share};
our $paths           = $Config{paths};
our $client          = $Config{client};
our $remote_conf     = $Config{remote_conf};
our $reports		 = $Config{reports};
our $wsus_log 		 = $Config{wsus_log};
our $log_info		 = $Config{log_info};
