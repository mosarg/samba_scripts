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
  print "$dayOfMonth\n";        
    if (($month>=9)&&($month<=12)){
        $class_code=($current_year+1-$class).$section;
    }elsif (($month>=0)&&($month<=8)){
        $class_code=($current_year-$class).$section;
    }
  return $class_code;
  }
  
sub parse_arguments{
      # REQUIRES source directory, root dest directory inside user folder 
      # destination class in the form <istitute>/<sub istitute>/<full class code>, action to perform
      # OUTPUTS source directory, root destination directory, user destinatin directory
      # sub institute class number  class section and action to peform
      
      my @arguments;
      my ($source_dir,$dest_dir,$dest_class,$action)=@_;
      $source_dir =~ m/\w+\/(\w+)$/g;
      push(@arguments,$source_dir);  
      my $dest_dir_cont=$1;
      push(@arguments,$dest_dir);
      push(@arguments,$dest_dir_cont);
      $dest_class=~ m/linussio\/(\w+)\/\w+$/;
      my $school=$1;
      push(@arguments,$school);
      $dest_class =~ m/(linussio)\/\w+\/(\d)(\w+)$/;
      my $class=$2;
      print "class $class\n";
      my $section=$3;

      push(@arguments,$class);
      push(@arguments,$section);
      push(@arguments,$action);
      return @arguments;
      #OUTPUT array ($source_dir,$dest_root_dir,$dest_dir,$school,$class,$section,$action)
        }
                                                                      
                                            
sub get_students_home {

my ($class)=shift;
my ($school)=shift;
my(@homes);
my @attrs = ['dn','homeDirectory','sn','uid'];
my $dn="ou=$class,ou=$school,ou=Users,dc=linussio,dc=net";
print "$dn\nn";
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



sub put_files {

    
  my ($source_dir,$dest_root_dir,$dest_dir,@homes)=@_;
    foreach my $home (@homes){
      if (-d "$home/$dest_root_dir"){
       system("cp -r \"$source_dir\" \"$home/$dest_root_dir\"");
       print "User $home OK!\n";
#     print  "Directory $source_dir succesfully copied into $home/$dest_root_dir\n";
      $home=~ m/.+\/(.+)$/;
      system("chown $1.studenti -R \"$home/$dest_root_dir/$dest_dir\"");
#      print  "chown $1.studenti -R \"$home/$dest_root_dir/$dest_dir\"\n";
      }else{print "User $home lacks $dest_root_dir\n";}
   }			
}

sub remove_files{

my ($source_dir,$dest_root_dir,$dest_dir,@homes)=@_;	

    foreach my $home (@homes){
      if ($home ne ""){
          if (-d "$home/$dest_root_dir/"){
          system("rm -r \"$home/$dest_root_dir/\"");
          print "rm -r  $home/$dest_root_dir/\n";
          }else{print "No directory to remove!\n";}
            
            }
          }
}

sub do_file_op{
#INPUT array ($source_dir,$dest_dir,$dest_dir,$school,$class,$section,$action)

    my ($source_dir,$dest_root_dir,$dest_dir,$school,$class,$section,$action)=@_;
    my @homes=get_students_home(get_init_year($class,$section),$school);
    if ($action eq "put"){
      put_files($source_dir,$dest_root_dir,$dest_dir,@homes);
      }
      if ($action eq "remove"){
      remove_files($source_dir,$dest_root_dir,$dest_dir,@homes);
      }
    }

if (@ARGV) {
  do_file_op(parse_arguments(@ARGV));
}else
{
   print "Usage:  distribute-file2 <source directory> <root dest Directory relative to user folder> linussio/<school>/<section> <action>\n";
   print "EX: distribute-file2 /home/professori/mosa/Desktop/esercizi Desktop linussio/ipsc/3ao put\n";
}
$ldap->unbind;