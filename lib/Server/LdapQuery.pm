package Server::LdapQuery;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Net::LDAP;
use Data::Dumper;
use Filesys::DiskSpace;
use Data::Structure::Util qw( unbless );
use feature "switch";
use Try::Tiny;
use Server::Configuration qw($server $ldap $ldap_users);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(getGroup isPosix getFreeDiskSpace getUserFromUname getUsersDiskProfiles getUserFromHumanName getUsers getUsersHome getUserHome getClassHomes getGroupMembers getUserFromUid unbindLdap doOuExist getAllOu getUserBaseDn);

my $connectionStatus='ok';
my $ldapConnection = Net::LDAP->new( $ldap->{'server'} );

#bind to AD ldap server as Administrator
if($ldapConnection){
	$ldapConnection->bind(
		$ldap->{'bind_root'} . ',' . $ldap->{'dir_base'},
		password => $ldap->{'bind_root_password'}
		);
}


sub getUsers {
	my $dn;
	my $userObjects;
	my %current_users;
	foreach my $group ( @{ $ldap_users->{ou} } ) {
		$dn = "ou=$group," . $ldap->{'user_base'} . ',' . $ldap->{'dir_base'};

		$userObjects = $ldapConnection->search(
			base   => "$dn",
			scope  => 'sub',
			filter => "objectclass=posixAccount",
		);

		$current_users{$group} = [];
		foreach ( $userObjects->entries() ) {

			push(
				@{ $current_users{$group} },
				{
					uid    => $_->get_value( $ldap->{'uid_map'} ),
					script => $_->get_value( $ldap->{'script'} ) || 'empty'
				}
			);
		}
	}
	return \%current_users;
}

sub getUserHome {
	my $user = shift;

	if ( !$user ) { return ''; }
	my $dn         = $ldap->{'user_base'} . ',' . $ldap->{'dir_base'};
	my $userObject = $ldapConnection->search(
		base   => "$dn",
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) ("
		  . $ldap->{'uid_map'}
		  . "=$user)",
	);
	return ( $userObject->entries() )[0]->get_value( $ldap->{'home_map'} );
}

sub getUserLdapProfile {

}


sub getUsersHome {
	my $dn = $ldap->{'user_base'} . ',' . $ldap->{'dir_base'};
	my @homes;
	my $userObjects = $ldapConnection->search(
		base   => "$dn",
		scope  => 'sub',
		filter => "objectclass=posixAccount",
	);

	$userObjects->code && die $userObjects->error;
	foreach my $entry ( $userObjects->entries ) {
		push( @homes, $entry->get_value( $ldap->{'home_map'} ) );
	}
	return \@homes;
}


sub getUsersDiskProfiles {
	my @profiles = execute( "ls " . $server->{'profiles_dir'} );

	#shift shift @profiles;
	chomp @profiles;
	return \@profiles;
}

sub getClassHomes {
	my $class  = shift;
	my $school = shift;
	my @homes;
	my @attrs = [ 'dn', $ldap->{'home_map'}, 'sn', $ldap->{'uid_map'} ];
	my $dn =
	    "ou=$class,ou=$school,"
	  . $ldap->{'user_base'} . ','
	  . $ldap->{'dir_base'};

	$ldapConnection->bind;
	my $userObjects = $ldapConnection->search(
		base   => "$dn",
		scope  => 'sub',
		filter => "objectclass=posixAccount"
	);

	$userObjects->code && die $userObjects->error;
	foreach my $entry ( $userObjects->entries ) {
		push( @homes, $entry->get_value( $ldap->{'home_map'} ) );
	}
	return \@homes;
}

