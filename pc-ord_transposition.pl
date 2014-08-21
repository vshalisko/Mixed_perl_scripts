#!/usr/local/bin/perl 
#
##---------------------------------------------------------------------------##
##  Author:
##      Viacheslav Shalisko       vshalisko@gmail.com
##  Description:
##      Program to make transposition rows-columns in pc-ord file (csv format) 
##  Usage:
##      perl pc-ord_transposition.pl file.csv > file_transposed.csv
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


use locale;
use strict;
use Text::ParseWords;

my $sep = ";";    # separator in csv file

my (@column_titles,@row_titles,@matrix) = ();

my $input = $ARGV[0];

## Input

open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
  my @input_lines = <DATAFILE>;
close(DATAFILE);


my $first_line = &trim(shift @input_lines); 
my $second_line = &trim(shift @input_lines);
my $third_line = shift @input_lines;
my $data_type = "Q";

if ($third_line =~ /.*M.*/i) {$data_type = "M";} elsif ($third_line =~ /.*C.*/i){$data_type = "C"}

@column_titles = &trim(&parse_csv(shift @input_lines));
shift @column_titles;

for (my $i = 0; $i <= $#input_lines; $i++) 
{
  my @line_items = &parse_csv($input_lines[$i]);
  $row_titles[$i] = &trim(shift @line_items);
  for (my $j = 0; $j <= $#line_items; $j++)
  {
    $matrix[$j][$i] = &trim($line_items[$j]);
  }   
}

## Output

print "$second_line\n";
print "$first_line\n";

for (my $i = 0; $i <= $#row_titles; $i++)
{
  print $sep;
  print $data_type;
}

print "\n";
for (my $i = 0; $i <= $#row_titles; $i++)
{
  print $sep;
  print $row_titles[$i];
}


for (my $i = 0; $i <= $#column_titles; $i++) 
{
  print "\n";
  print $column_titles[$i];
  for (my $j = 0; $j <= $#row_titles; $j++)
  {                               
    print $sep;
    print $matrix[$i][$j];
  }   
}


## Subs

sub parse_csv {
  return quotewords($sep,0, $_[0]);
}

sub trim {
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  };
  return wantarray ? @out : $out[0];
}
