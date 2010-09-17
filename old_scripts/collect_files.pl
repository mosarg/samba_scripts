#!/usr/bin/perl

use Net::LDAP;
use File::Path;
use strict;

my($ldap) = Net::LDAP->new("localhost") || die "can't connect to !: $@";

sub get_init_year {
  my ($class,$section)=@_;
  my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
  my $current_year=1900+$yearOffset;
  my $class_code;  
        
    if (($month>=9)&&($month<=12)){
        $class_code=($current_year+1-$class).$section;
    }elsif (($month>=0)&&($month<=6)){
        $class_code=($current_year-$class).$section;
    }
  return $class_code;
  }
  
sub parse_arguments{
      # REQUIRES source directory, dest directory inside user folder 
      # source class in the form <istitute>/<sub istitute>/<full class code>, action to perform
      # OUTPUTS source directory relative to student directory, 
      # 	destination directory, 
      # 	user destination directory
      # 	sub institute 
      #		class number  
      #		class section 
      #		action to peform
      
      my @arguments;
      my ($source_dir,$dest_dir,$dest_class,$action)=@_;
      $source_dir =~ m/\/home\/\w+\/\w+\/(.+)$/g;
      push(@arguments,$1);  
      push(@arguments,$dest_dir);
      $dest_class=~ m/linussio\/(\w+)\/\w+$/;
      my $school=$1;
      push(@arguments,$school);
      $dest_class =~ m/(linussio)\/\w+\/(\d)(\w+)$/;
      my $class=$2;
      my $section=$3;
      push(@arguments,$class);
      push(@arguments,$section);
      push(@arguments,$action);
      return @arguments;
      #OUTPUT array ($source_dir,$dest_root_dir,$school,$class,$section,$action)
        }
                                                                      
                                            
sub get_students_home {

my ($class)=shift;
my ($school)=shift;
my(@homes);
my @attrs = ['dn','homeDirectory','sn','uid'];
my $dn="ou=$class,ou=$school,ou=Users,dc=linussio,dc=net";
my($mesg) = $ldap->search(base=> "$dn",
                                                scope =>'sub',
                                                filter => "objectclass=posixAccount"
                                                );
                                                
                                                $mesg->code && die $mesg->error;
                                                my($i)=0;
                                                
                                                foreach my $entry ($mesg->entries) {
                                                push(@homes,$entry->get_value('homeDirectory'));
                                                          }
                                                return @homes;
                                  }




sub collect_files {

    my ($source_dir,$dest_dir,@homes)=@_;
    foreach my $home (@homes){
      if (-d "$home/$source_dir"){
      $home=~ m/.+\/(.+)$/;
      my $student=$1;
      my $prof=$ENV{'HOME'};
      $prof=~ m/\/home\/professori\/(\w+)$/g;
      $prof=$1;
      system("cp -r \"$home/$source_dir\"  \"$dest_dir/compito.$student\" ");
      print "User $home OK! Directory exists\n";
      print  "Directory $home/$source_dir succesfully copied into $dest_dir/compito.$student\n";
      system("chown $prof.professori -R \"$dest_dir/compito.$student\"");
      print  "chown $prof.professori -R \"$dest_dir/compito.$student\"\n";
      }else{
       $home=~ m/.+\/(.+)$/;
        my $student=$1;
      print "User $student lacks $home/$source_dir\n";}
   }			
}


sub do_file_op{
#INPUT array ($source_dir,$dest_dir,$school,$class,$section,$action)
    my ($source_dir,$dest_dir,$school,$class,$section,$action)=@_;
    my @homes=get_students_home(get_init_year($class,$section),$school);
    collect_files($source_dir,$dest_dir,@homes);
    }

if (@ARGV) {
  
    do_file_op(parse_arguments(@ARGV));
}else
{
   print "Usage:  collect-file <source directory> <dest Directory relative> linussio/<school>/<section>\n";
   print "EX: collect-file /home/liceo/lau/Desktop/compito1 /home/professori/pibiondi6/Documenti/cor-compito  linussio/liceo/4bl \n";
}
$ldap->unbind;