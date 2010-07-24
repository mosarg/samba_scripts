package Client::ParseLog;

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use DBI;
use DBD::mysql;
use Net::Ping;
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd);
use Client::configuration qw($wsus_log);
use Client::commands qw(execute_command);

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(mustreboot otherUpdatesRunning removelog);

sub mustreboot{
	my $client=shift;
	my $wsus_log= execute_shell_client_cmd($client,'type '.$wsus_log);
	($wsus_log=~m/reboot/)?return 1:return 0;
}


sub removelog{
	my $client=shift;
	execute_shell_cmd($client,'del '.$wsus_log);
}

sub otherUpdatesRunning{
	my $client=shift;
	my $wpkg_check_log=execute_command($client,'check_wpkg_running');
	($wpkg_check_log=~m/Nessuna/)?return 1:return 0;
}

1;