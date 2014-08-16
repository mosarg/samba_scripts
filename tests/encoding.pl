#!/usr/bin/perl
use encoding 'utf8', Filter => 1;
use strict;
use warnings;
use Text::Capitalize;
use Server::Commands qw(sanitizeString sanitizeSubjectname sanitizeUsername);

my $name="CHIARA";
my $surname="D'INCA'";

$name=sanitizeString( capitalize( lc( $name) ) );
$surname=sanitizeString( capitalize( lc( $surname ) ) );

print "$name $surname \n";
print sanitizeUsername($name.$surname);