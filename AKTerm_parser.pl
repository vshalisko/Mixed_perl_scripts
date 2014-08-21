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



# =========== working code below this line ==============================================================
use Text::ParseWords;
use Time::localtime;

my $input = $ARGV[0];
my $output = $input.".stations.csv";
my ($header,$header1) = ();
my (@lines) = ();
my %elements = ();

open(DATAFILE, "<$input") || die "\nUnable to open file $input\n";
  @lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines; # we dont need header line currently

if (-e $output) { 
  die "\nSeems that output file $output already exists. Please remove or rename it.\n" 
}

my $first_line = 0;
my $line_counter = 0;
my $header1 = 0;

foreach my $item (@lines) {
  my @values = &parse_csv($item);
  if ( !(scalar @values >= 27) ) { next; } # skip to  if inthe next if input table line has less than 27 fields
  foreach (@values) { chomp; }
  if ( (scalar @values >= 27) && ($values[2] =~ /(CO|NO2|NOX|O3|PM10|SO2)/i) ) 
  {
    my $class = $1;
    $elements->{$values[0]}->{$values[1]}->{$class} = {  # date -> station -> measure -> time
           '0' => $values[3], '1' => $values[4],
           '2' => $values[5], '3' => $values[6],
           '4' => $values[7], '5' => $values[8],
           '6' => $values[9], '7' => $values[10],
           '8' => $values[11],'9' => $values[12],
           '10' => $values[13], '11' => $values[14],
           '12' => $values[15], '13' => $values[16],
           '14' => $values[17], '15' => $values[18],
           '16' => $values[19], '17' => $values[20],
           '18' => $values[21], '19' => $values[22],
           '20' => $values[23], '21' => $values[24],
           '22' => $values[25], '23' => $values[26],
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

  print DATAFILE 'fecha_entera, mes, hora, ';
    foreach my $ref_2 (sort keys %{$elements->{'01/01/2007'}}) 
    { 
      print DATAFILE $ref_2;
      print DATAFILE "_co, ";
      print DATAFILE $ref_2;
      print DATAFILE "_no2, ";
      print DATAFILE $ref_2;
      print DATAFILE "_nox, ";
      print DATAFILE $ref_2;
      print DATAFILE "_o3, ";
      print DATAFILE $ref_2;
      print DATAFILE "_so2, ";
      print DATAFILE $ref_2;
      print DATAFILE "_pm10, ";
    }
  print DATAFILE "\n";


  foreach my $ref_1 (sort {substr($a,3,2) <=> substr($b,3,2) || substr($a,0,2) <=> substr($b,0,2)} keys %$elements)
  {
    # day level
    for (my $i=0; $i < 24; $i++)
    {
      # hour level
      $ref_1 =~ m/(\d+)\/(\d+)\/(\d+)/i;                          # date
      printf DATAFILE "  %4.4d-%2.2d-%2.2d.%2.2d:00:00, ", $3, $2, $1, $i+1; # end of the hour
      printf DATAFILE "%2.2d, %2.2d, ", $2, $i+1;

      foreach my $ref_2 (sort keys %{$elements->{$ref_1}})
      {
      # weather station level

          
            my $co = $elements->{$ref_1}->{$ref_2}->{CO}->{$i};
            my $no2 = $elements->{$ref_1}->{$ref_2}->{NO2}->{$i};
            my $nox = $elements->{$ref_1}->{$ref_2}->{NOX}->{$i};
            my $o3 = $elements->{$ref_1}->{$ref_2}->{O3}->{$i};
            my $so2 = $elements->{$ref_1}->{$ref_2}->{SO2}->{$i};
            my $pm10 = $elements->{$ref_1}->{$ref_2}->{PM10}->{$i};
            my $register_string = $co.', '.$no2.', '.$nox.', '.$o3.', '.$so2.', '.$pm10.', ';

            print DATAFILE $register_string;
      }
      print DATAFILE "\n";
    }
   print "+";
  }

printf DATAFILE "\n***";

close(DATAFILE);

sub parse_csv {
  return quotewords(",",0, $_[0]);
}

################################

