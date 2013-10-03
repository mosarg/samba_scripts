#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Server::Mail qw(countMessages);


use Getopt::Long;



my $folder='Inbox';

GetOptions('folder=s'=>\$folder);


print "Folder $folder contains ",countMessages($folder)," messages\n";