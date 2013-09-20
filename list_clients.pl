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

GetOptions('group=s'=>\$group,'format=s'=>\$format);


for ($format){
when(/plain/){
	foreach (@{get_clients_info($group)}){
		print $_->[0]."\n";
	    isClientUp($_->[1]);
	}
}
when(/xml/){
		foreach (@{get_clients_info($group)}){
		print "< node name=\"$_->[0]\" description=\"pc laboratorio\" tags=\"\" hostname=\"$_->[0].linussio.net\" osArch=\"x86\" osFamily=\"windows\" osName=\"Windows 7\" osVersion=\"6.1\" username=\"installservice\"/>\n";
	    
	}
}

}










