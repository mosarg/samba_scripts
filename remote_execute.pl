#!/usr/bin/perl

use strict;
use warnings;
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd execute_net_client_cmd);
use Getopt::Long;



my $client='localhost';
my $command='notepad';
my $share='';

GetOptions('client=s'=>\$client,'share=s'=>\$share,'command=s'=>\$command);

if($client ne 'localhost'){
print execute_net_client_cmd($client,$share,$command);
}else{
	print 'localhost is obviously not a windows client!',"\n";
}