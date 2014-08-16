package Client::Log;

use strict;

use Cwd;
use Getopt::Long;
use Client::configuration qw($log_info);
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Switch;



require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(doLog transportMail);


sub doLog{
	my $transport=shift;
	my $subject=shift;
	my $message=shift;
	
	switch($transport){
		case 'mail'{
			transportMail($log_info->{'email_recipient'},$log_info->{'email_sender'},
			$subject,$message);
		}
	}
}


sub transportMail{
	my $recipient=shift;
	my $sender=shift;
	my $subject=shift;
	my $message=shift;
	
	my $email = Email::Simple->create(
    header => [
      To      => $recipient,
      From    => $sender,
      Subject => $subject,
    ],
    body => $message,
  );

  sendmail($email);
}





1;