package Server::Actions;

use strict;
use warnings;
use Cwd;
use File::Copy;
use File::Path qw(make_path remove_tree);
use Getopt::Long;
use Server::Configuration qw($dirs);
use Server::Query qw(getUsersHome);



require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(cleanupDustbins cleanupPublicFolders cleanupDir);


sub cleanupDustbins{
	my $homes=getUsersHome();
	foreach my $home (@{$homes}){
		print "Now cleaning $home / $dirs->{dustbin}\n";		
		cleanupDir($home."/".$dirs->{dustbin});
	}
	
}

sub cleanupPublicFolders{
	foreach (keys %{$dirs->{public_folders}}){
		cleanupDir($dirs->{public_folders}->{$_});
		print $_,"\n";
	}
}

sub cleanupDir{
	my $dir=shift;
	if (-d $dir){
		remove_tree($dir,{keep_root => 1});
	}else{
		print "$dir doesn't exists\n";
		return '';
	}
	return 1;
}

sub removeDir{
	my $dir=shift;
	if (-d $dir){
		remove_tree($dir,{keep_root => 0});		
	}else{
		return '';
	}
}

sub moveDir{
	
}


sub archiveDir{
	
}

1;
