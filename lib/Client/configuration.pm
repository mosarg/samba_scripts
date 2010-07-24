package Client::configuration;
use strict;
use warnings;
use YAML::XS qw(LoadFile);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK =
  qw($remote_share $remote_executer $domain $network_user $remote_user $remote_password $database $dsn $wsus_log);

my %Config =
  %{ LoadFile('/opt/samba_scripts/configuration.yaml') };

our $remote_executer = $Config{remote_executer};
our $domain          = $Config{domain};
our $network_user    = $Config{network_user};
our $remote_user     = $Config{remote_user};
our $remote_password = $Config{remote_password};
our $database        = $Config{database};
our $remote_share	 = $Config{remote_share};

#our $database_password = 'ocs';
#our $database_user     = 'ocs';
our $dsn      = "dbi:mysql:$database->{name}:localhost:3306";
our $wsus_log = $Config{wsus_log};
