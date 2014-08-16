package Server::Django;

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
our @EXPORT_OK = qw(addDjangoUser deleteDjangoUser doDjangoUserExist changeDjangoPassword);

my $django_user="$server->{virtualenvs}->{gestione_scuola} /opt/django_utils/user.py";

my $backendId='django';



sub changeDjangoPassword{
	my $username=shift;
	my $password=shift;
	my $command="$django_user setpassword $username --password \\\"$password\\\" ";
	print execute($command,$backendId);
		
}


sub addDjangoUser{
	my $user=shift;
	
	
	my $command="$django_user add $user->{account}->{username}";
			$command.=" --name=\\\"$user->{name}\\\" --surname=\\\"$user->{surname}\\\"";
			$command.=" --email=\\\"$user->{account}->{username}\@".$ldap->{default_mail}."\\\"";
			$command.=" --password=\\\"$user->{account}->{password}\\\"";
	my $result=execute($command,$backendId);
	
	for($result){
		when (/duplicate/){ $user->{creationStatus} = 2; }
		when (/error/) { $user->{creationStatus} = 0; }
		when (/(\d+)/) {
			$user->{creationStatus}=1;
			chomp($_);
			$user->{account}->{backendUidNumber}=$_;
		}
		default   { $user->{creationStatus} =   0; }
	}
	
	return $user;
}

sub deleteDjangoUser{
	my $username=shift;
	my $command="$django_user delete $username";
	my $result=execute($command,$backendId);
	for ($result){
		when(/successfull/){
			return 1;
		}
		when(/not/){
			return 0;
		}
	}
	return 0;
}

sub doDjangoUserExist{
	my $user=shift;
	my $command="$django_user check $user->{account}->{username}";
	
	my $result=execute($command,$backendId);
	for($result){
		when (/user present/){return 1;}
		when (/user not found/){return 0;}
		default {return 5;}
	}
}