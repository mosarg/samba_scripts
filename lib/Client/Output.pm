package Client::Output;

use strict;
use warnings;
use Cwd;
use HTML::Tiny;
use HTML::Tabulate qw(render);

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK =qw(htmlOut);
  
sub htmlOut{
	my $page = HTML::Tiny->new;
	my $data=shift;
	my $tables='';
	foreach my $curClient (keys %{$data}){
		$tables .=$page->h1({'class'=>'clientHeader'},$curClient).renderHtmlTable($data->{$curClient});
	}


	return $page->html(
    [
      $page->head( $page->title( 'Sample page' ),
      	$page->link({'type'=>'text/css','href'=>'wpkg.css','rel'=>'stylesheet'} ) ),
      $page->body(
        [
          $page->h1( { class => 'main' }, 'Wpkg report page' ),
          $page->div({class=>'data'},$tables )
        ]
      )
    ]
  );
	

}	

sub renderHtmlTable{
	my $tableData=shift;
	my $table_defn = { 
        table => {class=>'packages'},
        tr => { class=>sub{ 
        	my $r=shift;	
        	if(defined($r->{alert})){
        	if ($r->{alert}==1){
        		return 'error';
        	}else{return 'normal';
        		
        	}
        	}
        }},
        null => '&nbsp;',
        labels => 1,
        fields => [ qw(package server_version client_version) ],
       };
    
    return render($tableData,$table_defn);
}  

1;