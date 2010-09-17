#!/usr/bin/perl
use strict;
use Net::LDAP;

my($ldap) = Net::LDAP->new("127.0.0.1") || die "can't connect to !: $@";

$ldap->bind("cn=Manager,dc=linussio,dc=net",password=>"sambackett");

sub modify_user_sid {

            my($uid,$new_sid)=@_;


            #if ($uid eq ""){print "Attenzione manca uno username"; return "error";}
                        
#            $ldap->bind("cn=Manager,dc=linussio,dc=net",password=>"sambackett");   
            
            my($data) = $ldap->search(base=> "ou=Users,dc=linussio,dc=net",
                                                scope =>'sub',
                                                filter => "&(objectclass=posixAccount) (uid=$uid)");
                                                
            $data->code && die $data->error;
            
            $new_sid="S-1-5-21-3940284654-3667504151-3746250938-".$new_sid;
            my $user=$data->pop_entry();
            if (defined $user){
            my $userDN=$user->dn();


            print $userDN."\n";
            #my $mesg = $ldap->modify($userDN, replace => { "sambaSID" => $new_sid } );
            #print "sambaSID ".$user->get_value('sambaSID')."\n";

            }
            
 
            
           # if($user){
           # $new_sid="S-1-5-21-3940284654-3667504151-3746250938-".$new_sid;
           # $user->replace(sambaSID=>$new_sid);
           # $user->update($ldap);
           # }
            #my(@output)=$data->entries(0);   
            #if (@output){
            #return $output[0]->get_value('uid');
            #}else{
            #return "empty";
            #}
#           $ldap->unbind;
          }
          
          






my $dump_file;

$dump_file="/tmp/out";

open  DUMP, "< $dump_file" or die "Can't open $dump_file: $!";

my @ldap_dump=<DUMP>;
my $match;
my $uid;
my $sid;
my %users_sid;
$match=0;

foreach my $line (@ldap_dump){

if ($line=~ m/#\s+(\w+).*sers, linussio.net$/){
                      #print "$1\n";
                      $match=1;
                      $uid=$1;
                      }
if (($line=~ m/sambaSID:\s+(.*)/)and($match==1)){
  #print "$1\n";
  $match=0;
  $sid=$1;
  push(@{$users_sid{$sid}},$uid);
  }

}

my @sid_numbers;
my $array_elements;
my $total_duplicate_sids=0;
for my $user_sid (keys %users_sid){
  $array_elements=@{$users_sid{$user_sid}};
  
$user_sid=~m/.*-(\d{4})/;
  push(@sid_numbers,$1);
  if ($array_elements >1 ){
  print "User sid $user_sid with username has $array_elements elements:\n";
  $total_duplicate_sids+=$array_elements;
  foreach (@{$users_sid{$user_sid}}){
    print "$_\n";
    }
  
  }
#  print "@{$users_sid{$user_sid}}";
  }
  
  @sid_numbers=sort(@sid_numbers);
  my @sid_number_occupation;
  my $sids=@sid_numbers;
  my $dummy;
  print "Scalar".scalar(@sid_numbers)."\n";  
  print "Min sid is $sid_numbers[0] Max is $sid_numbers[scalar(@sid_numbers)-1]\n";
  
#  for ($dummy=0;$dummy<$sid_numbers[scalar(@sid_numbers)];$dummy++){
#    $sid_number_occupation[$dummy
  
  foreach (@sid_numbers){
   
     $sid_number_occupation[$_]=1;
    
    }

$dummy=0;
my @free_sids;
my $free_sids_number=0;
  for ($dummy=0;$dummy<scalar(@sid_number_occupation);$dummy++){
    
    if(($sid_number_occupation[$dummy]==0)and($dummy>3000)and($dummy%2==0)){
      push(@free_sids,$dummy);
      $free_sids_number+=1;
      print "Sid number $dummy is free\n";
    
    }    
}    
    
    print "Total number of duplicate sids: $total_duplicate_sids\n";
    print "Number of free sids above 3000: $free_sids_number\n";
    


foreach  my $current_sid(keys %users_sid){
  #modify_user_sid("sagabriele5",3012);    
  $array_elements=@{$users_sid{$current_sid}};
  if ($array_elements>1){
    print "$current_sid\n";    
    shift(@{$users_sid{$current_sid}});
    foreach (@{$users_sid{$current_sid}}){
    my $fresh_new_sid=shift(@free_sids);
      print "User $_ gets sid ".$fresh_new_sid."\n";
  
    modify_user_sid($_,$fresh_new_sid);     } 
  
      }    
    }
    
    
    
 $ldap->unbind;   
