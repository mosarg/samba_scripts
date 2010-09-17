package Server::Configuration;

use strict;
use warnings;
use YAML::XS qw(LoadFile);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK =qw($ldap_users $ldap $dirs $server $mail);

my %Config = %{ LoadFile('/opt/samba_scripts/server_configuration.yaml') };

our $ldap			  =$Config{ldap};
our $dirs			  =$Config{dirs};
our $server			  =$Config{server};
our $mail			  =$Config{mail};
our $ldap_users		  =$Config{ldap_users};

1;