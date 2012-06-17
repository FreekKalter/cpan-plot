package CPAN::TesterStats::Plot;
use v5.12;
use strict;
use warnings;

use utf8;

use Cwd;
use Chart::Gnuplot;
use Path::Class;


for my $file ( qw( total win32 mac ) ){
    open my $fh , "<" , "$file.data" or die "Could not open $file: $!";
    my (@x, @y, @sets);
    while( <$fh> ){
        /(\d{4}-\d{2}-\d{2})\t(\d*)/;
        push @x, $1;
        push @y, $2;
    }

    push @sets , Chart::Gnuplot::DataSet->new(
        xdata => \@x,
        ydata => \@y,
        style => 'linespoints',
    );
#    my $csplines = Chart::Gnuplot::DataSet->new(
#        xdata  => \@x,
#        ydata  => \@y,
#        style  => 'lines',
#        smooth => 'csplines',
#        title  => 'Smoothed by cubic splines',
#    );
#    my $bezier = Chart::Gnuplot::DataSet->new(
#        xdata  => \@x,
#        ydata  => \@y,
#        style  => 'lines',
#        smooth => 'bezier',
#        title  => 'Smoothed by a Bezier curve',
#    );
}

# Initiate the chart object
my $output = file(getcwd(), "output.png");
my $chart = Chart::Gnuplot->new(
   output => $output->as_foreign('Unix'),
);

# Set Gnuplot path for MS Windows
$chart->gnuplot('wgnuplot.exe') if ($^O eq 'MSWin32');
# Plot the graph
$chart->plot2d(@sets);
