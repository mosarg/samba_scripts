package Server::Samba4;

use strict;
use warnings;
use Cwd;
use Server::Configuration qw($server $ldap);
use Server::Commands qw(execute doFsObjectExist sanitizeString);
require Exporter;


our @ISA       = qw(Exporter);
our @EXPORT_OK = qw( addS4Ou doS4UserExist getNewUid posixifyUser addS4User addS4Group getNewGid posixifyGroup setS4PrimaryGroup getGid getRid getS4UnixHomeDir deleteS4User getGroupCard setS4GroupMembership deleteS4Group doS4GroupExist);




sub posixifyGroup{
	my $groupName=shift;
	my $gid=shift;
	my $ldif=
"dn: cn=$groupName,$ldap->{'group_base'},$ldap->{'dir_base'}
changetype: modify
add: objectClass
objectClass: posixGroup
-
add: gidNumber
gidNumber: $gid";
return ldbLoadLdif($ldif,$gid);
}

sub posixifyUser{
	my $userDn=shift;
	my $uid=shift;
	my $gid=shift;
	my $unixHome=shift;
	
	my $ldif=
"dn: $userDn,$ldap->{'dir_base'}
changetype: modify
add: objectClass
objectClass: posixAccount
-
add: uidNumber
uidNumber: $uid
-
add: gidNumber
gidNumber: $gid
-
add:unixHomeDirectory
unixHomeDirectory: $unixHome
-
add: loginShell
loginShell: /bin/bash";

ldbLoadLdif($ldif,$uid);
}

sub ldbLoadLdif{
	 my $ldif=shift;
	 my $filePrefix=shift;
	
	  my $fileName="/tmp/$filePrefix.ldif";        
      open(LDIF ,">$fileName");
      print LDIF $ldif or die 'error';        
      close(LDIF);
	  	  
      my $command="scp $fileName ".$server->{'root'}."@".$server->{'fqdn'}.":/tmp";
      my $output=`$command`;
      
      return execute("ldbmodify --url=ldap://$ldap->{'server_fqdn'} --user=$ldap->{'domain'}/$ldap->{'domain_admin'}%$ldap->{'bind_root_password'} $fileName");
}

sub cleanNscdCache{
	execute('nscd --invalidate passwd');
	execute('nscd --invalidate group');
}

sub getNewUid{
	my $userName=shift;
	my $uid=execute("wbinfo -i $userName | cut -d \":\" -f3");
	chomp($uid);
	return $uid=~/^\d+$/?$uid:0;
}

sub getNewGid{
	my $groupName=shift;
	my $gid=execute("wbinfo --group-info=$groupName | cut -d \":\" -f 3");
	chomp($gid);
	return $gid=~/^\d+$/?$gid:0;
}

sub getGid{
	my $groupName=shift;
	return execute("\'echo -n \$(wbinfo --group-info=$groupName|cut -d \":\" -f3 -n)\'");
}

sub getRid{
	my $groupName=shift;
	return execute("\'echo -n \$\(wbinfo --gid-to-sid=\$\(echo -n \$\(wbinfo --group-info=$groupName|cut -d \":\" -f3 -n\)\)|cut -d \"-\" -f 8\)\'");
}

sub doS4UserExist{
	my $userName=shift;
	my $idReport=execute("id $userName");
	print $idReport;
	$idReport=~m/uid/ ? return 1:return 0;	
}

sub doS4GroupExist{
	my $group=shift;
	my $gidReport=execute("getent group|grep -c \^$group");
	chomp($gidReport);
	return $gidReport;
}

sub getS4UnixHomeDir{
	my $user=shift;
	my $ldbBaseCommand="ldbsearch --url=ldap://$ldap->{'server_fqdn'} --user=$ldap->{'domain'}/$ldap->{'domain_admin'}%$ldap->{'bind_root_password'}";
	return execute("\' echo -n \$($ldbBaseCommand cn=$user | grep unix | cut -d \":\" -f2) \'" );
}

sub getGroupCard{
	my $group=shift;
	my @members=split(',',execute(" \' echo -n \$(getent group $group | cut -d \":\" -f4)\'" ));
	return scalar(@members);
}

sub deleteS4Group{
	my $group=shift;
	if (getGroupCard($group)>0){
		print "Group not empty, cannot delete!\n";
		return;
	}
	execute("samba-tool group delete $group");
}

sub deleteS4User{
	
	my $user=shift;
	if (!(doS4UserExist($user))){print "User doesn't exist!"; return 0;}
	 #remove home dir
	 my $homeDir=getS4UnixHomeDir($user);
	 if (doFsObjectExist($homeDir,'d')){
	 	execute("rm -rf $homeDir");
	 }
	#remove samba4 profile
	my $profileDir=$server->{profiles_dir}."/".$user;
	if (doFsObjectExist($profileDir,'d')){
		execute("rm -rf $profileDir\*");
	}
	#delete user
	execute("samba-tool user delete $user");
	cleanNscdCache();
}

