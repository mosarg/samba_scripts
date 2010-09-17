#!/usr/bin/perl
use strict;

#my $link_file="\"/home/professori/condivisi/qualifica_2007_2008/III BP TUR OSBAT/DOCUMENTI EXCEL/giudizi  base da rielaborare.xls\"";

#my $link_file="\"/home/professori/condivisi/qualifica_2007_2008/III\ AP\ \ AZ\ GUZZON/DOCUMENTI\ EXCEL\ GUZZON/giudizi  base da rielaborare guzzon.xls\"";

my $link_file="\"/home/professori/condivisi/qualifica_2007_2008/III AC IPSIA/DOCUMENTI EXCEL IPSIA/giudizi  base da rielaborare.xls\"";

my $professors="/opt/scripts/manteinance/prof3aceconi.txt";
open HOMES,"<",$professors or die "can't open file $professors";
my @professors_home=<HOMES>;
chomp(@professors_home);

foreach my $home(@professors_home){
my $link_to="/home/professori/$home/Desktop/giudizi_qualifica_3aceconi.xls";


#system("ls -lah $link_file");
system("ln -s $link_file $link_to");
system("chmod 770 $link_to");

print "$home\n";

}