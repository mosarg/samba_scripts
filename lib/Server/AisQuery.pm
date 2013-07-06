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
our @EXPORT_OK = qw(getCurrentStudentsAis getCurrentTeachersAis getAisUsers getCurrentClassAis);




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
                t.sanacognome AS \"surname\" ,t.dananascita AS \"birthDate\"
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



sub getAisUsers {

#Axios Tables
#TSISALU_ALUNNI alunni table nome,cognome,isisaluid,codalunnosidi,annocronologico,sezione,annoscol ->Tutti gli alunni
	return \$aisDbh->tables;

}