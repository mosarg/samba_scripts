package Server::AisQuery;

use DBI;
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );

use Server::Configuration qw($server $ais);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis);




#open ais database connection

my $aisDbh = DBI->connect(
	"dbi:Firebird:hostname=" . $ais->{'fqdn'} . ";db=" . $ais->{'database'},
	$ais->{'user'}, $ais->{'password'} );

  
#
# idctid: 1 Docente, 2 Ata, 3 Ds
#


sub executeAisQuery{
	my $query=shift;
	my $result = $aisDbh->prepare($query);
	$result->execute();
	my $slice={};
	my $matches = $result->fetchall_arrayref($slice);
	return $matches;
};



sub getCurrentTeachersAis {
	my $query = "SELECT DISTINCT t.ianaid As \"userIdNumber\",t.sananome AS \"name\",
                t.sanacognome AS \"surname\" ,t.dananascita AS \"birthDate\",\'UDSSC817F0\' As meccanographic
                FROM  tana_anagrafiche t 
     			INNER JOIN tanacag ta on(t.ianaid=ta.ianaid)
     			INNER JOIN tanaper_personale p on (ta.ianacagid=p.ianacagid)
     			LEFT  JOIN ttno_tiponomina tt on(p.itnoid=tt.itnoid)
     			LEFT  JOIN tquap_qualpers tq on (p.iquapid=tq.iquapid)
     			LEFT  JOIN tnop_nominaperso  tn on(p.inopid=tn.inopid)
   				WHERE p.idctid=1 AND p.istabperid=1  AND tq.iquapusercode IN (12,14,17,25)";

	return executeAisQuery($query);
}


sub getCurrentStudentsAis {
	my $query = "SELECT DISTINCT codalunnosidi AS \"userIdNumber\",nome AS \"name\",
       			cognome AS \"surname\", datanascita AS \"birthDate\", 
       			annocronologico AS \"classNumber\", sezione AS \"classLabel\",
       			coddebolescuola AS \"meccanographic\", annoscol AS \"year\" 
				FROM tsisalu_alunni";
	return executeAisQuery($query);
}


sub getCurrentClassAis{
	my $query ="SELECT DISTINCT a.annocronologico AS \"classNumber\", a.sezione AS \"classLabel\",
       			a.coddebolescuola AS \"meccanographic\",s.descrsede AS \"description\"
				FROM tsisalu_alunni a INNER JOIN tsissed_sedi s ON(a.coddebolescuola=s.coddebolescuola);";
	return executeAisQuery($query);
}


sub getCurrentAtaAis{
	my $query="SELECT DISTINCT t.ianaid As \"userIdNumber\",t.sananome AS \"name\",
                t.sanacognome AS \"surname\" ,t.dananascita AS \"birthDate\",\'UDSSC817F0\' As \"meccanographic\"
                FROM  tana_anagrafiche t 
     			INNER JOIN tanacag ta on(t.ianaid=ta.ianaid)
     			INNER JOIN tanaper_personale p on (ta.ianacagid=p.ianacagid)
     			LEFT  JOIN ttno_tiponomina tt on(p.itnoid=tt.itnoid)
     			LEFT  JOIN tquap_qualpers tq on (p.iquapid=tq.iquapid)
     			LEFT  JOIN tnop_nominaperso  tn on(p.inopid=tn.inopid)
   				WHERE p.idctid=2 AND p.istabperid=1  AND tq.iquapusercode IN (7,24,31,1)";
   			return executeAisQuery($query);
	
}

sub getCurrentSubjectAis{
	my $query="SELECT r.imatid AS \"subjectId\", r.smatldesc AS \"description\", r.smatsdesc AS \"shortDesc\"
	FROM TMAT_MATERIE r";
	return executeAisQuery($query);
}

sub getCurrentTeacherClassAis{
	
my $year=shift;	
my $result={};
my $query="SELECT  t.ianaid AS \"userIdNumber\",m.imatid AS \"subjectId\",ta.iacsannocorso AS \"classNumber\",ts.ssezsdesc AS \"classLabel\" FROM
tana_anagrafiche t
INNER JOIN tanacag tan ON(t.ianaid=tan.ianaid)
INNER JOIN tanaper_personale p ON (tan.ianacagid=p.ianacagid)
INNER JOIN tdct_docenteata td ON (td.idctid=p.idctid) 
INNER JOIN tclsmatana ma ON (t.ianaid=ma.ianaid)
INNER JOIN tmat_materie m ON (ma.imatid=m.imatid) 
INNER JOIN tcls_classi tc ON (ma.iclsid=tc.iclsid)
INNER JOIN tacs_annicorso ta ON (tc.iacsid=ta.iacsid)
INNER JOIN tind_indirizzo ti ON (tc.iindid=ti.iindid)
INNER JOIN tsez_sezioni ts ON (tc.isezid=ts.isezid)
WHERE td.sdctldesc='Docente' AND p.istabperid=1  AND tc.dstart>='01.09.$year' AND tc.dend <= '01.09.".++$year."\'";

my $teacherMap= executeAisQuery($query);

foreach my $mapElement (@{$teacherMap}){
	if (!$result->{$mapElement->{userIdNumber}}){
		$result->{$mapElement->{userIdNumber}}=[];
	}		
	$mapElement->{classNumber}=lc($mapElement->{classNumber});
	$mapElement->{classLabel}=lc($mapElement->{classLabel});
	$mapElement->{classId}=$mapElement->{classNumber}.$mapElement->{classLabel};
	push(@{$result->{$mapElement->{userIdNumber}}},$mapElement);
}

return $result;

}








sub getAisUsers {

my $role=shift;

if ($role eq 'student'){
	return getCurrentStudentsAis();
}
if ($role eq 'ata'){
	return getCurrentAtaAis();
}

if ($role eq 'teacher'){
	return getCurrentTeachersAis();
}


}

1;