sub getGroupMembers {

	#$ldapConnection->bind;
	my $group = shift;
	my @members;
	my $mesg = $ldapConnection->search(
		base   => $ldap->{'group_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixGroup) (cn=$group)"
	);
	$mesg->code && die $mesg->error;
	my $i = 0;
	foreach my $entry ( $mesg->entries ) {

		push( @members, $entry->get_value( $ldap->{'memberuid_map'} ) );
	}
	return \@members;
}

sub getUserFromUid {
	my $uid = shift;

	#$ldapConnection->bind;
	my $data = $ldapConnection->search(
		base   => $ldap->{'user_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) (uidNumber=$uid)"
	);
	$data->code && die $data->error;
	my @output = $data->entries();
	if (@output) {
		return $output[0]->get_value( $ldap->{'uid_map'} );
	}
	else {
		return '';
	}
}

sub getUserFromUname {
	my $uname = shift;

	my $data = $ldapConnection->search(
		base   => $ldap->{'user_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) ("
		  . $ldap->{'uid_map'}
		  . "=$uname)"
	);
	$data->code && die $data->error;
	my @output = $data->entries();
	if (@output) {
		return $output[0]->get_value( $ldap->{'uid_map'} );
	}
	else {
		return 0;
	}
}

sub getUserFromHumanName {
	my $name    = shift;
	my $surname = shift;
	$ldapConnection->bind;
	my $data = $ldapConnection->search(
		base   => $ldap->{'user_base'} . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		filter => "&(objectclass=posixAccount) (cn=$name $surname)"
	);
	$data->code && die $data->error;
	my @output = $data->entries();
	if (@output) {
		return $output[0]->get_value( $ldap->{'uid_map'} );
	}
	else {
		return '';
	}
}


sub doOuExist{
	my $ouString=shift;
	my @ouName=split(',',$ouString);
	my $ouName=scalar(@ouName)>1?shift(@ouName):$ouString;
		
	#my $ouBase=shift;

	my $data = $ldapConnection->search(
		base   => $ldap->{'dir_base'},
		scope  => 'sub',
		attrs => ['distinguishedName'],
		filter => "&(objectclass=organizationalUnit) ($ouName)"
	);
	$data->code && die $data->error;
		
	if(( $data->entries() )[0]){
		return ( $data->entries() )[0]->get_value('distinguishedName')=~m/$ouString/i?1:0;
	} else{
		return 0;
	}
}



sub getUserGid{
	
	my $username=shift;
		
	my $base=$ldap->{user_base}. ','.$ldap->{dir_base};
}


sub getGroup{
	my $name=shift;
	
	my $base=$ldap->{group_base}. ','.$ldap->{dir_base};
	my $filter="&(objectclass=group) (cn=$name)";
	my $attributes=['distinguishedName','gidNumber','cn','name'];
	my $result={};	
		
	my $data = $ldapConnection->search(
		base   => $base,
		scope  => 'sub',
		attrs => $attributes,
		filter => $filter
	);
	my @answer=$data->entries();

	if(@answer){
		$result->{distinguisedName}=lc($answer[0]->get_value('distinguishedName'));
		$result->{gidNumber}=$answer[0]->get_value('gidNumber');
		$result->{cn}=$answer[0]->get_value('cn');
		$result->{name}=$answer[0]->get_value('name');
		
	}
	
	return $result;
			
	
}




sub isPosix{
	my $objectName=shift;
	my $type=shift;
	my $base=$ldap->{dir_base};
	my $filter;
	my $attributes=[];
	for($type){
		when(/user/){
			$base=$ldap->{user_base}. ',' .$base;
			$filter="&(objectclass=posixAccount) (cn=$objectName)";
			$attributes=['distinguishedName'];
		}
		when(/group/){
			$base=$ldap->{group_base}. ',' .$base;
			$filter="&(objectclass=posixGroup) (cn=$objectName)";
			$attributes=['distinguishedName'];
		}	
	}
	my $data = $ldapConnection->search(
		base   => $base,
		scope  => 'sub',
		attrs => $attributes,
		filter => $filter
	);
	$data->code && die $data->error;
	
	my @answer=$data->entries();
	
	return $answer[0]?1:0;
	
	
	
	
}


sub getUserBaseDn{
	my $userName=shift;
	my $result=0;
	my $data = $ldapConnection->search(
		base   => $ldap->{user_base}. ',' . $ldap->{dir_base},
		scope  => 'sub',
		attrs => ['distinguishedName'],
		filter => "&(objectclass=posixAccount) (cn=$userName)"
	);
	$data->code && die $data->error;
	my @answer=$data->entries();
	if(@answer){
		$result=lc( ($data->entries())[0]->get_value('distinguishedName'));
		$result=~s/cn=$userName,//;
	}
	return $result;
}

sub getAllOu{
	my $ouBase=shift;
	my $result=[];
	my $data = $ldapConnection->search(
		base   => $ouBase . ',' . $ldap->{'dir_base'},
		scope  => 'sub',
		attrs => ['distinguishedName'],
		filter => "&(objectclass=organizationalUnit)"
	);
	$data->code && die $data->error;
	
	foreach my $entry ($data->entries()){
		push(@{$result}, $entry->get_value('distinguishedName') );
	}
	
	return $result;
}


sub getFreeDiskSpace {
	my $mount_point = shift;

	my ( $fs_type, $fs_desc, $used, $avail, $fused, $favail ) = '';

	if ( -d $mount_point ) {

		( $fs_type, $fs_desc, $used, $avail, $fused, $favail ) =
		  df $mount_point;
	}
	else {
		print "You must give an existing mount point!\n";
	}
	if ($avail) {
		return int( $avail / 1000 );
	}
	else {
		return '';
	}
}




sub unbindLdap {
	$ldapConnection->unbind;
}

1;
