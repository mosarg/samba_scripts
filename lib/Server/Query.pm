package Server::Query;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Net::LDAP;
use Data::Dumper;
use Filesys::DiskSpace;
use Data::Structure::Util qw( unbless );

use Server::Configuration qw($server $ldap $ldap_users $ais $adb);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK =
  qw(getCurrentStudentsAis getCurrentTeachersAis getAisUsers getFreeDiskSpace
  getUserFromUname getUsersDiskProfiles getUserFromHumanName getUsers getUsersHome getUserHome getClassHomes
  getGroupMembers getUserFromUid unbindLdap doUserExistAdb doAccountExistAdb doClassExistAdb syncUsersAdb syncClassAdb);

my $ldapConnection = Net::LDAP->new( $ldap->{'server'} )
  || print "can't connect to !: $@";

#bind to AD ldap server as Administrator
$ldapConnection->bind(
	$ldap->{'bind_root'} . ',' . $ldap->{'dir_base'},
	password => $ldap->{'bind_root_password'}
);

#open ais database connection
my $aisDbh = DBI->connect(
	"dbi:Firebird:hostname=" . $ais->{'fqdn'} . ";db=" . $ais->{'database'},
	$ais->{'user'}, $ais->{'password'} );

#open user account database connections
my $adbDbh = DBI->connect( "dbi:mysql:$adb->{'database'}:$adb->{'fqdn'}:3306",
	$adb->{'user'}, $adb->{'password'} )
  or die "Can’t connect to DB\n";
 
   
 sub doUserExistAdb{
  	my $userId=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM user WHERE userIdNumber=$userId";
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 } 
  
 sub doAccountExistAdb{
 	my $userId=shift;
 	my $accountType=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM account WHERE userIdNumber=$userId AND type=\'$accountType\'";
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 }
 
 
 sub doUsernameExistAdb{
 	my $username=shift;
 	my $query="SELECT DISTINCT COUNT(username) FROM account WHERE username=\'$username\'";
 	my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 }
 
  
  
 sub doUserClassExistAdb{
 	my $userId=shift;
 	my $schoolYear=shift;
 	my $query="SELECT COUNT(userIdNumber) FROM attends WHERE userIdNumber=$userId AND year=$schoolYear";
    my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];	
  }
 
  
 sub doClassExistAdb{
 	my $classId=shift;
 	my $meccanographic=shift;
 	my $query="SELECT COUNT(classId) FROM class WHERE classId=\'$classId\' AND meccanographic=\'$meccanographic\'";
    my $queryH=$adbDbh->prepare($query);
 	$queryH->execute();
 	return ($queryH->fetchrow_array())[0];
 }
  
 
 sub addAccountAdb{
 	my $userIdNumber=shift;
 	my $userName=shift;	
 	my $type=shift;
 	
 	if (doAccountExistAdb($userIdNumber,$type)){
 		print "$userName $userIdNumber has already an account of type $type\n ";
 	}else{
 		my $userName=sanitizeUsername($userName);
 		my $userNameCount=doUsernameExistAdb($userName);
 		if($userNameCount>0) {$userName=$userName.$userNameCount;}
 		print "Adding account $userName\n";
 		my $query="INSERT INTO account (username,activity,type,userIdNumber) VALUES (\'$userName\',false,\'$type\',\'$userIdNumber\')";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	}
  }
 
   
 sub addUserAdb{
 	my $user=shift;
   	my $userId=$user->[0];
 	my $userName=ucfirst(sanitizeString(lc($user->[1])));
 	my $userSurname=ucfirst(sanitizeString(lc($user->[2])));	
 	
 	if (doUserExistAdb( $userId ) ){
 			print " $userId $userName $userSurname user already inserted \n";
 			addUserClassAdb($user);
 			#Update Samba 4 account ou
 			
 	}else{
 			my $query="INSERT INTO user (userIdNumber,name,surname) VALUES ($userId,\'$userName\',\'$userSurname\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 			addAccountAdb($userId,$userSurname.$userName,'Samba4');
 			addUserClassAdb($user);
 			#Create samba4 account into correct ou
 		}
  	return 1;
 }
 

 sub addUserClassAdb{
 	my $userId=$_[0]->[0];
 	my $classYear=$_[0]->[4];
 	my $classLabel=$_[0]->[5];
 	my $classId=$classYear.$classLabel;
 	my $schoolYear=$_[0]->[7];

 	if (doUserClassExistAdb($userId,$schoolYear)){
 		print "User map already exists\n";
 	}else{
 		my $query="INSERT INTO attends (userIdNumber,classId,year) VALUES ($userId,\'$classId\',$schoolYear)";
 		my $queryH=$adbDbh->prepare($query);
 		$queryH->execute();
 	} 	
 }
 
 
 sub addClassAdb{
 	my $chronologicalYear=$_[0]->[0];
 	my $classLabel=lc($_[0]->[1]);
 	my $meccanographic=$_[0]->[2];
 	if (doClassExistAdb($chronologicalYear.$classLabel,$meccanographic) ){
 		print "Class $chronologicalYear$classLabel,$meccanographic already inserted\n";
 	}else{
 		my $query="INSERT INTO class (classId,classDescription,classOu,classCapacity,meccanographic) 
 				VALUES (\'$chronologicalYear$classLabel'\,'Class Description',\'ou=$chronologicalYear$classLabel\',30,\'$meccanographic\')";
 			my $queryH=$adbDbh->prepare($query);
 			$queryH->execute();
 	}
 }
 
 sub addSchoolAdb{
 	
 	
 }
 
 
 sub syncClassAdb{
 	my $classes=getCurrentClassAis();
 	foreach my $class (@{$classes}){
 		addClassAdb($class);
 	}
 	
 } 
   
 sub syncUsersAdb{
 	my $users=getCurrentStudentsAis();
 	foreach my $user (@{$users}){
 		addUserAdb($user);
  	}
 	
 }
 
  
  
#
# idctid: 1 Docente, 2 Ata, 3 Ds
#

sub getCurrentTeachersAis {
	my $query = "SELECT DISTINCT t.ianaid As id,t.sananome AS name,
                t.sanacognome AS surname ,t.dananascita AS birthDate
                FROM  tana_anagrafiche t 
     			INNER JOIN tanacag ta on(t.ianaid=ta.ianaid)
     			INNER JOIN tanaper_personale p on (ta.ianacagid=p.ianacagid)
     			LEFT  JOIN ttno_tiponomina tt on(p.itnoid=tt.itnoid)
     			LEFT  JOIN tquap_qualpers tq on (p.iquapid=tq.iquapid)
     			LEFT  JOIN tnop_nominaperso  tn on(p.inopid=tn.inopid)
   				WHERE p.idctid=1 AND p.istabperid=1  AND tq.iquapusercode IN (12,14,17,25)";

	my $teachers = $aisDbh->prepare($query);
	$teachers->execute();
	my $matchTeachers = $teachers->fetchall_arrayref();
	return $matchTeachers;
}


sub getCurrentStudentsAis {
	my $query = "SELECT DISTINCT codalunnosidi AS id,nome AS name,
       			cognome AS surname, datanascita AS birthDate, 
       			annocronologico AS classNumber, sezione AS classLabel,
       			coddebolescuola AS meccanographic,annoscol AS schoolYear 
				FROM tsisalu_alunni";
	my $students = $aisDbh->prepare($query);
	$students->execute();
	my $matchStudents = $students->fetchall_arrayref();
	return $matchStudents;

}

sub getCurrentClassAis{
	my $query ="SELECT DISTINCT a.annocronologico AS classNumber, a.sezione AS classLabel,
       			a.coddebolescuola AS meccanographic,s.descrsede
				FROM tsisalu_alunni a INNER JOIN tsissed_sedi s ON(a.coddebolescuola=s.coddebolescuola);";
	my $classes = $aisDbh->prepare($query);
	$classes->execute();
	my $matchClasses = $classes->fetchall_arrayref();
	return $matchClasses;
}



sub getAisUsers {

#Axios Tables
#TSISALU_ALUNNI alunni table nome,cognome,isisaluid,codalunnosidi,annocronologico,sezione,annoscol ->Tutti gli alunni
	return \$aisDbh->tables;

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
	$ldapConnection->bind;
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
		return '';
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
