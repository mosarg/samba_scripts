package Server::Samba4;

use strict;
use warnings;
use Cwd;
use Server::Configuration qw($server $ldap);
use Server::Commands qw(execute doFsObjectExist);
require Exporter;


our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(doS4UserExist getNewUid posixifyUser addS4User addS4Group getNewGid posixifyGroup setS4PrimaryGroup getGid getRid getS4UnixHomeDir deleteS4User getGroupCard setS4GroupMembership deleteS4Group doS4GroupExist);




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
	return $uid;
}

sub getNewGid{
	my $groupName=shift;
	my $gid=execute("wbinfo --group-info=$groupName | cut -d \":\" -f 3");
	chomp($gid);
	return $gid;
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
		print "Group already exists!\n";
		return 0;
	}
	print execute($command);
	my $gid=getNewGid($groupName);
	print posixifyGroup($groupName,$gid);
	cleanNscdCache();
	return 1;
}


sub setS4PrimaryGroup{
	my $user=shift;
	my $group=shift;
	if (!(doS4UserExist($user->{uName}))){ print "Cannot set primary group: user doesn't exist!\n"; return 0;}
	if (!(doS4GroupExist($group))){print "Canno set primary group: group doesn't exist!\n"; return 0;}
	my $gid=getGid($group);
	my $rid=getRid($group);
	print execute("samba-tool group addmembers $group ".$user->{uName});	
	my $ldif=
"dn: cn=$user->{uName},$user->{ou},$ldap->{'dir_base'}
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
	$user->{'ou'}=~m/^ou=(\w+),/;
	my $homeDir=$1;
	my $unixHomeDir=$server->{home_base}."/$homeDir/".$user->{uName};
	my $sambaHomeDir="\\\\".$server->{windows_name}."\\".$server->{samba_home_base}."\\".$homeDir."\\".$user->{uName};
	my $ldif=
"dn: cn=$user->{uName},$user->{ou},$ldap->{dir_base}
changetype: modify
replace: unixHomeDirectory
unixHomeDirectory: $unixHomeDir
-
replace: homeDirectory
homeDirectory: $sambaHomeDir";
ldbLoadLdif($ldif,$user-> {uName});
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


sub addS4User{
	my $user=shift;
	my $group=shift;
	my $extraGroups=shift;
	$user->{'ou'}=~m/^ou=(\w+),/;
	my $homeDir=$1;
	if(!(doS4GroupExist($group))) {
		return 0;
	}
	my $command="samba-tool user add $user->{uName} $user->{password} --userou $user->{ou} --surname=".$user->{surname}." --use-username-as-cn";
	$command.=" --given-name=".$user->{name}." --profile-path=\"\\\\\\\\\\\\\\\\".$server->{windows_name}."\\\\\\\\".$server->{samba_profiles_path}."\\\\\\\\".$user->{uName}."\" " ;
	$command.=" --home-drive=H: --home-directory=\"\\\\\\\\\\\\\\\\".$server->{'windows_name'}."\\\\\\\\".$server->{samba_home_prefix}."\\\\\\\\$homeDir\\\\\\\\".$user->{uName}."\" ";
	$command.=" --department=$user->{'meccanographic'} --description=$user->{'idNumber'}";
	
	#create user
	execute($command);
	#set user to no expire

	execute("samba-tool user setexpiry ".$user->{uName}." --noexpiry");
	
	my $unixHomeDir=$server->{home_base}."/$homeDir/".$user->{uName};
    posixifyUser("cn=".$user->{uName}.",".$user->{ou},getNewUid($user->{uName}),20513,$unixHomeDir);

	setS4PrimaryGroup($user,$group);	
	setS4GroupMembership($user->{uName},$extraGroups);
		
	
	if (!doFsObjectExist($unixHomeDir,'d')){
		execute("mkdir -p $unixHomeDir");		
	}
		
	cleanNscdCache();
	execute("chown ".$user->{uName}.":".$group." $unixHomeDir");
		
}


1;