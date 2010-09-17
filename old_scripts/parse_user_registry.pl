#!/usr/bin/perl
use strict;
use Parse::Win32Registry qw(:REG_);








my $filename_upper;
my $filename_lower;
#get user profiles dir

my (@user_profiles)=`ls /home/samba/profiles`;

chop(@user_profiles);

foreach (@user_profiles){
  $filename_upper="/home/samba/profiles/$_/NTUSER.DAT";
  $filename_lower="/home/samba/profiles/$_/ntuser.dat";
 if (-e $filename_lower){
  check_registry($filename_lower,$_);
 }elsif(-e $filename_upper){
  check_registry($filename_upper,$_);
   }else{
  print "Il file di registro per l'utente $_ non esiste\n";
 }
 }


#$filename="/home/samba/profiles/fabi/NTUSER.DAT";
#check_registry($filename,"fabi");






sub check_registry{
my ($reg_filename,$user)=@_;
my $registry = Parse::Win32Registry->new($reg_filename);
my $root_key = $registry->get_root_key;
my $software_key = $root_key->get_subkey(".DEFAULT\\Software") || $root_key->get_subkey("Software");


                    
  if (defined($software_key)) {
      my @user_key_names = (
         "Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders",);
        my @check_keys=("AppData","Desktop","Personal");
         if (my $key = $software_key->get_subkey($user_key_names[0])) {
           foreach my $value ($key->get_list_of_values) {
                               foreach (@check_keys){
                                if ($value->as_string=~m/^$_/){
                                   #print "Valore della chiave".$value->as_string."\n";
                                 if ($value->as_string=~m/HILBERTO|LOGONSERVER/){
                                   #print "La chiave $_ è OK\n";
                                   }
                                   else
                                   {
                                     print "La chiave $_ dell'utente $user deve essere reimpostata\n";
                                   }
                                }
                               }
                                    
           }
         }
  }                                                                                        
}