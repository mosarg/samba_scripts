use strict;
use warnings;
use Server::Configuration qw($ldap $programs);
use Net::LDAP;
use Data::Dumper;
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use Server::LdapQuery qw(   getUsers getUserFromHumanName getUserHome);

#quick hack need through rewrite

my @human_name;
my $users_file='/tmp/bluestring_users';
my $user_home_dir='';
my $user_name='';
my @bstring_data=('Coge07','Bluestring.lnk','Gestionale.lnk');
open(USERS, $users_file) || die("Could not open file!");
my @users=<USERS>;
chomp(@users);
foreach (@users){
	 @human_name=split(' ',$_);
	 $user_name=getUserFromHumanName($human_name[1],$human_name[0]);
	 $user_home_dir=getUserHome($user_name);
	 
	 if($user_home_dir){
	 print $_." ".$user_home_dir."\n";
	 dircopy($programs->{'bstring'}."/".$bstring_data[0],$user_home_dir."/".$bstring_data[0]);
	 fcopy($programs->{'bstring'}."/".$bstring_data[1],$user_home_dir."/Desktop");
	 fcopy($programs->{'bstring'}."/".$bstring_data[1],$user_home_dir."/Desktop");
	 foreach my $data_element (@bstring_data){
	 	system("chown $user_name.studenti -R \"".$data_element."\"");
	 }
	 
	 }else{
	 	print $_." not present\n";
	 }
} 
close(USERS);