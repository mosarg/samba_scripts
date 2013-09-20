#!/usr/bin/perl

use strict;
use warnings;
use Client::Info qw(getWpkgPkgRev isClientUp collectClientsPackagesInfo getPackageMismatch get_client_info get_clients_info showClientConfig getWpkgConfig);
use Client::ParseLog qw(parseXml );
use Data::Dumper;
use HTML::Tabulate qw(render);
use Client::configuration qw( $reports);
use Getopt::Long;
use feature "switch";

my $group='';
my $format='plain';
my $osName='Windows 7';
my $osVersion='6.1';
my $osArch='x86';

GetOptions('group=s'=>\$group,'format=s'=>\$format,'osname=s'=>\$osName,'osversion=s'=>\$osVersion);


for ($format){
when(/plain/){
	foreach (@{get_clients_info($group)}){
		print $_->[0]."\n";
	    isClientUp($_->[1]);
	}
}
when(/xml/){
		foreach (@{get_clients_info($group)}){
		print "<node name=\"$_->[0]\" description=\"pc laboratorio\" tags=\"\" hostname=\"$_->[0].linussio.net\" osArch=\"$osArch\" osFamily=\"windows\" osName=\"$osName\" osVersion=\"$osVersion\" username=\"installservice\"/>\n";
	    
	}
}

}










