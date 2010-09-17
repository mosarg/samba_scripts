#!/usr/bin/perl

use strict;
use warnings;
use Client::Info qw(getWpkgPkgRev isClientUp collectClientsPackagesInfo getPackageMismatch get_client_info get_clients_info showClientConfig getWpkgConfig);
use Client::ParseLog qw(parseXml );
use Client::Output qw(htmlOut);
use Data::Dumper;
use HTML::Tabulate qw(render);
use Client::configuration qw( $reports);
use Getopt::Long;

my $group='';

GetOptions('group=s'=>\$group);


foreach (@{get_clients_info($group)}){
		print $_->[0]."\n";
	    isClientUp($_->[1]);
}










