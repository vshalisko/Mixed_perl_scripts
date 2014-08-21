#!/usr/local/bin/perl

## Created 11.2008 by Viacheslav Shalisko 
## Stript to prepare data in AKTerm (meteorological time series in the format used by the German Weather Service, DWD)#
## Input data in table form for single meteorological station                                                                                                                       
#
# Output data format: 
# The data part consists of lines each with 16 entries that are separated by exactly one
# blank. The entries are:
# Entry Meaning Position Value range
# KENN Data set ID (*) 1 bis 2 AK
# STA Station ID (*) 4 bis 8 00001-99999
# JAHR Year 10 bis 13 1800-2...
# MON Month 15 bis 16 1-12
# TAG Day 18 bis 19 1-31
# STUN Hour 21 bis 22 0-23
# NULL Zeros 24 bis 25 0
# QDD Quality byte (wind direction) 27 0,1,2,9 (2 - in degrees)
# QFF Quality byte (wind speed) 29 0,1,2,3,9   (1 - in 0.1 m/s)
# DD Wind direction 31 bis 33 0-360,999
# FF Wind Speed 35 bis 37 0-999
# QB Quality byte (value status) (*) 39 0-5,9
# KM Klug/Manier stability class 41 1-7,9
# QB Quality byte (value status) (*) 43 0,1,9
# HM Mixing layer height (m) (*) 45 bis 48 0-9999
# QB Quality byte (value status) (*) 50 0-5,9
# (*) Value required but not evaluated
# 
# QDD Definition
# 0 Wind Direction in Dekagrad
# 1 Wind Direction in Grad, Original in Dekagrad
# 2 Wind Direction in Grad, Original in Grad
# 9 Wind Direction missing
# QFF Definition
# 0 Wind Speed in Knots
# 1 Wind Speed in 0,1 m/s, Original in 0,1 m/s
# 2 Wind Speed in 0,1 m/s, Original in Knots (0,514 m/s)
# 3 Wind Speed in 0,1 m/s, Original in m/s
# 9 Wind Speed missing
# The entry KM has the value 7, if the dispersion category can not be determined and the value 9 if it is missing.

use Text::ParseWords;
use Time::localtime;

my $input = $ARGV[0];
my $output = $input.".akterm";
my ($header, $header1) = ();
my (@lines) = ();
my %elements = ();
my ($startdate, $enddate) = ();

open(DATAFILE, "<$input") || die "\nUnable to open file $input\n";
  @lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines;
#$header1 = shift @lines;

if (-e $output) { 
  die "\nFile $output already exists.\nRemove it.\n" 
}

my $first_line = 0;
foreach my $item (@lines) {
  my @values = &parse_csv($item);

  foreach (@values) { chomp; }

  if ( (scalar @values >= 27) && (!defined $startdate) ) # start date check
  { 
    $startdate = $values[0];
    $enddate = $startdate;
  }
  elsif ((scalar @values >= 27) && (defined $startdate)) # end date check
  {
    if (defined $enddate && 
      (
      substr($enddate,3,2) < substr($values[0],3,2) || 
      substr($enddate,0,2) < substr($values[0],0,2) ||
      substr($enddate,7,4) < substr($values[0],7,4)
      )
    ) 
    {
      $enddate = $values[0];
    }
  }


  if ( (scalar @values >= 27) && ($values[2] =~ /(WDR|WSP)/i) ) 
  {
    my $class = $1;
    $elements->{$values[0]}->{$values[1]}->{$class} = {  # date -> station -> measure -> time
                                  '0' => $values[3],
                                  '1' => $values[4],
                                  '2' => $values[5],
                                  '3' => $values[6],
                                  '4' => $values[7],
                                  '5' => $values[8],
                                  '6' => $values[9],
                                  '7' => $values[10],
                                  '8' => $values[11],
                                  '9' => $values[12],
                                  '10' => $values[13],
                                  '11' => $values[14],
                                  '12' => $values[15],
                                  '13' => $values[16],
                                  '14' => $values[17],
                                  '15' => $values[18],
                                  '16' => $values[19],
                                  '17' => $values[20],
                                  '18' => $values[21],
                                  '19' => $values[22],
                                  '20' => $values[23],
                                  '21' => $values[24],
                                  '22' => $values[25],
                                  '23' => $values[26],
                                  };
    print ".";
  }
  else 
  {
    print "!";
  }
}

print "\n\n";

open(DATAFILE, ">$output") || die "\nUnable to open file $output\n"; 

printf DATAFILE <<"OUT", localtime->mday(), localtime->mon()+1, localtime->year()+1900, localtime->hour(), localtime->min(), localtime->sec();
* AKTERM, Mexican Weather
* Period $startdate to $enddate
* Anonymized data, date: %02d.%02d.%d %02d:%02d:%02d
+ anemometer heights (0.1 m): 32 41 57 74 98 144 200 244 283
OUT


  foreach my $ref_1 (sort {substr($a,3,2) <=> substr($b,3,2) || substr($a,0,2) <=> substr($b,0,2)} keys %$elements)
  {
    # day level
    foreach my $ref_2 (sort keys %{$elements->{$ref_1}})
    {
      # weather station level
       for ($i=0; $i < 24; $i++) 
       {



        my $wsp = $elements->{$ref_1}->{$ref_2}->{WSP}->{$i} * 10;  # wind speed in 0.1 m/s
        $ref_1 =~ m/(\d+)\/(\d+)\/(\d+)/i;                          # date
        print DATAFILE "AK 00001 ";
        printf DATAFILE "%4.4d %2.2d %2.2d %2.2d ", $3, $2, $1, $i;
        print DATAFILE "00 2 1 ";
        printf DATAFILE "%3.3d %3.3d ", $elements->{$ref_1}->{$ref_2}->{WDR}->{$i}, $wsp;
        print DATAFILE "0 3 0 -999 0\n";
        print "+";
      }
    }
  }

# print $elements->{'01/01/2007'}->{'CEN'}->{'WDR'}->{'00'}; # test of first element

close(DATAFILE);

sub parse_csv {
  return quotewords(",",0, $_[0]);
}


################################

