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
our @EXPORT_OK = qw(getCurrentStudentsAis getCurrentTeachersAis getAisUsers );




#open ais database connection

my $aisDbh = DBI->connect(
	"dbi:Firebird:hostname=" . $ais->{'fqdn'} . ";db=" . $ais->{'database'},
	$ais->{'user'}, $ais->{'password'} );

  
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