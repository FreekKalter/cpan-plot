package CPAN::TesterStats::Get;

use v5.12;
use strict;
use warnings;
use utf8;

use LWP; 
use HTML::TreeBuilder;
use Data::Dumper qw( Dumper );
use DateTime;
use File::ReadBackwards;
use Path::Class;

my $dir = $ARGV[0] || ".";
my %scores = (
    total   => { address    => "http://stats.cpantesters.org/testers.html" ,
                 tests      => 0,
                 column     => 1,
               },
    mac     => { address    => "http://stats.cpantesters.org/leaders/leaders-darwin-all.html" ,
                 tests      => 0, 
                 column     => 3, 
               },
    win32   => { address    => "http://stats.cpantesters.org/leaders/leaders-mswin32-this.html" , 
                 tests      => 0, 
                 column     => 3,
               },
    linux   => { address    => "http://stats.cpantesters.org/leaders/leaders-linux-all.html" , 
                 tests      => 0, 
                 column     => 3,
               },
);
my $now = DateTime->now( time_zone => 'local' );
for my $key (keys %scores){
    #check last date
    my $last_date;
    my $filename = file($dir , "${key}.data");
    if(-e $filename ){ 
        my $bw = File::ReadBackwards->new( $filename ) or die "Could not read ${key}.data backwards: $!";
        my $last_line = $bw->readline;
        chomp $last_line;
        $bw->close;
        $last_line =~ /( \d{4} - \d{2} - \d{2} )  \t (\d*)/x;
        $last_date = $1;
    }else{
        $last_date = 0;
    }
    
    if ($now->ymd ne $last_date){
        my $web  = do_GET($scores{$key}{address});
        my $tree = HTML::TreeBuilder->new;
        $tree->parse($web);

        my $tr = $tree->look_down(
            '_tag' => 'tr',
            sub { $_[0]->look_down(
                            '_tag' => 'td',
                            sub{ $_[0]->as_text =~ m/kalter/i }
                )},
        );                   
        my @trs = $tr->descendants(); 

        open my $dh, ">>" , $filename;
        print $dh $now->ymd, "\t" , $trs[$scores{$key}{column}]->as_text(), "\n";
        close $dh;
    }
}

sub do_GET {
    my $browser;
    $browser = LWP::UserAgent->new unless $browser;
    my $resp = $browser->get(@_);
    return ( $resp->content, $resp->status_line, $resp->is_success, $resp )
      if wantarray;
    return unless $resp->is_success;
    return $resp->content;
}
