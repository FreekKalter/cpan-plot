package CPAN::TesterStats::Plot;
use v5.12;
use strict;
use warnings;

use utf8;

use Cwd;
use Chart::Gnuplot;
use Path::Class;

# Initiate the chart object
my $output = file(getcwd(), 'plot.png');
say $output;
my $chart = Chart::Gnuplot->new(
   output => $output->as_foreign('Unix'),
);

# Set Gnuplot path for MS Windows
$chart->gnuplot('wgnuplot.exe') if ($^O eq 'MSWin32');

# Raw data
my @x = (1, 2, 3, 4, 5, 6);
my @y = (2, 8, 3, 2, 4, 0);

my $points = Chart::Gnuplot::DataSet->new(
    xdata => \@x,
    ydata => \@y,
    style => 'linespoints',
);
my $csplines = Chart::Gnuplot::DataSet->new(
    xdata  => \@x,
    ydata  => \@y,
    style  => 'lines',
    smooth => 'csplines',
    title  => 'Smoothed by cubic splines',
);
my $bezier = Chart::Gnuplot::DataSet->new(
    xdata  => \@x,
    ydata  => \@y,
    style  => 'lines',
    smooth => 'bezier',
    title  => 'Smoothed by a Bezier curve',
);

# Plot the graph
$chart->plot2d($points, $csplines, $bezier);
