package Server::AisQuery;
use DBI;
use DBD::CSV;
use experimental 'switch';
use strict;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Server::Configuration qw($server $ais);
use Server::Commands qw(execute sanitizeString sanitizeUsername);
require Exporter;


our @ISA = qw(Exporter);
our @EXPORT_OK = qw(a2n getCurrentTeachersAis  getAisUsers getCurrentClassAis getCurrentSubjectAis getCurrentTeacherClassAis getCurrentYearAis getCurrentStudentsClassSubjectAis getStudyPlanSubject getCurrentStudentsAis);

#open ais database connection
  
#
# idctid: 1 Docente, 2 Ata, 3 Ds
#

sub a2n {
  my $data=shift;
  my %hash;
	@hash{("A".."Z")} = (1..26);	
	foreach my $letter (keys %hash){
		$data=~s/$letter/$hash{$letter}/g;
	}  
  return int($data);
}


sub executeAisQuery{
	my $query=shift;
	my $aisDbh= DBI->connect("DBI:CSV:f_dir=".$ais->{'database'});
	my $result = $aisDbh->prepare($query);
	$result->execute();
    my $matches = $result->fetchall_arrayref({});
	$result->finish;
	$aisDbh->disconnect;	
	return $matches;
};
#sub executeAisQuery{
#	my $aisDbh = DBI->connect(
#	"dbi:Firebird:hostname=" . $ais->{'fqdn'} . ";db=" . $ais->{'database'},
#	$ais->{'user'}, $ais->{'password'} );
#	my $query=shift;
#	my $result = $aisDbh->prepare($query);
#	$result->execute();
#	my $matches = $result->fetchall_arrayref({});
#	$result->finish;
#	$aisDbh->disconnect;	
#	return $matches;
#};

sub executeAisPlaneQuery{
	my $aisDbh= DBI->connect("DBI:CSV:f_dir=".$ais->{'database'});
	my $query=shift;
	my $result = $aisDbh->prepare($query);
	$result->execute();
	my $matches = $result->fetchall_arrayref();
	$result->finish;
	$aisDbh->disconnect;	
	return [map {@$_} @{$matches}];
};


sub getCurrentTeachersAis {
	my $year=shift;	
	my $query="SELECT userIdNumber, name,surname ,birthDate, ".$ais->{main_mec}." As meccanographic FROM
			   docenti_ata";
	return executeAisQuery($query);
}

sub getStudentsAis 	{
	my $parameters=shift;
	my $year=shift;
    my $query="SELECT userIdNumber,surname,name,birthDate,meccanographic, classLabel||meccanographic AS classLabel, classNumber,classNumber||classLabel||meccanographic AS className,\'$year\' as year, studyPlan FROM alunni";
	my $students=executeAisQuery($query);
#	foreach my $student (@{$students}){
#		$student->{userIdNumber}=a2n($student->{userIdNumber});
#	}
	
	return $students;
}


sub getCurrentStudentsAis{
	my $parameters=shift;
	return getStudentsAis($parameters,$ais->{year})
}



sub getStudyPlanSubject{
	my $studyPlan=shift;
	my $query="SELECT  code FROM materie";    
	return executeAisPlaneQuery($query);
}


sub getCurrentStudentsClassSubjectUnNormAis{

my $query="SELECT code, classname FROM materie_classi";

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

	my $query="select classNumber, classLabel||meccanographic AS classLabel, meccanographic,description FROM classi";
	return executeAisQuery($query);
}


sub getCurrentAtaAis{
	my $query="SELECT  DISTINCT userIdNumber, name,surname ,birthDate,\'".$ais->{main_mec}."\' As meccanographic FROM
			   ata";
   			return executeAisQuery($query);
}



sub getCurrentSubjectAis{
	my $query="SELECT code, description,shortDescription FROM materie";
	return executeAisQuery($query);
}


sub getCurrentTeacherClassAis{
my $year=shift;	
my $result={};

my $query="SELECT userIdNumber,\'0\' as subjectId, \'5\' as classNumber, \'Z\' as classLabel FROM docenti_ata";

print $query;
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
	return getCurrentTeachersAis($parameters);
}


}

1;