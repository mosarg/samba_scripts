package Server::Configuration;

use strict;
use warnings;
use YAML::XS qw(LoadFile);
use Db::Django;
require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK =qw($schema $programs $ldap_users $ldap $dirs $server $mail $ais $adb);

my %Config = %{ LoadFile('/etc/samba_scripts/server_configuration.yaml') };

our $ldap			  =$Config{ldap};
our $dirs			  =$Config{dirs};
our $server			  =$Config{server};
our $mail			  =$Config{mail};
our $ldap_users		  =$Config{ldap_users};
our $programs		  =$Config{programs};
our $ais			  =$Config{ais};
our $adb			  =$Config{adb};

our $schema=Db::Django->connect('dbi:mysql:gestione_scuola','mosa','sambackett');

1;