#!/usr/bin/perl
use strict;
use Data::Dumper;
use warnings;
use Cwd qw(abs_path);

my $pragmaModules=['Cwd','strict','Encode','warnings','Getopt::Long','File::Copy','Term::ANSIColor','threads','File::Path','Data::Dumper','Net::Ping'];



installPackages();
#print Dumper listUsedPackages();



sub installPackages{
	my $packages=listUsedPackages();
	my $result;

	
	foreach my $package (keys %{$packages}){
		print "Installing $package\n";
		$result=`cpan -i $package`;
	}
}



sub listUsedPackages{
	my $path=currentDir();
	my @packages=`egrep -rho '^use\\s\\w+::\\w+|^use\\s\\w+' $path`;
	my $result={};
	chomp @packages;
	
	foreach my $package (@packages){
		$package=~s/use\s//;
		if ( !($package=~m/Server::|Client::/)&&!($package~~ @{$pragmaModules}) ){
					
			$result->{$package}=++$result->{$package};
			
	}
		}
	return $result;
	
}


sub currentDir{

my $path = abs_path();
$path=~s/\/\w+$//;
return $path; 
	
}