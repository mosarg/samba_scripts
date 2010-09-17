#!/usr/bin/perl

use Net::LDAP;
use File::Path;
use strict;

my($ldap) = Net::LDAP->new("localhost") || die "can't connect to !: $@";





sub get_group_members {

my($group)=shift;
my(@members);
my($mesg) = $ldap->search(base=> "ou=Groups,dc=linussio,dc=net",
                                                scope =>'sub',
                                                filter => "&(objectclass=posixGroup) (cn=$group)");
                                                $mesg->code && die $mesg->error;
                                                my($i)=0;
                                                foreach my $entry ($mesg->entries) {
                                                @members = $entry->get_value('memberuid');
                                                        }
                                  return @members;
                                  }



sub get_class {
  my ($class_code)=shift;
 
  my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
  my $current_year=1900+$yearOffset;
  $class_code=~ m/^(\d+)\w+$/;
  my $class=$current_year-$1+1;
  $class_code=~/^\d+(\w)\w+$/;
  my $section=$1;
  $class=$class.$section;
  return $class;  

}


sub create_dir {

  my ($school)=shift;
  my ($class)=shift;
  my $dir="/opt/istituti/".$school."/".$class;
  if (not -d "$dir"){
  eval { mkpath($dir,0,0770) };
        if ($@) {
                 print "Couldn't create $dir: $@";
        }
        }
   }



sub make_user_link {

  my ($user)=shift;
  my @attrs = ['dn','homeDirectory','sn','uid'];
  my($mesg) = $ldap->search(base=> "ou=Users,dc=linussio,dc=net",
                            scope =>'sub',
                            filter => "&(objectclass=posixAccount) (uid=$user)",
                            attrs=> @attrs
                            );

  
  my $entry=$mesg->pop_entry();
  if (defined $entry) {
  my $userDN = $entry->dn();
  my $uid = $entry->get_value('uid');
  my $home = $entry->get_value('homeDirectory');
  my $surname= $entry->get_value('sn');
  
  print $userDN."\n";
  $userDN=~ m/^uid=.*,ou=(\w+),ou=/;
  my $school=$1;
  $userDN=~ m/ou=(\d+\w+),ou=$school/;
  
  my $class_c=$1;
  
  if ($class_c ne  ""){
  
  my $class=get_class($class_c);
  my $source_dir ="/home/".$school."/".$uid;
  my $dest_link ="/opt/istituti/".$school."/".$class."/".$surname."-".$uid;

  create_dir($school,$class);
  if (not -l $dest_link){
  system("ln -s $source_dir $dest_link");}
  }else{ print "This is not a stundent!\n";}
  
  }
  else
  {print "User doesn't exist\n";}

}



sub create_users_inventory {

my (@members)=get_group_members("studenti");


foreach my $member (@members){

make_user_link($member);
print $member."\n";

}


}


create_users_inventory();


