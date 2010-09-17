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




sub print_group_members{

my ($group)=shift;

my (@members)=get_group_members($group);

my ($output_file)=$group.".components";

open OUT, "> $output_file" or die "Can't open $output_file : $!";

foreach my $member (@members){

print OUT $member."-";

}
close OUT;

}

sub in_group{

my ($group)=shift;
my ($user)=shift;
my ($truth)=0;
my ($group_file)=$group.".components";

open MEMBERS, "< $group_file" or die "Can't open $group_file : $!";

my ($members)=<MEMBERS>;
if ( $members=~ m/.*$user.*/){
  $truth=1;
  }

if ($truth){
  print "Hurra!\n";
  }

close MEMBERS;
}



print_group_members($ARGV[0]);

in_group("professori","mosa");
