#!/usr/bin/perl
use strict;
use warnings;
use Client::startstop qw(turnoff_client);


turnoff_client($ARGV[0]);
