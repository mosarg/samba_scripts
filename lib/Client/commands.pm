package Client::commands;
use strict;
use warnings;
use YAML::XS qw(LoadFile);
use Client::configuration qw($remote_share $paths);
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd execute_net_client_cmd);



require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(execute_command);

my %defined_commands = %{ LoadFile('/opt/samba_scripts/commands.yaml') };

our $commands = $defined_commands{commands};


sub execute_command {
	my $currentClient  = shift;
	my $command = shift;

	if ( $commands->{$command} ) {

		if ( $commands->{$command} ne substitute_path( $commands->{$command} ) )
		{
			#print "Command with network access executed\n";
			return execute_net_client_cmd( $currentClient, $remote_share->{domain},
				substitute_path( $commands->{$command} ) );
		}
		else {
			#print "Command without network access executed\n";
			return execute_shell_client_cmd( $currentClient, $commands->{$command} );
		}

	}
	else {
		print "Command $command doesn't exist!\n";
		return;
	}
}

sub substitute_path {
	my $string = shift;
	foreach my $path ( keys %{$paths} ) {
		last if ( $string =~ s/\[$path\]/$paths->{$path}/g );

	}
	return $string;
}
1;