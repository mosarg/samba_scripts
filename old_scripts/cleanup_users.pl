#!/usr/bin/perl
#kill all runaway users
use Proc::ProcessTable;
use Net::LDAP;
use strict;

my($ldap) = Net::LDAP->new("127.0.0.1") || die "can't connect to !: $@";
my($proctable) = new Proc::ProcessTable || die "can't get running process";




sub get_user_fromuid {

            my($uid)=shift;
            $ldap->bind;
            my($data) = $ldap->search(base=> "ou=Users,dc=linussio,dc=net",
                                                scope =>'sub',
                                                filter => "&(objectclass=posixAccount) (uidNumber=$uid)");

            $data->code && die $data->error;
            my(@output)=$data->entries();
            if (@output){
            return $output[0]->get_value('uid');
            }else{
            return "empty";
            }
            $ldap->unbind;

}


sub kill_runaway_users{

         my %users_list;
         my $process;

         foreach $process ( @{$proctable->table} ){
         
         $users_list{$process->uid}=$users_list{$process->uid}+1

        }

        for my $key (keys %users_list)
          { 
            if (($key >1000) && ($key < 2000)){
                my($user)=get_user_fromuid($key);
                print "User uid is ".$key."\n";
                if ($user ne "empty"){
                  print "I'm going to kill ".$user."\n";
                  my(@args)=("/usr/bin/killall -u $user");
                  system(@args)==0 or die "system @args failed: $?";	
                  }else
                    {print "No users to kill!\n";}
                    }else{
                    print "Nothing to do for uid $key  $users_list{$key} processes\n";
                    }
                    
                    }
                  }


kill_runaway_users();

