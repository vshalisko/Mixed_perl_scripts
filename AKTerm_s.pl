#!/usr/local/bin/perl

#
##---------------------------------------------------------------------------##
##  Author:
##      Viacheslav Shalisko       vshalisko@gmail.com
##  Description:
##     Stript to prepare data in time series .DMNA format for use with GNU AUSTAL 2000 software
##  Created: 
##      11.2008
##---------------------------------------------------------------------------##
##    
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##---------------------------------------------------------------------------##
## 
##  Input data in table form for single meteorological station and values in parameter section pf this file
##  Output data in time series DMNA format suitable to use with AUSTAL2000 ver 2.4.4 as series.dmna archive
#


# =========== input parameter section ==============================================================
#  sample parameters set for use with 27 zones of contaminant emissions for Calzada Independencia - Gobernador Curiel (Guadalajara, Mexico) urban traffic simulation

#  my $segment_number = 27; # number of zones of contaminant emissions
  my $segment_number = 0; # excluding contaminant emissions columns
  my %segment_hash = ( # table that designates contribution of each segment in total contamination (parts of total contamination)
       1 => 0.0415,  2 => 0.0451,  3 => 0.0527,  4 => 0.0377,  5 => 0.0364,  6 => 0.0644,
       7 => 0.0373,  8 => 0.0283,  9 => 0.0565, 10 => 0.0424, 11 => 0.0520, 12 => 0.0419,
      13 => 0.0759, 14 => 0.0326, 15 => 0.0342, 16 => 0.0584, 17 => 0.0572, 18 => 0.0279,
      19 => 0.0245, 20 => 0.0149, 21 => 0.0219, 22 => 0.0257, 23 => 0.0268, 24 => 0.0267,
      25 => 0.0214, 26 => 0.0159, 27 => 0.0001, 
    );
  my %contaminants_hash = ( # values of total contamination in peak-hours (highest contamination values)
      'xx' => 171.736,  # CO (g/s)
      'no2' => 23558.864,   # CO2 (g/s)
      'nox' => 33.147,  # NOx (g/s)
      'bzl' => 39.608,  # VOC (g/s)
      'pm-2' => 8.973,  # PM-10 (g/s)
      'so2' => 7.248,   # SO2 (g/s)
    );
  my %hour_contamination_hash = ( # table that designates level of atmospheric contamination during typical day (1 - highest, peak hour contamination, 0 - no contamination)
       1 => 0.188,  2 => 0.116,  3 => 0.079,  4 => 0.068,  5 => 0.099,  6 => 0.243,
       7 => 0.619,  8 => 1,  9 => 0.975, 10 => 0.869, 11 => 0.824, 12 => 0.847,
      13 => 0.884, 14 => 0.940, 15 => 0.928, 16 => 0.871, 17 => 0.908, 18 => 0.918,
      19 => 0.988, 20 => 0.988, 21 => 0.936, 22 => 0.745, 23 => 0.540, 24 => 0.328,
    );
  my %hour_stability_hash = ( # table to emulate atmospheric stabiliti during dayly cycle (0 - stable to neutral, 1 - neutral to unstable, 2 - unstable due to higher surface temperature)
       1 => 0,  2 => 0,  3 => 0,  4 => 0,  5 => 0,  6 => 0,
       7 => 0.5,  8 => 0.5,  9 => 1, 10 => 2, 11 => 2, 12 => 2,
      13 => 2, 14 => 2, 15 => 2, 16 => 2, 17 => 2, 18 => 2,
      19 => 1, 20 => 1, 21 => 1, 22 => 0.5, 23 => 0, 24 => 0,
    );

## Look subprogramm "monin_obukhov" below to set method for estimation of Monin-Obukhov length (actually extremely rudimentary approach is used)

# =========== working code below this line ==============================================================
use Text::ParseWords;
use Time::localtime;

my $input = $ARGV[0];
my $output = $input.".series.dmna";
my ($header, $header1) = ();
my (@lines) = ();
my %elements = ();
my ($startdate, $enddate) = ();

open(DATAFILE, "<$input") || die "\nUnable to open file $input\n";
  @lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines; # we dont need header line currently

if (-e $output) { 
  die "\nSeems that output file $output already exists. Please remove or rename it.\n" 
}

my $first_line = 0;
my $line_counter = 0;

foreach my $item (@lines) {
  my @values = &parse_csv($item);
  if ( !(scalar @values >= 27) ) { next; } # skip to  if inthe next if input table line has less than 27 fields
  foreach (@values) { chomp; }
  
  # setting start date and end date
  if ( !defined $startdate )
  { 
    # set start date and initial end date
    $startdate = $values[0]; 
    $enddate = $startdate;
  }
  elsif (defined $startdate)
  {
    if (defined $enddate && 
      (
      substr($enddate,3,2) < substr($values[0],3,2) || 
      substr($enddate,0,2) < substr($values[0],0,2) ||
      substr($enddate,7,4) < substr($values[0],7,4)
      )
    ) 
    {
      # update end date
      $enddate = $values[0];
    }
  }

  if ( (scalar @values >= 27) && ($values[2] =~ /(WDR|WSP|TMP)/i) ) 
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
    $line_counter++;
  }
  else 
  {
    print "!";
  }
}

print "\n\n";

open(DATAFILE, ">$output") || die "\nUnable to open file $output\n"; 

