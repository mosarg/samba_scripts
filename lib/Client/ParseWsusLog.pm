package Client::ParseWsusLog;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use DBI;
use DBD::mysql;
use Net::Ping;
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd);
use Client::configuration qw($wsus_log);

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(mustreboot);

sub mustreboot{
	my $client=shift;
	my $wsus_log= execute_shell_client_cmd($client,'type '.$wsus_log);
	($wsus_log=~m/reboot/)?return 1:return 0;
}


sub removelog{
	my $client=shift;
	execute_shell_cmd($client,'del '.$wsus_log);
}

1;