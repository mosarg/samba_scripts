package Server::Gapps;

use strict;

use Data::Dumper;
use warnings;
use experimental 'switch';
use Cwd;
use Server::Configuration qw($server $ldap);
use Server::LdapQuery qw(isPosix getGroup);
use Server::Commands qw(execute doFsObjectExist sanitizeString);
use feature "switch";
use Try::Tiny;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(changeGappsPassword);

my $gapps_user="$server->{virtualenvs}->{gestione_scuola} /opt/django_utils/user.py";
my $backendId='gapps';

sub changeGappsPassword{
	my $username=shift;
	my $password=shift;
	my $command="$gapps_user setgpassword $username --password \\\"$password\\\" ";
	execute($command,$backendId);
}


sub addGappsUser{
	
}

sub deleteGappsUser{
	
}