my $contaminants_string = '';
my $contaminants_header = '';
my $size = 20;  # first 4 fields 
foreach my $contaminant (sort keys %contaminants_hash) { # making header format string (any problem in this line leads to unusable file)
  $contaminants_string .= $contaminant .' ';
  for (my $c=1; $c <=$segment_number ; $c++) {
    my $segment = sprintf "%02d", $c;
    $contaminants_header .= '"'.$segment.'.'.$contaminant.'%%10.3e" ';
    $size += 4;
  }
}

$line_counter = $line_counter  * 8; # considering that each line of inputfile represent one day, and in output file it is a hourly estimation byt we counted 3 times each day

# output file header
printf DATAFILE <<"OUT", localtime->mday(), localtime->mon()+1, localtime->year()+1900, localtime->hour(), localtime->min(), localtime->sec();
-- Period $startdate to $enddate
-- Anonymized data, date: %02d.%02d.%d %02d:%02d:%02d
-- Anemometer heights (0.1 m): 32 41 57 74 98 144 200 244 283
-- Contamination data for $segment_number zones
-- Contaminants: $contaminants_string
form  "te%%20lt" "ra%%5.0f" "ua%%5.1f" "lm%%7.1f" $contaminants_header
locl  "C"
mode  "text"
ha  3.2 4.1 5.7 7.4 9.8 14.4  20.0  24.4  28.3
sequ  "i"
dims  1
size  $size
lowb  1
hghb  $line_counter
*
OUT


  foreach my $ref_1 (sort {substr($a,3,2) <=> substr($b,3,2) || substr($a,0,2) <=> substr($b,0,2)} keys %$elements)
  {
    # day level
    foreach my $ref_2 (sort keys %{$elements->{$ref_1}})
    {
      # weather station level - not implemented to save in separate files
       for (my $i=0; $i < 24; $i++) 
       {
        my $wsp = $elements->{$ref_1}->{$ref_2}->{WSP}->{$i};  # wind speed in m/s
  my $wdr = $elements->{$ref_1}->{$ref_2}->{WDR}->{$i};  # wind direction in grados
  
  
  my $lm = &monin_obukhov($elements->{$ref_1}->{$ref_2}->{TMP}->{$i},$i+1,$wsp,$wdr);        # Monin-Obukhov length
        $ref_1 =~ m/(\d+)\/(\d+)\/(\d+)/i;                          # date
        printf DATAFILE "  %4.4d-%2.2d-%2.2d.%2.2d:00:00 ", $3, $2, $1, $i+1; # end of the hour
        printf DATAFILE "  %3.3d   %3.1f %7.1f ", $wdr, $wsp, $lm; # wind direction and speed
  foreach my $contaminant (sort keys %contaminants_hash) {
    for (my $c=1; $c <=$segment_number ; $c++) {
      printf DATAFILE "%10.3e ", &contamination($c,$2,$1,$i+1,$contaminant); # contamination values for each segment
    }
  }
        print DATAFILE "\n";
      }
    }
   print "+";
  }

printf DATAFILE "\n***";
# print $elements->{'01/01/2007'}->{'CEN'}->{'WDR'}->{'00'}; # test of first element

close(DATAFILE);

sub parse_csv {
  return quotewords(",",0, $_[0]);
}

{
our ($wsp_1, $wdr_1, $temp_1, $stability) = (); # variables appear out of sub

sub monin_obukhov {
  # Rude estimation of Monin-Obukhov length 
  # City of GDL
  ($temp_a, $hour_a, $wsp_a, $wdr_a) = @_;
  if (!defined $stability) { $stability = 0 }
  if (!defined $wsp_1) {$wsp_1 = $wsp_a}
  if (!defined $wdr_1) {$wdr_1 = $wdr_a}
  if (!defined $temp_1) {$temp_1 = $temp_a}
  my $l = 99999;
  my $hour_stability = $hour_stability_hash{$hour_a};
  my $wind_stability = 0;
  my $direction_stability = 0;
  my $temperature_stability = 0;
  if ( ($wsp_a - $wsp_1) > 5 || ($wsp_a > 10) ) { $wind_stability = 1; } elsif ( (($wsp_a - $wsp_1) < -5) || ($wsp_a < 0.25) ) { $wind_stability = -1; }
  if ( ((($wdr_a - $wdr_1) > 60) || (($wdr_a - $wdr_1) < -60)) && ($wsp_a > 5) ) { $direction_stability = 1; }
  if ( (($temp_a - $temp_1) >= 1) || ((temp_a - $temp_1) <= -1) ) { $temperature_stability = 1; }
  my $stability = ($stability + $hour_stability + $wind_stability + $direction_stability + $temperature_stability) / 2;
  if ($stability <= 0.5) {
  $l = 99999;
  } elsif ($stability > 0.5 && $stability <= 1) {
  $l = -196;
  } elsif ($stability > 1 && $stability <= 2) {
  $l = -83;
  } elsif ($stability > 2) {
  $l = -34;
  }
  $wsp_1 = $wsp_a;
  $wdr_1 = $wdr_a;
  $temp_1 = $temp_a;
  # $l = 99999; # substitute
  return $l;
}
}

sub contamination {
  my ($segment,$month,$day,$hour,$contaminant) = @_;

  # IMPORTANT: as wel it is necessary to include here holydays list to make modification of contamination
  my $contaminant_value = $contaminants_hash{$contaminant};
  $contamination = $contaminant_value * $hour_contamination_hash{$hour} * $segment_hash{$segment};
  return $contamination;
}
################################

