use strict;
use warnings;

open FILE, "<", "../tests/fdisk.lc" or die $!;

my @disks;
my @partitions;
my @disk_partitions=<FILE>;

	foreach my $disk_partition (@disk_partitions) {

		#print $disk_partition,"\n";

		if ( $disk_partition =~ /Disk\s+\/dev\/(\w+):.+,\s+(\d+)\s+bytes/ ) {
			push( @disks,
				{ 'device_name' => $1, 'device_size' => int( $2 / 1048576 ) } );
		}

		if ( $disk_partition =~
			/\/dev\/(\w+\d).+(\d+)\s+(\d+)\s+(\d+)\s+(\w+|\d+)\s+/ )
		{
			print "$1 $2 $3 $4 $5\n";
			push(
				@partitions,
				{
					'device_name'   => $1,
					'start_block'   => $2,
					'end_block'     => $3,
					'blocks_number' => $4,
					'type'          => $5
				}
			);

#print "Device name: $1 Start Block: $2 End block: $3 Blocks number: $4 Type: $5 \n";
		}

	}