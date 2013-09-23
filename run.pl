#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Client::commands qw(execute_command list_commands);
use Client::Info qw(get_clients_info);
use Switch;

binmode STDOUT, ":utf8";

my $clients = 'localhost';
my $command = 'notepad';
my $group = '';
my $all     = '';
my $list_commands ='';
my $exclude='localhost';

GetOptions(
	'clients=s' => \$clients,
	'command=s' => \$command,
	'all'       => \$all,
	'group=s'   => \$group,
	'exclude=s' =>\$exclude,
	'list-commands'=>\$list_commands
);

#todo: rewrite commands router

if($list_commands){
	list_commands();
	exit;
}


if ($all) {
	my @excludes=split(',',$exclude);
	foreach my $computer ( @{ get_clients_info($group) } ) {
		if(!$computer->[0]~~@excludes){
			print "Current computer $computer->[0] ip ",$computer->[1]," \n";
			execute_command( $computer->[1], $command );
			sleep 5;
		}
		
	}
}
else {
	switch ($clients) {
		case "test" {print "Test case\n";}
		case /\,/ {
			foreach my $computer ( split( /,/, $clients ) ) {
				print "Current computer ",$computer," \n";
				print execute_command( $computer, $command ),"\n";
				sleep 5;
			}

		}
		case /\|/ { print "Use , as client separator\n"; }
		else { print execute_command( $clients, $command ), "\n"; }
	}

}
