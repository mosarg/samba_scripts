#!/usr/bin/perl

use strict;

#####################################
# give_quota(<users group>,<credit>)
#####################################




sub give_quota{

my ($group)=shift;
my ($quota)=shift;
my ($truth)=0;
my ($group_file)="/opt/scripts/printing/".$group.".components";

if ($group ne "generic"){
  open MEMBERS, "< $group_file" or die "Can't open $group_file : $!";
  my (@members)=<MEMBERS>;
    foreach my $member (@members){
    system("pkusers -b $quota $member");
    print "pkusers -b $quota $member \n";
    }
  close MEMBERS;
}else
{

system("pkusers -b $quota");
print "pkusers -b $quota\n";
}
    
return $truth;
}
        




# generic users are given a standard quota of 5 euro/month
give_quota("generic",5);
# system administrators are almost quotaless
give_quota("administrators",1000);
# generic users for non-supervised laboratories are given 150 euro/month
give_quota("unsupervised",150);
# privileged users are given 15 euro/month worth of printing
give_quota("privileged",15);


