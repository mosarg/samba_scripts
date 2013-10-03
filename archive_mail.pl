#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Server::Mail qw(storeMessages dumpNewMessages);


use Getopt::Long;



my $folder='testmail';

GetOptions('folder=s'=>\$folder);

#dumpNewMessages('global_mail_folder',$folder);

storeMessages('global_mail_folder',$folder,'/users/segreteria/2010');