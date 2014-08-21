#!/usr/local/bin/perl 
#
##---------------------------------------------------------------------------##
##  Author:
##      Viacheslav Shalisko       vshalisko@gmail.com
##  Description: Script to merge dbf files with ArcGIS zonal statistics data
##               Takes directiry with dbf files as input and output list of values in csv format (in standard output)
##     
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


use XBase;
   
my $dir = $ARGV[0];
   
   
chdir $dir || die "\nCan`t open directory $dir\n";


while (<*.dbf>) {
    $file = $_;

    my $database = new Xbase;
    $database->open_dbf($file, undef);
    
    my $end=$database->lastrec;
    my $current_rec = 1;

    while ($current_rec < $end) 
    {
      $current_rec = $database->recno;
      print "linea $current_rec de $end, ";
      print "$file, ";
      print &trim($database->get_field("ROUTE_NAME"));
      print ", ";
      print $database->get_field("COUNT");
      print ", ";
      print $database->get_field("AREA");
      print ", ";
      print $database->get_field("MIN");
      print ", ";
      print $database->get_field("MAX");
      print ", ";
      print $database->get_field("RANGE");
      print ", ";
      print $database->get_field("MEAN");
      print ", ";
      print $database->get_field("STD");
      print ", ";
      print $database->get_field("SUM");
      print "\n";
      $database->go_next;

    }
    $database->close_dbf;
}



sub trim {
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  };
  return wantarray ? @out : $out[0];
}
