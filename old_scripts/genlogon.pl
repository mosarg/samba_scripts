#!/usr/bin/perl
#
# genlogon.pl
#
# Perl script to generate user logon scripts on the fly, when users
# connect from a Windows client.  This script should be called from smb.conf
# with the %U, %G and %L parameters. I.e:
#
#	root preexec = genlogon.pl %U %G %L
#
# The script generated will perform
# the following:
#
# 1. Log the user connection to /var/log/samba/netlogon.log
# 2. Set the PC's time to the Linux server time (which is maintained
#    daily to the National Institute of Standard's Atomic clock on the
#    internet.
# 3. Connect the user's home drive to H: (H for Home).
# 4. Connect common drives that everyone uses.
# 5. Connect group-specific drives for certain user groups.
# 6. Connect user-specific drives for certain users.
# 7. Connect network printers.

# Log client connection
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);










my($uid);
my(@groups);
my($entry);
my ($user)=$ARGV[0];



sub in_group{

my ($group)=shift;
my ($user)=shift;
my ($truth)=0;
my ($group_file)="/opt/scripts/samba/".$group.".components";

open MEMBERS, "< $group_file" or die "Can't open $group_file : $!";

my ($members)=<MEMBERS>;
if ( $members=~ m/.*$user.*/){
  $truth=1;
    }
    
  close MEMBERS;
return $truth;
}
        



# Start generating logon script
open LOGON, ">/home/netlogon/$ARGV[0].cmd";

#print LOGON "\@ECHO OFF\r\n";
print LOGON "NET USE /delete \\\\TSCLIENT\\dischi\n";

#monta la home directory su H:

#print LOGON "NET USE /delete H:\n";
#print LOGON "NET USE H: \\\\HILBERTO\\$ARGV[0]\n";

#Monta la directory pubblica

#print LOGON "NET USE /delete L:\n";

print LOGON "NET USE L: \\\\ltsp\\pubblico /PERSISTENT:NO\n";


#Monta la directory condivisa degli alunni

#print LOGON "NET USE /delete R:\n";
print LOGON "NET USE R: \\\\ltsp\\studenti /PERSISTENT:NO\n";

#Monta la directory condivisa dei professori
if (in_group("professori",$user)){
#print LOGON "NET USE /delete Y:\n";
#print LOGON "NET USE /delete K:\n";
#print LOGON "NET USE /delete N:\n";
print LOGON "NET USE Y: \\\\ltsp\\professori /PERSISTENT:NO\n";
print LOGON "NET USE K: \\\\ltsp\\istituti /PERSISTENT:NO\n";
print LOGON "NET USE N: \\\\ltsp\\circolari /PERSISTENT:NO\n";
}

#Monta la directory condivisa del sostegno
if (in_group("sostegno",$user)){
#print LOGON "NET USE /delete W:\n";
print LOGON "NET USE W: \\\\ltsp\\sostegno /PERSISTENT:NO\n";
}


close LOGON;
