package Server::Logon;

use strict;
use warnings;
use YAML::XS qw(LoadFile);
use Server::Configuration qw($dirs $server);
use Switch;
require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK =
  qw(inGroup setupClient selectComputer getLogonPrefs fileHeader insertWait removeAllPrinters);

sub setupClient {
	my $data       = shift;
	my $logon_file = shift;
	switch ($data->{type}){
		case 'terminalserver' {setupClientTerminalServer($data,$logon_file);	}
		else {setupClientStandalone($data,$logon_file);}
	}
}


sub setupClientStandalone{
	my $data       = shift;
	my $logon_file = shift;
	if ( defined( $data->{'printers'} ) ) {
		if ( defined( $data->{'printers'}->{'devices'} ) ) {
			foreach my $printer ( @{ $data->{'printers'}->{'devices'} } ) {
				push( @$logon_file, addPrinter($printer) );
			}
		}
		if (defined($data->{'printers'}->{'default'})){
			push(@$logon_file,setDefaultPrinter($data->{'printers'}->{'default'}) );			
		}
	}
	if ( defined( $data->{'shares'} ) ) {
		foreach my $share ( @{ $data->{'shares'} } ) {
			push( @$logon_file,
				addNetworkDrive( $share->{'drive'}, $share->{'share'} ) );

		}
	}
	if (defined( $data->{'scripts'} ) ){
		foreach my $script ( @{$data->{'scripts'}}){
			push( @$logon_file,
				addScript($script->{'shell'},$script->{'file'}));
		}
	}
}
sub setupClientTerminalServer{
	my $data=shift;
	my $logon_file=shift;
	my $vbs_script='';
	
	my @clients=keys %{$data->{clients}};
	
	$vbs_script="Dim Sh,client
				 Set Sh = CreateObject(\"WScript.Shell\")
				 client = Sh.ExpandEnvironmentStrings(\"%CLIENTNAME%\")
				 Dim regEx,Matches
   				 Set regEx = New RegExp
                 regEx.Pattern = \"(".join('|',@clients).")\"
   				 regEx.IgnoreCase = True
   				 regEx.Global = True
   				 Set Matches = regEx.Execute(client)
				 Select Case Matches(0).value\n";
	foreach my $terminal_client (@clients){
	$vbs_script.="case \"$terminal_client\"\n";
	if ( defined( $data->{'clients'}->{$terminal_client}->{'printers'}->{'devices'} ) ) {
		foreach my $printer ( @{ $data->{'clients'}->{$terminal_client}->{'printers'}->{'devices'} } ) {
				$vbs_script.=addPrinter($printer);
			}
		}
	if (defined($data->{'clients'}->{$terminal_client}->{'printers'}->{'default'})){
			$vbs_script.=setDefaultPrinter($data->{'clients'}->{$terminal_client}->{'printers'}->{'default'});			
		} 	
	
	}
		$vbs_script.="End Select\n";
		push(@$logon_file,$vbs_script);

}

sub selectComputer {
	my $computers      = shift;
	my $computer       = shift;
	my $computer_class = '';
	foreach my $current_computer (@$computers) {
		if ( $current_computer eq $computer ) {
			return $current_computer;
		}
		elsif ( $computer =~ /$current_computer/ ) {
			$computer_class = $current_computer;
		}
	}
	return $computer_class;
}

sub getLogonPrefs {
	
	return LoadFile( $server->{'logon_prefs_file'} );
}

sub inGroup {
	my $group       = shift;
	my $user        = shift;
	my $user_groups = `id $user`;
	( $user_groups =~ /$group/ ) ? return 1 : return '';
}

sub fileHeader {
	my $output="ON ERROR RESUME NEXT\n";
	$output.="dim objShell,objNetwork,allPrinters\n";
	$output.="set objShell=wscript.createObject(\"wscript.shell\")\n";
	$output.="set objNetwork = CreateObject(\"WScript.Network\")\n";
	return $output;
}

sub addScript{
	my $shell= shift;
	my $file=shift;
	my $output="objShell.run \"\\\\".$server->{'windows_name'}."\\netlogon\\$shell \\\\".$server->{'windows_name'}."\\netlogon\\".$file."\"\n ";
	return $output;
	
}

sub addPrinter {
	my $printer_name = shift;
	return "objNetwork.AddWindowsPrinterConnection \"\\\\"
	  . $server->{'windows_name'}
	  . "\\$printer_name\"\n";
}

sub removePrinter {
	my $printer_name = shift;
	return "objNetwork.RemovePrinterConnection \"\\\\"
	  . $server->{'windows_name'}
	  . "\\$printer_name\",\"true\",\"true\"\n";
}

sub cyclePrinter {
	my $printer_name = shift;
	return removePrinter($printer_name) . addPrinter($printer_name);
}

sub setDefaultPrinter {
	my $printer_name = shift;
	return "objNetwork.SetDefaultPrinter \"\\\\"
	  . $server->{'windows_name'}
	  . "\\$printer_name\"\n";
}

sub addNetworkDrive {
	my $network_letter = shift;
	my $network_share  = shift;
	my $output="objNetwork.RemoveNetworkDrive \"$network_letter\",true,true\n";
	$output.="objNetwork.MapNetworkDrive \"$network_letter\", \"\\\\". $server->{'windows_name'} . "\\$network_share\" \n";
	return $output;
}

sub insertWait {
	my $time = shift;
	return "wscript.sleep $time\n";

}

sub removeAllPrinters {
	return "Set allPrinters = objNetwork.EnumPrinterConnections
             For LOOP_COUNTER = 0 To allPrinters.Count - 1 Step 2
             If Left(allPrinters.Item(LOOP_COUNTER +1),2) = \"\\\\\" Then
                objNetwork.RemovePrinterConnection allPrinters.Item(LOOP_COUNTER +1),True,True
             End If
             Next\n";
}
