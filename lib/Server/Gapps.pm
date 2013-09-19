package Server::Django;

use strict;
use warnings;
use Data::Dumper;

use Cwd;
use Server::Configuration qw($server $ldap);
use Server::LdapQuery qw(isPosix getGroup);
use Server::Commands qw(execute doFsObjectExist sanitizeString);
use feature "switch";
use Try::Tiny;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(addDjangoUser deleteDjangoUser doDjangoUserExist changeDjangoPassword);

my $django_user="$server->{virtualenvs}->{gestione_scuola} /opt/django_utils/user.py";
my $backendId='gapps';

sub changeGappsPassword{
	
		
}


sub addGappsUser{
	
}

sub deleteGappsUser{
	
}


