package Client::RemoteExecution;
use Encode qw(decode encode);
use strict;
use warnings;
use Cwd;
use Unicode::String qw(latin1 utf8);
use Getopt::Long;
use Net::Ping;
use Client::configuration


  qw($remote_executer $network_user $domain  $remote_user $remote_password);
	use IPC::Run qw( run timeout );

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK =qw(execute_client_cmd execute_shell_client_cmd execute_net_client_cmd);
sub execute_client_cmd {
	my $client  = shift;
	my $command = shift;
	my $ping    = Net::Ping->new();
	my $input;
	my $output;
	my $error;
	$ping->port_number('139');
	my $remote_command = " --runas $domain\/$remote_user\%$remote_password ";
	$remote_command =
	  $remote_command
	  . " -U $domain\/$remote_user\%$remote_password  \/\/$client \"$command\" ";
	if ( $ping->ping( $client, '5' ) ) {
		my @command = (
			$remote_executer,'--uninstall', '--runas',
			"$domain\/$remote_user\%$remote_password", '-U',
			"$domain\/$remote_user\%$remote_password", "\/\/$client",
			"$command"
		);
		run \@command, \$input, \$output,\$error;
		return $output.' '.$error;
		
	}
	else {
		return 'offline';
	}
}
sub execute_shell_client_cmd {
	my $client  = shift;
	my $command = shift;
	return decode('IBM850',execute_client_cmd( $client, 'cmd  /c ' . $command ));
}
sub execute_net_client_cmd {
	my $client     = shift;
	my $location   = shift;
	my $command    = shift;
	my $net_access = 'net use '
	  . $location . ' '
	  . '/USER:'
	  . $network_user->{domain} . "\\"
	  . $network_user->{username} . " "
	  . $network_user->{password}.">null";

	my $net_leave = 'net use /delete ' . $location.">null";

	return decode('IBM850',execute_client_cmd( $client,
		'cmd  /c  "' . $net_access . "&" . $command ."&".$net_leave.'"' ));
}

1;
