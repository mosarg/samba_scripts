#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;
use Switch;
use Server::Configuration qw($ldap);
use Server::Commands qw(hashNav);
use Server::LdapQuery qw(doOuExist getAllOu);
use Server::Samba4 qw(addS4Group deleteS4Group doS4GroupExist addS4Ou);
use Server::AdbOu qw(getAllOuAdb getOuByUsernameAdb getOuByUserIdAdb);

my $commands = "init,sync,list";

my $backend     = '';
my $all         = 0;
my $description = 'generic description';

( scalar(@ARGV) > 0 ) || die("Possibile commands are: $commands\n");

GetOptions(
	'backend=s'     => \$backend,
	'all'           => \$all,
	'description=s' => \$description
);
$backend or die("You must specify a backend\n");

switch ( $ARGV[0] ) {

	case 'sync' {
		listOu( \&createOu );
	}
	case 'list' {
		listOu( \&checkOu );
	}
	case 'init' {
		listOu( \&createOu );
	}
	else { die("$ARGV[0] is not a command!\n"); }
}

sub checkOu {
	my $ou = shift;
	my $format = { ok => 'green', unsynced => 'red' };
	
	my $status = doOuExist($ou) ? 'ok' : 'unsynced';

	switch ($backend) {
		case 'samba4' {
			print $ou
			  . " [".colored(uc($status) , $format->{$status} ) . "]\n";
		}
	}
}

sub createOu {
	my $ou     = shift;
	my $format = { ok => 'green', unsynced => 'red','already synced'=>'yellow' };
	my $status = doOuExist($ou) ? 'ok' : 'unsynced';
	switch ($backend) {
		case 'samba4' {
			if ( $status eq 'unsynced' ) {
				$status=addS4Ou( $ou, 'user' )?'ok':'unsynced';
			}else{
				$status='already synced';
			}
		print $ou." [".colored(uc($status),$format->{$status})."]\n";
		}
	}

}

sub listOu {
	my $action = shift;
	switch ($backend) {
		case 'samba4' {
			my $adbOu = getAllOuAdb('samba4');
			hashNav( $adbOu, '', $action );
		}
	}
}

