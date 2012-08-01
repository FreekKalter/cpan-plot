package CPAN::TesterStats::Plot;
use v5.12;
use strict;
use warnings;

use utf8;

use Cwd;
use Chart::Gnuplot;
use Path::Class;

my $dir = $ARGV[0] || ".";
my ( @sets, @delta_sets );
for my $file ( qw( total win32 mac linux) ){
    open my $fh , "<" , file($dir, "$file.data") or die "Could not open $file: $!";
    my ( @x, @y, @x_delta, @y_delta );

    <$fh> =~ /( \d{4} - \d{2} - \d{2} )  \t (\d*)/x;
    my $yesterday = $2;
    push @x, $1; 
    push @y, $2; 

    while( <$fh> ){
        /( \d{4} - \d{2} - \d{2} )  \t (\d*)/x;
        push @x       , $1;
        push @x_delta , $1;
        push @y       , $2;
        push @y_delta , $2 - $yesterday;
        $yesterday = $2;
    }

    push @sets , Chart::Gnuplot::DataSet->new(
        title   => "$file",
        xdata   => \@x,
        ydata   => \@y,
        style   => 'linespoints',
        timefmt => '%Y-%m-%d',      # input time format
    );
    
    push @delta_sets , Chart::Gnuplot::DataSet->new(
        title   => "$file",
        xdata   => \@x_delta,
        ydata   => \@y_delta,
        style   => 'linespoints',
        timefmt => '%Y-%m-%d',      # input time format
    );
}

# Initiate the chart object
my $output = file($dir, "output.png");
my $chart = Chart::Gnuplot->new(
   output   => $output->as_foreign('Unix'),
   xlabel   => 'Date axis',
   ylabel   => 'Number of test on cpan',
   bg       => 'white',
   legend   => {
        position    => "outside bottom",
        width       => 3,
        height      => 4,
        align       => "right",
        title       => "Legend",
   },
   timeaxis => "x",
   xtics    => {
        labelfmt => '%y/%m/%d',   
   },
);

# Set Gnuplot path for MS Windows
$chart->gnuplot('wgnuplot.exe') if ($^O eq 'MSWin32');
# Plot the graph
$chart->plot2d(@sets);

# Initiate the chart object
$output = file($dir, "delta_output.png");
$chart = Chart::Gnuplot->new(
   output   => $output->as_foreign('Unix'),
   xlabel   => 'Date axis',
   ylabel   => 'Number of test per day',
   bg       => 'white',
   legend   => {
        position    => "outside bottom",
        width       => 3,
        height      => 4,
        align       => "right",
        title       => "Legend",
   },
   timeaxis => "x",
   xtics    => {
        labelfmt => '%y/%m/%d',   
   },
);

# Set Gnuplot path for MS Windows
$chart->gnuplot('wgnuplot.exe') if ($^O eq 'MSWin32');
# Plot the graph
$chart->plot2d(@delta_sets);
