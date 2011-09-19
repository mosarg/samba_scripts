package Client::ParseLog;

use strict;
use warnings;
use XML::Simple;

use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd);
use Client::configuration qw($wsus_log);
use Client::commands qw(execute_command);
use Client::commands qw(execute_command);

require Exporter;


our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(checkAxiosUpdateState mustreboot otherUpdatesRunning removelog parseXml);

sub mustreboot {
	my $currentClient    = shift;
	my $current_wsus_log =
	  execute_shell_client_cmd( $currentClient, 'type ' . $wsus_log );
	 
	( $current_wsus_log =~ m/reboot/ ) ? return 1 : return '';
}

sub checkAxiosUpdateState{
	my $currentClient    = shift;
	my $current_axios_log =
	  execute_command( $currentClient, 'get_axioslog');
	( $current_axios_log =~ m/errore/ ) ? return 1 : return '';
}


sub removelog {
	my $currentClient = shift;
	execute_shell_cmd( $currentClient, 'del ' . $wsus_log );
}

sub otherUpdatesRunning {
	my $currentClient  = shift;
	my $wpkg_check_log =
	  execute_command( $currentClient, 'wpkg_check_running' );
	($wpkg_check_log =~ m/Nessuna/ ) ? return '' : return 1;
}

sub parseXml {
	my $xmlFile   = shift;
	my $xmlConfig = XMLin($xmlFile);
	return $xmlConfig;
}

1;
