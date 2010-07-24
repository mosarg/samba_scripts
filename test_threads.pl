use threads;
use strict;
use warnings;
use Client::update qw(do_client_update);


my $test_th1=threads->create(\&do_client_update,'wilos',10);
#my $test_th=threads->create(\&test12);
#my $test_th1=threads->create(\&test12);
#$test_th->detach();
#$test_th1->detach();



sub test12{
	my $inc=int(rand(20));
	my $count=0;
	while ($count<$inc) {
		sleep 1;
		$count++;
	}
	return $inc;
}

    foreach (threads->list()){
    	print $_->join()."\n";
    }


