#!/usr/bin/perl
use strict;
use warnings;
use Cwd;

use Nmap::Parser;

my $nmap = new Nmap::Parser;
my $nmap_path='/usr/bin/nmap';
my $nmap_args='-sP';


my @ips=('192.168.0.0/24');
$nmap->parsescan($nmap_path, $nmap_args, @ips);

my @hosts = $nmap->all_hosts('up');

foreach my $host (@hosts){
	
	print $host->addr()."\n";

}