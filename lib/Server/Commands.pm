package Server::Commands;

use strict;
use warnings;
use Cwd;
use Server::Configuration qw($server $schema);
use DateTime;


require Exporter;

our @ISA       = qw(Exporter);

our @EXPORT_OK = qw(execute sanitizeString sanitizeUsername doFsObjectExist hashNav today sanitizeSubjectname);

my %accentedString=('a\'','à','e\'','é','u\'','ù','i\'','ì','o\'','ò',);
my %punctuationString=('\'','\\\'','\(','','\)','');
my %nastyString2=('\\\'','','\\\\','',']','','\s','',',','','\.','','\(','','\)','');

#d directory

sub doFsObjectExist{
	my $object=shift;
	my $type=shift;
	return execute("test ! -$type $object ; echo -n \$\?");
}


sub hashNav{
	my $list=shift;
	my $parent=shift;
	my $action=shift;
	my $backend=shift;
	my $legacy;
	foreach my $key (keys %{$list}){
	$legacy=$parent?$key.",".$parent:$key;
	$action->($backend,$legacy);	
		
		if(ref($list->{$key})eq 'HASH'){
			hashNav($list->{$key},$legacy,$action,$backend);
		}
	}
}


sub execute{
	my $command=shift;
	my $backend=shift;
	my $fqdn=$server->{'fqdn'};
	
	if ($backend){
		my $adbBackend=$schema->resultset('BackendBackend')->find({kind=>$backend});
		$fqdn=$adbBackend->server_fqdn();			
	}
	
	my $toExecute= "ssh ".$server->{'root'}."@".$fqdn." $command";
	if($server->{dry_run}){
		return $toExecute;
	}else{
		return `$toExecute  2>&1`;
	}
}



sub sanitizeUsername{
	my $username=shift;
	$username=lc($username);
	$username=~ tr/[é,à,è,ì,ò,ù,\-]/[e,a,e,i,o,u,,]/;
	
	foreach my $char (keys(%nastyString2)){
		$username=~s/$char/$nastyString2{$char}/g;
	} 
	$username=~ s/.{12}\K.*//s;
	return $username;
}

sub sanitizeSubjectname{
	my $subjectName=shift;
	$subjectName=sanitizeString(lc($subjectName));
	
	my @subelements=split(' ',$subjectName);
	
	my @finalName;
	
	foreach my $subElement (@subelements ){
		$subElement=~ tr/[é,à,è,ì,ò,ù,\-]/[e,a,e,i,o,u,,]/;
		foreach my $char (keys(%nastyString2)){
			$subElement=~s/$char/$nastyString2{$char}/g;
		} 
	$subElement=~ s/.{3}\K.*//s;
	if (length($subElement)==3){
		push(@finalName,$subElement);
	}
	
	}
	
		
	return join('_',@finalName);
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

sub today{
	my $dt = DateTime->today;
	return $dt->date;
}

1;