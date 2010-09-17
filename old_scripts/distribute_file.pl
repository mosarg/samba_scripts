#!/usr/bin/perl

use Net::LDAP;
use File::Path;
use strict;

my($ldap) = Net::LDAP->new("localhost") || die "can't connect to !: $@";





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



sub put_files {
  
  my ($file,@homes)=@_;
    foreach my $home (@homes){
      system("cp -r $file $home/Desktop");
      print "cp -r $file $home/Desktop\n";
      $home=~ m/.+\/(.+)$/;
      system("chown $1.studenti -R $home/Desktop/$file");
      print "chown $1.studenti -R $home/Desktop/$file\n";
   }			
}

sub remove_files{


my ($file,@homes)=@_;	
    foreach my $home (@homes){
      if ($home ne ""){
          system("rm -r $home/Desktop/$file");
          print "rm -r $home/Desktop/$file\n";
            }
          }
}



my $class=$ARGV[0];
my $school=$ARGV[1];
my $file=$ARGV[2];
my $action=$ARGV[3];
my @homes=get_students_home($class,$school);
if ($action eq "put"){
put_files($file,@homes);
}
if ($action eq "remove"){
remove_files($file,@homes);
}

$ldap->unbind;