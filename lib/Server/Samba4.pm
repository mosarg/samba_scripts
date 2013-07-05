package Server::Samba4;

use strict;
use warnings;
use Cwd;
use Server::Configuration qw($server $ldap);
use Server::Commands qw(execute);
require Exporter;


our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(doS4UserExist getNewUid posixifyUser addS4User getNewGid posixifyGroup);





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
ldbLoadLdif($ldif,$gid);
	
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
      
      print execute("ldbmodify --url=ldap://$ldap->{'server_fqdn'} --user=$ldap->{'domain'}/$ldap->{'domain_admin'}%$ldap->{'bind_root_password'} $fileName")
	
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


sub doS4UserExist{
	my $userName=shift;
	my $idReport=execute("id $userName");
	$idReport=~m/uid/ ? return 1:return 0;	
}


sub deleteS4Group{
	
	
}


sub deleteS4User{
	
	
}


sub addS4Group{
	my $groupName;
	my $command="samba tool group add --groupou ".$ldap->{'group_base'}." $groupName";
	execute($command);
	my $gid=getNewGid($groupName);
	posixifyGroup($groupName,$gid);
	cleanNscdCache();
}

sub addS4User{
	my $userName=shift;
	my $password=shift;
	my $name=shift;
	my $surname=shift;
	my $userOu=shift;
	my $userIdNumber=shift;
	my $meccanographic=shift;
	$userOu=~m/^ou=(\w+),/;
	my $homeDir=$1;
	
	my $command="samba-tool user add $userName $password --userou $userOu --surname=$surname --use-username-as-cn";
	$command.=" --given-name=$name --profile-path=\"\\\\\\\\\\\\\\\\".$server->{'windows_name'}."\\\\\\\\".$server->{'samba_profiles_path'}."\" " ;
	$command.=" --home-drive=H: --home-directory=\"\\\\\\\\\\\\\\\\".$server->{'windows_name'}."\\\\\\\\".$server->{'samba_home_prefix'}."\\\\\\\\$homeDir\\\\\\\\$userName\" ";
	$command.=" --department=$meccanographic --description=$userIdNumber";
	print $command;
	execute($command);
    posixifyUser("cn=$userName,$userOu",getNewUid($userName),20513,$server->{'home_base'}."/$homeDir/".$userName);
	cleanNscdCache();
		
}





1;