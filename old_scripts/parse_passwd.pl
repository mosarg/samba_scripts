#!/usr/bin/perl -w

#setpwent();
$n=0;
$passwd = "/etc/passwd";
open(PW,$passwd) or die "Can't open $passwd:$!\n";

while (<PW>)  {
     ($LOGIN,$passwd,$uid,$gid,$gcos,$dir,$shell) = split(/:/);
     if(($uid>1000)&&($uid<5000)){
     @args=("ls","-lah");
     #@args_mod=("/usr/sbin/smbldap-usermod","-a","-C \\\\hilberto\\$UID","-D H:","-E $UID.cmd","-F \\\\hilberto\\profiles\\$UID");
     #@arg_pwd=("smbldap-passwd-cm","$LOGIN","$LOGIN");
     #system("smbldap-usermod -a -C '\\\\hilberto\\$LOGIN' -D H: -E $LOGIN.cmd -F '\\\\hilberto\\profiles\\$LOGIN' $LOGIN");
     #system("smbldap-passwd-cm $LOGIN $LOGIN");
     #system(@args);
     system("smbldap-usermod -g studenti $LOGIN");
     $n=$n+1;
     print $LOGIN;
     print $n."\n";
  #         print "$LOGIN,$PASSWORD,$UID,$GID,$QUOTA,$COMMENT,$GECOS,$HOMEDIR,$SHELL\n";
         }
                                     }
close(PW);
#endpwent();
                                     