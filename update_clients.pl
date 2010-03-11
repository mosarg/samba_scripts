#!/us r/bin/perl

use strict;
use warnings;
use Client::startstop qw(wakeup_clients checkclients_up turnoff_clients);


#wake up all clients

wakeup_clients();

#wakeup_clients
print "I'm waiting 120 seconds for hosts to come up\n";

sleep 120;

#check all host are up
checkclients_up();

#turn off all computers
turnoff_clients();



