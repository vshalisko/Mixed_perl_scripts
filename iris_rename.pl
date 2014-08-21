#!/usr/local/bin/perl 
#
##---------------------------------------------------------------------------##
##  Author:
##      VSh
##  Description: 
##      
##      direcory out should be created as a subdir of input directory
##  Date:
##      03.2009
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

use File::Copy;

my $dir = $ARGV[0];
my $out_dir = $ARGV[1];
   
chdir $dir || die "\nCan`t open input directory $dir\n";

my @files_of_onterest = ();
my $copy_couter = 0;

while (<*.*>) {
    my $file = $_;
    my $new_file_location = $out_dir."\\".$file;
    if ( $file =~ /(.+)(\.iris|\.irx|\.prj|\.dbf)(\d*)$/i )
    {
      # some object of interest
      push (@files_of_onterest, $file);
      print ".";
      my $c = copy($file,$new_file_location) or warn "\nCopy of $old_file_location failed: $!\n";
      if ($c) 
      {
        $copy_counter += 1;
      }
    }
}

print "\n$copy_counter files were copied from $dir to $out_dir\n";
chdir $out_dir || die "\nCan`t open output directory $out_dir\n";

foreach my $file_to_rename (@files_of_onterest) {
   $file_to_rename =~ /(.+)(\.iris|\.irx|\.prj|\.dbf)(\d*)$/i;
   $new_name = $1 . '__' . $3 . $2;
   print "Renaming $file_to_rename to $new_name\n";
   rename ($file_to_rename, $new_name) or warn "Couldn't rename $file_to_rename to $new_name!\n";
}
