package CPAN::TesterStats::Get;

use v5.12;
use strict;
use warnings;

use utf8;

use LWP; 
use HTML::TreeBuilder;
use Data::Dumper qw( Dumper );
use DateTime;

my %scores = (
    total   => { address => "http://stats.cpantesters.org/testers.html" ,
                 tests => 0 },
    mac     => { address => "http://stats.cpantesters.org/leaders/leaders-darwin-this.html" ,
                 tests => 0 } ,
    win32   => { address => "http://stats.cpantesters.org/leaders/leaders-mswin32-this.html" , 
                 tests => 0 },
);
my $now = DateTime->now( time_zone => 'local' );

for my $key (keys %scores){

    my $web  = do_GET($scores{$key}{address});
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($web);

    my $tr = $tree->look_down(
        '_tag' => 'tr',
        sub { $_[0]->look_down(
                        '_tag' => 'td',
                        sub{ $_[0]->as_text =~ m/freek.*kalteronline.*org/ }
            )},
    );                   
    my @trs = $tr->descendants(); 
    open my $dh, ">>" , "${key}.data";
    print $dh $now->ymd, "\t";
    if($key eq 'total'){
        print $dh $trs[1]->as_text(), "\n";
        $scores{$key}{tests} = $trs[1]->as_text();
    }else{
        print $dh $trs[2]->as_text(), "\n";
        $scores{$key}{tests} = $trs[2]->as_text();
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
