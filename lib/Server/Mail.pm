package Server::Mail;

use strict;
use warnings;
use experimental 'switch';
use Cwd;
use Getopt::Long;
use Net::LDAP;
use Data::Dumper;
use Mail::Box::Manager;
use Mail::Box::Tie::ARRAY;
use Date::Parse;
use YAML::XS qw(LoadFile DumpFile);
use List::Util qw(min);

use Server::Configuration qw($mail);
require Exporter;



our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(countMessages getNewMessages dumpNewMessages storeMessages);

sub storeMessages {
	my $mail_box_name           = shift;
	my $mail_folder_name        = shift;
	my $archiveopteryx_mail_box = shift;
	my $import_mail = dumpNewMessages( $mail_box_name, $mail_folder_name );
	
	
	foreach my $current_mail (@{$import_mail}){
	if ( $current_mail ne '' ) {
		print $mail->{archiveopteryx}->{aoximport}
		  . " -v -e $archiveopteryx_mail_box mbox $current_mail", "\n";
		system( $mail->{archiveopteryx}->{aoximport}
			  . " -v -e $archiveopteryx_mail_box mbox $current_mail" );
		
	}
	else {
		print "Nothing to import\n";
	}
	unlink($current_mail);
	}
	system( $mail->{archiveopteryx}->{aox} . " vacuum" );
}

sub countMessages {
	my $mail_box = shift;
	my $mgr      =
	  new Mail::Box::Manager( folderdir => $mail->{global_mail_folder} );
	my $folder = $mgr->open( folder => "=" . $mail_box );
	my $nr_messages = $folder->nrMessages;
	$folder->close;
	return $nr_messages;

}

sub dumpNewMessages {
	my %mail_state;
	my %current_mail_state;
	my $mail_box_name    = shift;
	my $mail_folder_name = shift;
	my $mail_folder_mgr  =
	  new Mail::Box::Manager( folderdir => $mail->{$mail_box_name} );
	my $folder = $mail_folder_mgr->open( folder => "=" . $mail_folder_name );
	my $tmp_mail_folder_mgr = new Mail::Box::Manager();
	my $tmp_mbox_file       = '/tmp/test' . $mail_folder_name;
	my $max_perfolder       = 150;
	my $max                 = 0;
	my $min                 = 0;
	my @tmp_mail_folders;
	
	
	if ( -f $mail->{global_mail_state} ) {
		%mail_state = LoadFile( $mail->{global_mail_state} );
	}
	else {
		print "Processing complete folder\n";
		%mail_state = (
			processed_msg => 0,
			last_timestp  => 0
		);
	}

	%current_mail_state = (
		processed_msg => $folder->nrMessages,
		last_timestp  => getMsgTime( $folder->message(-1) )
	);

	if ( $current_mail_state{processed_msg} <=
		$mail_state{processed_msg} )
	{
		DumpFile( $mail->{global_mail_state}, %current_mail_state );
		print "No new messages to process\n";
		push(@tmp_mail_folders,'');
		return \@tmp_mail_folders;
	}

	my $nbr_new_messages =
	  $current_mail_state{processed_msg} - $mail_state{processed_msg};

	print "There are $nbr_new_messages new messages\n";

	my @new_messages      = $folder->messages( -$nbr_new_messages, -1 );
	my $tmp_folder_number = int( $nbr_new_messages / $max_perfolder );
	
	print "$tmp_folder_number tmp folders will be created\n";

	for ( my $i = 0 ; $i <= $tmp_folder_number ; $i++ ) {

		my $tmp_folder = $tmp_mail_folder_mgr->open(
			type   => 'mbox',
			folder => $tmp_mbox_file . $i,
			create => 1,
			access => 'w'
		);
		
		push(@tmp_mail_folders, $tmp_mbox_file . $i);
		print "Create tmp folder $tmp_mbox_file", $i, "\n";
		$max = min( ( $i + 1 ) * $max_perfolder, $nbr_new_messages ) - 1;
		$min = $i * $max_perfolder;
		print "Processing messages from $min to $max\n";
		$mail_folder_mgr->copyMessage( $tmp_folder,
			@new_messages[ $min .. $max ] );
		$tmp_folder->close;

	}
	$folder->close;
	DumpFile( $mail->{global_mail_state}, %current_mail_state );
	return \@tmp_mail_folders;

}

sub getMsgTime {
	my $message = shift;
	return str2time( $message->head->get('Date') );
}

#sub getNewMessages {
#
#	  my $mail_box = shift;
#	  my $mgr      =
#		new Mail::Box::Manager( folderdir => $mail->{global_mail_folder} );
#	  my $tmp        = new Mail::Box::Manager();
#	  my $tmp_folder = $tmp->open(
#		  type   => 'mbox',
#		  folder => '/tmp/test',
#		  create => 1,
#		  access => 'w'
#	  );
#	  my $folder = $mgr->open( folder => $mail_box );
#
#	  my @messages = $folder->messages( -5, -1 );
#
#	  foreach my $message (@messages) {
#
#		  print str2time( $message->head->get('Date') ), " ",
#			$message->head->get('Date'), "\n";
#	  }
#
#	  $mgr->copyMessage( $tmp_folder, $folder->messages( -5, -1 ) );
#
#	  print $tmp_folder->nrMessages;
#
#	  #tie my(@inbox), 'Mail::Box::Tie::ARRAY', $folder;
#	  #tie my(@tmp_inbox),'Mail::Box::Tie::ARRAY', $tmp_folder;
#	  #print Dumper $inbox[-1];
#	  #push (@tmp_inbox,$inbox[-1]);
#	  #my $subset     = $folder->messages(-10,-8);
#	  #$folder->copyTo($tmp_folder,select=>\&filter);
#
#	  #	#my @messages=$folder->messages(-10,-8);
#	  #	#$tmp_folder->addMessages(@messages);
#	  #
#	  $folder->close;
#
#	  #return $subset;
#}

