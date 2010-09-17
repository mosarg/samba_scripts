#!/usr/bin/perl
use strict;

my @users=`ls /home/liceo`;


foreach my $user (@users){
#my $user_new=chomp($user);
$user=~ s/\r?\n$//;
#print "sudo -H -u $user test\n";  
    system("sudo -H -u $user /opt/scripts/misc/remove.sh");
    }