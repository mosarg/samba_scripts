#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Client::commands qw(execute_command);


my $client='localhost';
my $command='notepad';


GetOptions('client=s'=>\$client,'command=s'=>\$command);

print execute_command($client,$command),"\n";