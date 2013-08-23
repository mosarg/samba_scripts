package Server::Actions;

use strict;
use warnings;
use Cwd;
use Client::Log qw(transportMail);
use File::Copy;
use File::Path qw(make_path remove_tree);
use Getopt::Long;
use Server::Configuration qw($dirs $server $mail);
use Server::Commands qw(execute doFsObjectExist);
use Server::LdapQuery qw(getFreeDiskSpace getUserFromUname getUsersHome getUsersDiskProfiles);




require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(notifyDiskSpace cleanupOldProfiles cleanupDustbins cleanupPublicFolders cleanupDir cleanupOldProfiles moveDir);


sub cleanupDustbins{
	my $homes=getUsersHome();
	foreach my $home (@{$homes}){
		print "Now cleaning $home/$dirs->{dustbin}\n";		
		cleanupDir($home."/".$dirs->{dustbin});
	}
	
}

sub cleanupPublicFolders{
	foreach (keys %{$dirs->{public_folders}}){
		cleanupDir($dirs->{public_folders}->{$_});
		print $_,"\n";
	}
}

sub cleanupOldProfiles{
	my $username='';
	my $profiles=getUsersDiskProfiles();
	
	foreach my $userProfile (@{$profiles}){
		$userProfile=~ m/(\w+)$/;
		
		#print "User profile $1\n";
		if (!getUserFromUname($1)){
			if($userProfile ne ''){
			    print "I'm going to remove stale profile ",$server->{'profiles_dir'}."/".$userProfile,"\n";
			    removeDir($server->{'profiles_dir'}."/".$userProfile);
			}
		}
	}
	
}

sub notifyDiskSpace{
	my $currentDiskSpace=0;
	
	foreach my $mountPoint (@{$server->{'mount_points'}}){
		
		$currentDiskSpace=getFreeDiskSpace($mountPoint);
		
		if ($currentDiskSpace < $server->{'mount_point_size_thr'}){
			foreach my $recipient (@{$mail->{'server_notification_rec'}}){
			transportMail($recipient,$mail->{'mail_sender_address'},"$mountPoint full","Hurry up $mountPoint is filling quikly\n");
			print "$mountPoint over quota!\n";
			}
		
	}
	
}
return $currentDiskSpace,"\n";
}

sub cleanupDir{
	my $dir=shift;
	if (-d $dir){
		remove_tree($dir,{keep_root => 1});
	}else{
		print "$dir doesn't exist\n";
		return '';
	}
	return 1;
}

sub removeDir{
	my $dir=shift;
	if (-d $dir){
		remove_tree($dir,{keep_root => 0});		
	}else{
		print "$dir doesn't exist\n";
		return '';
	}
}

sub moveDir{
	my $oldPos=shift;
	my $newPos=shift;
	
	
if (doFsObjectExist($oldPos,'d')){
		execute("mv $oldPos $newPos");
		return 1;
	}
	return 0;
}

sub archiveDir{
	
}

1;
