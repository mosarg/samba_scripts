package Server::Commands;

use strict;
use warnings;
use Cwd;
use Server::Configuration qw($server);

require Exporter;

our @ISA       = qw(Exporter);

our @EXPORT_OK = qw(execute sanitizeString sanitizeUsername doFsObjectExist hashNav);

my %accentedString=('a\'','à','e\'','é','u\'','ù','i\'','ì','o\'','ò',);
my %punctuationString=('\'','\\\'','\s','');
my %nastyString2=('\\\'','','\\\\','',']','','\s','',',','');


sub doFsObjectExist{
	my $object=shift;
	my $type=shift;
	return execute("test ! -$type $object ; echo -n \$\?");
}



sub hashNav{
	my $list=shift;
	my $parent=shift;
	my $action=shift;
	my $legacy;
	foreach my $key (keys %{$list}){
	
	$legacy=$parent?$key.",".$parent:$key;
	
	$action->($legacy);	
		
		if(ref($list->{$key})eq 'HASH'){
			hashNav($list->{$key},$legacy,$action);
		}
	}
}


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
	foreach my $char (keys(%accentedString)){
		$data=~s/$char/$accentedString{$char}/g;
	} 
	foreach my $char (keys(%punctuationString)){
		$data=~s/$char/$punctuationString{$char}/g;
	} 
	return $data;
}

1;