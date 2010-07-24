#!/usr/bin/perl

use strict;
use warnings;
use Client::Info qw(substitute_path get_client_info get_clients_info);

foreach (@{get_clients_info()}){
	print $_->[0]."\n";
}


