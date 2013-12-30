package Server::Samba4;

use strict;
use warnings;
use Data::Dumper;
use feature "switch";
use Try::Tiny;
use Cwd;
use Server::Configuration qw($server $ldap);
use Server::LdapQuery qw(isPosix getGroup);
use Server::Commands qw(execute doFsObjectExist sanitizeString);
use Server::Actions qw(moveDir);
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(changeSamba4Password moveS4User addS4Ou doS4UserExist getNewUid  addS4User addS4Group   deleteS4User  setS4GroupMembership deleteS4Group doS4GroupExist updateS4Group getGroup updateS4User);


my $backendId='samba4';


sub changeSamba4Password{
	my $username=shift;
	my $password=shift;
	my $command="samba-tool user setpassword $username --newpassword=\'$password\' ";
	my $result=execute($command,$backendId);
	for($result){
		when(/short/){return 3;}
		when(/complexity/){return 4;}
		when(/OK/){return 1;}
		default {return 0;}
		}
	}
	




sub posixifyGroup {
	my $groupName = shift;
	my $gid       = shift;
	my $ldif      = "dn: cn=$groupName,$ldap->{'group_base'},$ldap->{'dir_base'}
changetype: modify
add: objectClass
objectClass: posixGroup
-
add: gidNumber
gidNumber: $gid";
	return ldbLoadLdif( $ldif, $gid );
}

sub posixifyUser {
	my $userDn   = shift;
	my $uid      = shift;
	my $gid      = shift;
	my $unixHome = shift;

	my $ldif = "dn: $userDn,$ldap->{'dir_base'}
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

return ldbLoadLdif( $ldif, $uid );
}


sub ldbLoadLdif {
	my $ldif       = shift;
	my $filePrefix = shift;

	my $fileName = "/tmp/$filePrefix.ldif";
	open( LDIF, ">$fileName" );
	print LDIF $ldif or die 'error';
	close(LDIF);

	my $command =
	  "scp $fileName " . $server->{'root'} . "@" . $server->{'fqdn'} . ":/tmp";
	my $output = `$command`;
	
	return execute(
"ldbmodify --url=ldap://$ldap->{'server_fqdn'} --user=$ldap->{'domain'}/$ldap->{'domain_admin'}%$ldap->{'bind_root_password'} $fileName",$backendId
	);
}

sub cleanNscdCache {
	execute('nscd --invalidate passwd',$backendId);
	execute('nscd --invalidate group',$backendId);
}

sub getNewUid {
	my $userName = shift;
	my $uid      = execute("wbinfo -i $userName | cut -d \":\" -f3",$backendId);
	chomp($uid);
	return $uid =~ /^\d+$/ ? $uid : 0;
}

sub getNewGid {
	my $groupName = shift;
	my $gid = execute("wbinfo --group-info=$groupName | cut -d \":\" -f 3",$backendId);
	chomp($gid);
	return $gid =~ /^\d+$/ ? $gid : 0;
}

sub getGid {
	my $groupName = shift;
	return execute(
		"\'echo -n \$(wbinfo --group-info=$groupName|cut -d \":\" -f3 -n)\'",$backendId);
}

sub getRid {
	my $groupName = shift;
	return execute(
"\'echo -n \$\(wbinfo --gid-to-sid=\$\(echo -n \$\(wbinfo --group-info=$groupName|cut -d \":\" -f3 -n\)\)|cut -d \"-\" -f 8\)\'",$backendId
	);
}

sub doS4UserExist {
	my $userName = shift;
	my $idReport = execute("id $userName",$backendId);
	$idReport =~ m/uid/ ? return 1 : return 0;
}

sub doS4GroupExist {
	my $group     = shift;
	my $groupData=getGroup($group);
	return $groupData->{gidNumber}?1:0;
	
}

sub getS4UnixHomeDir {
	my $userName = shift;
	my $ldbBaseCommand =
"ldbsearch --url=ldap://$ldap->{'server_fqdn'} --user=$ldap->{'domain'}/$ldap->{'domain_admin'}%$ldap->{'bind_root_password'}";
	return execute(
"\' echo -n \$($ldbBaseCommand cn=$userName | grep unix | cut -d \":\" -f2) \'",$backendId
	);
}

sub genS4HomeDir {
	my $user   = shift;
	my $ou     = $user->{account}->{ou};
	my $result = {};
	$ou =~ s/ou=//g;
	$ou = ( reverse( split( ',', $ou ) ) )[0];
	$result->{compact} = $ou;
	$result->{long} =
	  $server->{home_base} . "/$ou/" . $user->{account}->{username};
	$result->{base}  = $server->{home_base} . "/$ou";
	$result->{samba} = "\\\\"
	  . $server->{'windows_name'} . "\\"
	  . $server->{samba_home_prefix} . "\\"
	  . $ou . "\\"
	  . $user->{account}->{username};
	$result->{sambaprint} =
	    "\"\\\\\\\\\\\\\\\\"
	  . $server->{'windows_name'}
	  . "\\\\\\\\"
	  . $server->{samba_home_prefix}
	  . "\\\\\\\\"
	  . $ou
	  . "\\\\\\\\"
	  . $user->{account}->{username} . "\" ";
	return $result;
}

