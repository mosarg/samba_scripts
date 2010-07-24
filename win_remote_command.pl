#!/usr/bin/perl
use strict;
use warnings;
use Client::RemoteExecution qw(execute_client_cmd execute_shell_client_cmd);


print execute_shell_client_cmd($ARGV[0],'%programfiles%\esegui_aggiornamento\update.cmd');