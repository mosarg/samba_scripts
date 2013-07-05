package Server::Commands;

use strict;
use warnings;
use Cwd;
use Server::Configuration qw($server);

require Exporter;

our @ISA       = qw(Exporter);

our @EXPORT_OK = qw(execute sanitizeString sanitizeUsername);

my %nastyString=('a\'','à','e\'','é','u\'','ù','i\'','ì','o\'','ò','\'','\\\'');
my %nastyString2=('\\\'','','\\\\','',']','','\s','',',','');

sub execute{
	my $command=shift;
	my $toExecute= "ssh ".$server->{'root'}."@".$server->{'fqdn'}." $command";
	return `$toExecute  2>&1`;
}



sub sanitizeUsername{
	my $username=shift;
	$username=lc($username);
	$username=~ tr/[à,è,ì,ò,ù,\-]/[a,e,i,o,u,,]/;
	
	foreach my $char (keys(%nastyString2)){
		$username=~s/$char/$nastyString2{$char}/g;
	} 
	$username=~ s/.{10}\K.*//s;
	return $username;
}


sub sanitizeString{
	my $data=shift;
	foreach my $char (keys(%nastyString)){
		$data=~s/$char/$nastyString{$char}/g;
	} 
	return $data;
}

1;