sub getGroupCard {
	my $group = shift;
	my @members =
	  split( ',',
		execute(" \' echo -n \$(getent group $group | cut -d \":\" -f4)\'",$backendId) );
	return scalar(@members);
}

sub deleteS4Group {
	my $group = shift;
	if ( getGroupCard($group) > 0 ) {
		return 3;
	}
	if ( doS4GroupExist($group) ) {
		execute("samba-tool group delete $group",$backendId);
		cleanNscdCache();
		return 1;
	}
	else { return 4; }
	return 0;
}

sub moveS4User {
	my $user  = shift;
	my $oldDn = shift;
	my $newDn = shift;

	#move samba user under new ou
	if ( $oldDn ne $newDn ) {
		 execute("samba-tool ou move $oldDn $newDn",$backendId);
	}
	else {
		return 0;
	}

	#move home directory
	my $oldUnixHomeDir = getS4UnixHomeDir( $user->{account}->{username} );
	my $newUnixHomeDir = ( genS4HomeDir($user) )->{long};

	if ( $oldUnixHomeDir ne $newUnixHomeDir ) {
		moveDir( $oldUnixHomeDir, $newUnixHomeDir );
		#set samba home dir
		setS4UnixHomeDir($user);
		return 1;
	}
	return 1;
}

sub deleteS4User {
	my $userName = shift;
	if ( !( doS4UserExist($userName) ) ) {
		return 0;
	}

	#remove home dir
	my $homeDir = getS4UnixHomeDir($userName);
	if ( doFsObjectExist( $homeDir, 'd' ) ) {
		execute("rm -rf $homeDir",$backendId);
	}

	#remove samba4 profile
	my $profileDir = $server->{profiles_dir} . "/" . $userName;
	if ( doFsObjectExist( $profileDir, 'd' ) ) {
		execute("rm -rf $profileDir\*",$backendId);
	}

	#delete user
	execute("samba-tool user delete $userName",$backendId);
	cleanNscdCache();
	return 1;
}

sub addS4Group {
	my $groupName = shift;
	my $command =
	  "samba-tool group add --mail-address $groupName@".$ldap->{default_mail}." --groupou " . $ldap->{'group_base'} . " $groupName";
	print $command;
	if ( doS4GroupExist($groupName) ) {
		return 2;
	}
	my $result = execute($command,$backendId);
	my $gid    = getNewGid($groupName);
	
	
	if ($gid) {
		posixifyGroup($groupName,$gid);
		cleanNscdCache();
		return 1;
	}
	else { return 0; }
}

sub setS4PrimaryGroup {
	my $user  = shift;
	my $group = shift;
	if ( !( doS4UserExist( $user->{account}->{username} ) ) ) { return 0; }
	if ( !( doS4GroupExist($group) ) ) { return 0; }
	my $gid = getGid($group);
	my $rid = getRid($group);
	execute("samba-tool group addmembers $group " . $user->{account}->{username} ,$backendId);

#Uncomment to set windows primary  group=linux primary group
my $ldif =
"dn: cn=$user->{account}->{username},$user->{account}->{ou},$ldap->{user_base},$ldap->{dir_base}
changetype: modify
replace: primaryGroupID
primaryGroupID: $rid
-
changetype: modify
replace: gidNumber
gidNumber: $gid";
#We are settings only unix primary group because of AD primary group backlinking problems
#my $ldif =
#"dn: cn=$user->{account}->{username},$user->{account}->{ou},$ldap->{user_base},$ldap->{dir_base}
#changetype: modify
#replace: gidNumber
#gidNumber: $gid";
ldbLoadLdif( $ldif, $gid );
$lidf="dn: cn=Domain users,$ldap->{group_base},$ldap->{dir_base}
changetype: modify
delete: member
member: cn=$user->{account}->{username},$user->{account}->{ou},$ldap->{user_base},$ldap->{dir_base}";
ldbLoadLdif( $ldif, $gid );
execute("samba-tool group addmembers Domain\\\\ users " . $user->{account}->{username} ,$backendId);
}

sub setS4UnixHomeDir {
	my $user = shift;

	my $homeDir = genS4HomeDir($user);

	my $ldif =
"dn: cn=$user->{account}->{username},$user->{account}->{ou},$ldap->{user_base},$ldap->{dir_base}
changetype: modify
replace: unixHomeDirectory
unixHomeDirectory: $homeDir->{long}
-
replace: homeDirectory
homeDirectory: $homeDir->{samba}";
	ldbLoadLdif( $ldif, $user->{account}->{username} );
}

