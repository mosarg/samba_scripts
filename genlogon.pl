#!/usr/bin/perl
#
use Server::Logon
  qw(removeAllPrinters setupClient selectComputer getLogonPrefs fileHeader insertWait  );
use Data::Dumper;
use Server::Configuration qw($server);
use Switch;
use warnings;
use strict;

#my $user=$ARGV[0];
#my $computer=$ARGV[2];

my $user     = 'protocollo';
my $computer = 'tiresia';

my $logonData = getLogonPrefs;

my @logonFile;

push( @logonFile, fileHeader() );
push( @logonFile, removeAllPrinters() );
push( @logonFile, insertWait('100'));	

#common section
setupClient( $logonData->{'common'}, \@logonFile );

#computer section

my @computers = keys( %{ $logonData->{'computers'} } );

my $selected_computer = selectComputer( \@computers, $computer );
if ($selected_computer) {
	setupClient( $logonData->{'computers'}->{$selected_computer}, \@logonFile );
	
}

#group section
my @groups = keys( %{ $logonData->{'groups'} } );

if (@groups) {
	my $id_information = `id $user`;

	foreach my $current_group (@groups) {
		if ( $id_information =~ /$current_group/ ) {
			setupClient( $logonData->{'groups'}->{$current_group},
				\@logonFile );
		}
	}
}

#users section
my @users = keys( %{ $logonData->{'users'} } );

foreach my $current_user (@users) {
	if ( $current_user=~/$user/i ) {
		setupClient( $logonData->{'users'}->{$current_user}, \@logonFile );
		last;
	}
}

open  my $logon , ">".$server->{'logon_script_dir'}."/$user.vbs";

print $logon @logonFile;

close $logon;

