#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Client::commands qw(execute_command);
use Switch;

my $clients = 'localhost';
my $command = 'notepad';
my $all     = '';

GetOptions(
	'clients=s' => \$clients,
	'command=s' => \$command,
	'all'       => \$all
);

if ($all) {
	foreach my $computer ( @{ get_clients_info() } ) {
		execute_command( $computer->[1], $command );
	}
}
else {
	switch ($clients) {
		case "test" {print "Test case\n";}
		case /\,/ {
			foreach my $computer ( split( /,/, $clients ) ) {
				print execute_command( $computer, $command ),"\n";
			}

		}
		case /\|/ { print "Use , as client separator\n"; }
		else { print execute_command( $clients, $command ), "\n"; }
	}

}