sub setS4GroupMembership {
	my $user   = shift;
	my $groups = shift;
	my $error=1;
	if ( !( doS4UserExist($user) ) ) { return 0; }
	
	#all users members of Domain Users
	#push (@{$groups},"Domain Users");
		
	foreach my $group ( @{$groups} ) {
		if ( doS4GroupExist($group) ) {
			execute("samba-tool group addmembers $group $user",$backendId);	
		}
		else {
			$error=0;
		}
	}
	return $error;
}

sub updateS4Group{
	my $group=shift;
	my $groupData=getGroup($group);
	
	if($groupData){
		#posixify group
		print $group;
		if(!$groupData->{gidNumber}){
			my $gid    = getNewGid($group);
			posixifyGroup($group,$gid);
			$groupData->{gidNumber}=$gid;
		}		
	}else{
		print "Group $group not present\n";
	}
	
	return $groupData;
	
}



sub updateS4User{
	my $username=shift;
	my $container=shift;
	my $dn;
	my $homeDir;
	my $uid=getNewUid( $username);
	
	
	print "uid $uid\n";
	
	if($container){
		$dn="cn=".$username.","
		  ."ou=". $container.","
		  . $ldap->{user_base};
	$homeDir = genS4HomeDir({account=>{username=>$username,ou=>$container}});	
	$homeDir=$homeDir->{long};
	}else{
		$dn="cn=".$username.",". $ldap->{user_base};
		$homeDir=$server->{home_base} . "/". $username;
	}
	
	my $gid=getGid('Domain\ Users');
	
		
	posixifyUser($dn,$uid,$gid,$homeDir);
		
	
}



sub addS4Ou {
	my $ou   = shift;
	my $type = shift;
	my $command =
	    "samba-tool ou create $ou,"
	  . $ldap->{ $type . "_base" } . ","
	  . $ldap->{dir_base};
	my $result = execute($command,$backendId);
	return $result =~ m/created/ ? 1 : 0;
}

sub addS4User {
	my $user        = shift;
	my $group       = shift;
	my $extraGroups = shift;

	#define home dir
	my $homeDir = genS4HomeDir($user);

	#check if primary group exists
	if ( !( doS4GroupExist($group) ) ) {
		$user->{account}->{error} = 1;
		return $user;
	}

	
	my $command =
"samba-tool user add $user->{account}->{username} \'$user->{account}->{password}\' --userou $user->{account}->{ou},"
	  . $ldap->{user_base}
	  . " --surname=\\\""
	  .  $user->{surname} 
	  . "\\\" --use-username-as-cn";
	$command .=
	    " --given-name=\\\""
	  .  $user->{name} 
	  . "\\\" --profile-path=\"\\\\\\\\\\\\\\\\"
	  . $server->{windows_name}
	  . "\\\\\\\\"
	  . $server->{samba_profiles_path}
	  . "\\\\\\\\"
	  . $user->{account}->{username} . "\" ";
	$command .= " --home-drive=H: --home-directory=$homeDir->{sambaprint}";
	$command .=
" --department=$user->{account}->{ou} --description=$user->{userIdNumber}";
	$command.=" --mail-address=$user->{account}->{username}@".$ldap->{default_mail};

	#create user
	$user->{creationStatus} = execute($command,$backendId);

	#set user to no expire
	execute("samba-tool user setexpiry "
		  . $user->{account}->{username}
		  . " --noexpiry" ,$backendId);

	#set unix home dir

	$user->{account}->{unixHomeDir} = $homeDir->{long};

	#set unix account uid number

	$user->{account}->{backendUidNumber} =
	  getNewUid( $user->{account}->{username} );

	#add posix attributes

	print posixifyUser(
		"cn="
		  . $user->{account}->{username} . ","
		  . $user->{account}->{ou} . ","
		  . $ldap->{user_base},
		$user->{account}->{backendUidNumber},
		getGid($group), $user->{account}->{unixHomeDir}
	);

	#insert user into default groups
	setS4GroupMembership( $user->{account}->{username}, $extraGroups );
		
	### CHECK https://lists.samba.org/archive/samba-technical/2012-May/083285.html
	#set user primary group
	#setS4PrimaryGroup( $user, "Domain\\ Users" );
	setS4PrimaryGroup( $user, $group );
	
	
	
	#create user home directory
	if ( !doFsObjectExist( $user->{account}->{unixHomeDir}, 'd' ) ) {
		execute("mkdir -p $user->{account}->{unixHomeDir}",$backendId);
	}
	#clean nscdCache
	cleanNscdCache();
	#chown user home dir
	execute("chown "
		  . $user->{account}->{username} . ":"
		  . $group
		  . " $user->{account}->{unixHomeDir}" ,$backendId);
	#set account active
	$user->{account}->{active} = 1;
	return $user;
}

1;
