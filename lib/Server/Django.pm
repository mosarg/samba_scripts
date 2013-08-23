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
our @EXPORT_OK = qw(addDjangoUser deleteDjangoUser doDjangoUserExist);
my $django_user="python /opt/django_utils/user.py";


sub addDjangoUser{
	my $user=shift;
	
	my $command="$django_user create $user->{account}->{username}";
			$command.=" --name \\\"$user->{name}\\\" --surname \\\"$user->{surname}\\\"";
			$command.=" --email \\\"$user->{account}->{username}\@".$ldap->{default_mail}."\\\"";
			$command.=" --password \\\"$user->{account}->{password}\\\"";
	my $result=execute($command);
}

sub deleteDjangoUser{
	my $username=shift;
	my $command="$django_user delete $username";
	
	return execute($command);
		
}

sub doDjangoUserExist{
	my $username=shift;
	my $command="$django_user check $username";
	
	my $result=execute($command);
	for($result){
		when (/user present/){return 1;}
		when (/user not found/){return 0;}
		default {return 5;}
	}
}