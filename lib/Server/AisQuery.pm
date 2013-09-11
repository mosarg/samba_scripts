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
our @EXPORT_OK = qw(getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis getCurrentYearAis getCurrentStudentsClassSubjectAis getStudyPlanSubject getCurrentStudentsAis);




#open ais database connection



  
#
# idctid: 1 Docente, 2 Ata, 3 Ds
#


sub executeAisQuery{
	my $aisDbh = DBI->connect(
	"dbi:Firebird:hostname=" . $ais->{'fqdn'} . ";db=" . $ais->{'database'},
	$ais->{'user'}, $ais->{'password'} );
	my $query=shift;
	my $result = $aisDbh->prepare($query);
	$result->execute();
	my $matches = $result->fetchall_arrayref({});
	$result->finish;
	$aisDbh->disconnect;	
	return $matches;
};

sub executeAisPlaneQuery{
	my $aisDbh = DBI->connect(
	"dbi:Firebird:hostname=" . $ais->{'fqdn'} . ";db=" . $ais->{'database'},
	$ais->{'user'}, $ais->{'password'} );
	my $query=shift;
	my $result = $aisDbh->prepare($query);
	$result->execute();
	my $matches = $result->fetchall_arrayref();
	$result->finish;
	$aisDbh->disconnect;	
	return [map {@$_} @{$matches}];
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


sub getStudentsAis 	{
	my $parameters=shift;
	my $year=shift;

	my $query="SELECT DISTINCT ana.IANAID as \"userIdNumber\", ana.SANACOGNOME as \"surname\", ana.SANANOME as \"name\", ana.DANANASCITA as \"birthDate\",
			sed.SSEDMECCOD as \"meccanographic\",cls.SSEZLDESC as \"classLabel\",cls.IACSANNOCORSO as \"classNumber\",
			 \'$year\' as \"year\",cls.IACSANNOCORSO||cls.SSEZLDESC AS \"classname\",clspst.IPSTID AS \"studyPlan\"
			FROM TANA_ANAGRAFICHE ana INNER JOIN TANACAG anacag ON ( ana.IANAID = anacag.IANAID ) 
      		INNER JOIN TCAG_ANACATEG cag ON ( cag.ICAGID = anacag.ICAGID ) 
        	LEFT JOIN TSIT_SITUAZIONI sit ON ( ana.IANAID = sit.IANAID ) 
        	LEFT JOIN TCLSPST clspst ON ( clspst.ICLSPSTID = sit.ICLSPSTID) 
        	LEFT JOIN VCLS_CLASSI cls ON ( cls.ICLSID = clspst.ICLSID) 
        	LEFT JOIN VSED_SEDI sed ON (sed.IDWGSEDID = cls.IDWGSEDID) 
        	WHERE (ana.DDELETE IS NULL) AND (CAG.iCagId = 1 ) AND ((SIT.isitordine = 1) AND (SIT.dstart='".$year."-09-01') AND (CLS.idwgid=102)) AND sed.SSEDMECCOD IN (".join(',',@{$parameters}).") and TSIT_SITUAZIONI.ISITPOSREG<>0";

	return executeAisQuery($query);
}



sub getCurrentStudentsAis{
	my $parameters=shift;
	return getStudentsAis($parameters,$ais->{year})
}



sub getStudyPlanSubject{
	my $studyPlan=shift;
	my $query="SELECT  TMat.iMatId as \"code\"         
        FROM TMatRmaPst TMatRmaPst    
        INNER JOIN TMatRma TMatRma ON (TMatRma.iMatRmaId = TMatRmaPst.iMatRmaId AND TMatRma.dDelete IS NULL) 
        INNER JOIN TMat_Materie TMat   ON (TMat.iMatId = TMatRma.iMatId AND TMat.dDelete IS NULL)         
        LEFT JOIN TCompAsse TAsse       ON (TMatRmaPst.iCompAsseId = TAsse.iCompAsseId)
        LEFT OUTER JOIN TOan_OreAn TOan ON (TOan.iOanId = TMatRmaPst.iOanId AND TOan.dDelete IS NULL)   
        WHERE (TMatRmaPst.dDelete IS NULL) and TMATRMAPST.IPSTID=$studyPlan";
	return executeAisPlaneQuery($query);
}


sub getCurrentStudentsClassSubjectUnNormAis{



my $query="SELECT DISTINCT m.imatid AS \"code\",ta.sacssdesc||ts.ssezldesc AS \"classname\" FROM
tclsmatana ma INNER JOIN
TMAT_MATERIE m on(ma.imatid=m.imatid)  
INNER JOIN tcls_classi tc ON (ma.iclsid=tc.iclsid)
INNER JOIN tacs_annicorso ta ON (tc.iacsid=ta.iacsid)
INNER JOIN tind_indirizzo ti ON (tc.iindid=ti.iindid)
INNER JOIN tsez_sezioni ts ON (tc.isezid=ts.isezid) ORDER BY ta.SACSSDESC, ts.SSEZLDESC";

my $result={};
my $subjectClass=executeAisQuery($query);

foreach my $class (@{$subjectClass}){
	
	if(!$result->{$class->{classname}})
		{$result->{$class->{classname}}=[];
		
	}
	 push(@{$result->{$class->{classname}}},$class->{code});
	}
	
return $result;
}

sub getCurrentStudentsClassSubjectAis{
	my $parameters=shift;
	my $result={};
	my $students=getCurrentStudentsAis($parameters);

	foreach my $student (@{$students}){
		my $studentSubjects=getStudyPlanSubject($student->{studyPlan});	
		$result->{$student->{userIdNumber}}=[];
		foreach my $subject (@{$studentSubjects}){
			push(@{$result->{$student->{userIdNumber}}},{
					classLabel=>lc($student->{classLabel}),
					classNumber=>lc($student->{classNumber}),
					classId=>lc($student->{classNumber}).lc($student->{classLabel}),
					subjectId=>$subject,
					userIdNumber=>$student->{userIdNumber}
			});
		}
	}
	return $result;
}


sub getCurrentClassAis{

	my $query="select vc.IACSANNOCORSO as \"classNumber\", vc.SSEZLDESC AS \"classLabel\" ,sed.SSEDMECCOD AS \"meccanographic\" ,sed.SSEDNOMLDESC AS \"description\"
				 from VCLS_CLASSI vc
				 left join vsed_sedi sed on(vc.IDWGSEDID=sed.IDWGSEDID) where vc.SCLSANNOSCOL like \'$ais->{year}%\'";

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
	my $query="SELECT r.imatid AS \"code\", r.smatldesc AS \"description\", r.smatsdesc AS \"shortDescription\"
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

sub getCurrentYearAis{
	return $ais->{year};
}


sub getAisUsers {

my $role=shift;
my $parameters=shift;

if ($role eq 'student'){
	return getCurrentStudentsAis($parameters);
}
if ($role eq 'ata'){
	return getCurrentAtaAis();
}

if ($role eq 'teacher'){
	return getCurrentTeachersAis();
}


}

1;