sub addS4Group{
	my $groupName=shift;
	my $command="samba-tool group add --groupou ".$ldap->{'group_base'}." $groupName";
	if(doS4GroupExist($groupName)){ 
		return 0;
	}
	my $result=execute($command);
	my $gid=getNewGid($groupName);
	print posixifyGroup($groupName,$gid);
	cleanNscdCache();
	return 1;
}

sub setS4PrimaryGroup{
	my $user=shift;
	my $group=shift;
	if (!(doS4UserExist($user->{account}->{username}))){ print "Cannot set primary group: user doesn't exist!\n"; return 0;}
	if (!(doS4GroupExist($group))){print "Canno set primary group: group doesn't exist!\n"; return 0;}
	my $gid=getGid($group);
	my $rid=getRid($group);
	print execute("samba-tool group addmembers $group ".$user->{account}->{username});	
	my $ldif=
"dn: cn=$user->{account}->{username},$user->{account}->{ou},$ldap->{'dir_base'}
changetype: modify
replace: primaryGroupID
primaryGroupID: $rid
-
changetype: modify
replace: gidNumber
gidNumber: $gid";
ldbLoadLdif($ldif,$gid);
}

sub setS4UnixHomeDir{
	my $user=shift;
	$user->{account}->{ou}=~m/^ou=(\w+),/;
	my $homeDir=$1;
	my $unixHomeDir=$server->{home_base}."/$homeDir/".$user->{account}->{username};
	my $sambaHomeDir="\\\\".$server->{windows_name}."\\".$server->{samba_home_base}."\\".$homeDir."\\".$user->{account}->{username};
	my $ldif=
"dn: cn=$user->{account}->{username},$user->{account}->{ou},$ldap->{dir_base}
changetype: modify
replace: unixHomeDirectory
unixHomeDirectory: $unixHomeDir
-
replace: homeDirectory
homeDirectory: $sambaHomeDir";
ldbLoadLdif($ldif,$user-> {account}->{username});
}

sub setS4GroupMembership{
	my $user=shift;
	my $groups=shift;
	if (!(doS4UserExist($user)) ){print "User dosen't exist!\n"; return 0;}
	foreach my $group (@{$groups}){
		if(doS4GroupExist($group)){
			execute("samba-tool group addmembers $group $user");
		}else{
			print "Group $group doesn't exist!\n";
		}
	}	
}

sub addS4Ou{
	my $ou=shift;
	my $type=shift;
	my $command="samba-tool ou create $ou,".$ldap->{$type."_base"}.",".$ldap->{dir_base};
	my $result=execute($command);
	return $result=~m/created/?1:0;
}

sub addS4User{
	my $user=shift;
	my $group=shift;
	my $extraGroups=shift;

	#define home dir	
	my $homeDir=$user->{account}->{ou};
	$homeDir=~s/ou=//g;
	$homeDir=(reverse(split(',',$homeDir)))[0];
	
	#check if primary group exists
	if(!(doS4GroupExist($group))) {
		return 0;
	}
	
	$user->{password}='Samback@000';
		
	my $command="samba-tool user add $user->{account}->{username} $user->{password} --userou $user->{account}->{ou},".$ldap->{user_base}." --surname=\"".sanitizeString($user->{surname})."\" --use-username-as-cn";
	$command.=" --given-name=\"".sanitizeString($user->{name})."\" --profile-path=\"\\\\\\\\\\\\\\\\".$server->{windows_name}."\\\\\\\\".$server->{samba_profiles_path}."\\\\\\\\".$user->{account}->{username}."\" " ;
	$command.=" --home-drive=H: --home-directory=\"\\\\\\\\\\\\\\\\".$server->{'windows_name'}."\\\\\\\\".$server->{samba_home_prefix}."\\\\\\\\$homeDir\\\\\\\\".$user->{account}->{username}."\" ";
	$command.=" --department=$user->{'meccanographic'} --description=$user->{'userIdNumber'}";
		
	
	#create user
	$user->{creationStatus}=execute($command);

	print $command." $user->{creationStatus} \n";

	#set user to no expire
	execute("samba-tool user setexpiry ".$user->{account}->{username}." --noexpiry");
	#set unix home dir
	$user->{account}->{unixHomeDir}=$server->{home_base}."/$homeDir/".$user->{account}->{username};
    #set unix account uid number
    
    $user->{account}->{backendUidNumber}=getNewUid($user->{account}->{username});
    #add posix attributes   
    
    posixifyUser("cn=".$user->{account}->{username}.",".$user->{account}->{ou}.",".$ldap->{user_base},$user->{account}->{backendUidNumber},getGid($group),$user->{account}->{unixHomeDir});
	
	#set user primary group
				
	setS4PrimaryGroup($user,$group);	
	#insert user into default groups
	setS4GroupMembership($user->{account}->{username},$extraGroups);
	
	#create user home directory
	if (!doFsObjectExist($user->{account}->{unixHomeDir},'d')){
		execute("mkdir -p $user->{account}->{unixHomeDir}");		
	}
	#clean nscdCache	
	cleanNscdCache();
	#chown user home dir
	execute("chown ".$user->{account}->{username}.":".$group." $user->{account}->{unixHomeDir}");
	#set account active
	$user->{account}->{active}=1;
	
	return $user;	
}


1;