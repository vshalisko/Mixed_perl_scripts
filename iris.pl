	#!/usr/local/bin/perl 
#
##---------------------------------------------------------------------------##
##  Author:
##      VSh
##  Description: Script to convert INEGI IRIS vectorial data to ERSI SHP format
##      Takes directiry with IRIS files as input; it rewrites any present SHP 
##      file in case of name conflicts, so be careful
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


#use XBase;        # DBF access
use File::stat;   # file parameters interface   

my $verbose_level = $ARGV[0]; # should be numeric value from 0 to 3 reflecting level of scren output

my $dir = $ARGV[1];
   
chdir $dir || die "\nCan`t open directory $dir\n";

while (<*.irx>) { # actually fist we look for index files IRX, only this entries are processed
    my $irx_file_name = $_;
    my $file_name_base = $irx_file_name;
    $file_name_base =~ s/\.irx$//i;
    my $iris_file_name = $file_name_base.".iris";
    my $dbf_file_name = $file_name_base.".dbf";
    my $shp_file_name = $file_name_base.".shp";
    my $shx_file_name = $file_name_base.".shx";

    my $irx_file_stat = stat($irx_file_name);
    my $irx_size = $irx_file_stat->size;
    
    if ($verbose_level >= 1) {
      print "IRX of layer '$file_name_base' has $irx_size bytes\n";
    }

    # IRX header structure is the same as for IRIS files: 
    # [0] N - vector type (1 - piont, 5 - polygon)
    # [1] N - 3000
    # [2-5] - coordinates of 'box' in doble float (d)
    # [6] N - 1
    # [7-14] - 0
    my $irxheader = &segment_read(0,75,76,$irx_file_name,"N N d d d d N N N N N N N N N"); # read of IRX header 
    my $irxrecords = &segment_read(76,$irx_size,8,$irx_file_name,"N N"); # body with pairs of values: element number - element address

    &segment_dump($irxheader,"IRX header",$verbose_level);
    &segment_dump($irxrecords,"IRX body",$verbose_level);

    if (-e $iris_file_name) 
    {
      # read IRIS main file
      my $iris_file_stat = stat($iris_file_name);
      my $iris_size = $iris_file_stat->size;

      if ($verbose_level >= 1) {
        print "IRIS of layer '$file_name_base' has $iris_size bytes\n";
      }

      my $irisheader = &segment_read(0,75,76,$iris_file_name,"N N d d d d N N N N N N N N N"); # read of IRIS header 
      
      &segment_dump($irisheader,"IRIS header");

      if ($$irisheader[0][0] == 1) # point feature
      {
        print "IRIS of layer '$file_name_base' contains point features\n";

        my $shape_type = 1;
        my $body_size = 50; # header size is 100 bytes or 50 16-bit words
        my $record_count = 0;
        my $body_content = "";
        my $index_content = "";

        foreach my $point_record ( @$irxrecords )
        {
          my ($point_id,$point_address) = ($$point_record[0],$$point_record[1]);
          my $point_data = &segment_read(2*$point_address,2*$point_address+16,16,$iris_file_name,"d d");
          if ($verbose_level >= 2) {
            print "point $point_id: x = $$point_data[0][0], y = $$point_data[0][1]\n";
          }
          $body_content .= pack("N N I d d", $point_id, 10, 1, $$point_data[0][0], $$point_data[0][1]);
          $index_content .= pack("N N", $body_size, 10); # $body_size is used as offset
          $body_size += 14; # record size with record header is 28 bytes or 14 16-bit words
          $record_count += 1;
        }

        print "generating SHP with $record_count records\n";

        my $shp_header = &vector_header($body_size,$shape_type,$irisheader);
        my $shx_header = &vector_header(50+4*$record_count,$shape_type,$irisheader);

        open(SHP,">$shp_file_name") or warn "unable to open $shp_file_name for write";
        binmode(SHP);
        print SHP $shp_header;
        print SHP $body_content;
        print "SHP $shp_file_name has been written\n";
        close(SHP); 

        open(SHX,">$shx_file_name") or warn "unable to open $shx_file_name for write";
        binmode(SHX);
        print SHX $shx_header;
        print SHX $index_content;
        print "SHX $shx_file_name has been written\n";
        close(SHX); 


      }
      elsif ($$irisheader[0][0] == 5) # polygon feature
      {
        print "IRIS of layer '$file_name_base' contains polygon features\n";

        my $shape_type = 5;
        my $body_size = 50; # header size is 100 bytes or 50 16-bit words
        my $record_count = 0;
        my $body_content = "";
        my $index_content = "";

        foreach my $polygon_record ( @$irxrecords )
        {
          my ($polygon_id,$polygon_address) = ($$polygon_record[0],$$polygon_record[1]);


          # polygon record header structure in IRIS file (36 bytes + 8 bytes)
          # [0-3] coordinates of 'box' in doble float (d)
          # [4] N - possibly iti is a ring number
          # [5] N - polygon nodes number
          # [6] N - 0 possibly first ring address
          my $polygon_record_header = &segment_read(2*$polygon_address,2*$polygon_address+40,40,$iris_file_name,"d d d d I I");
          my $polygon_record_rings = &segment_read(2*$polygon_address+40,2*$polygon_address+40+4*$$polygon_record_header[0][4]-1,4,$iris_file_name,"I");

          my $polygon_data_start_address = 2*$polygon_address+40+4*$$polygon_record_header[0][4];
          my $polygon_data_end_address = 2*$polygon_address+40+4*$$polygon_record_header[0][4]+16*$$polygon_record_header[0][5]-1;

          if ($verbose_level >= 1) {
            print "header of polygon $polygon_id include: box ($$polygon_record_header[0][0],$$polygon_record_header[0][1],$$polygon_record_header[0][2],$$polygon_record_header[0][3]) ";
            print "total of $$polygon_record_header[0][5] nodes and $$polygon_record_header[0][4] rings\n";
            print "node sequence from $polygon_data_start_address to $polygon_data_end_address\n";
          }

          my $polygon_record_data = &segment_read($polygon_data_start_address,$polygon_data_end_address,16,$iris_file_name,"d d");
          &segment_dump($polygon_record_data,"polygon $polygon_id data: ",$verbose_level);
          &segment_dump($polygon_record_rings,"polygon ring $polygon_id references: ",$verbose_level);

          # SHP polygon consist of points and rings Number of points and rings is included in polygon header 
          # then apperas index of rings (sequence of addresseses of first point of each ring, then sequence of points
          # to calculate polygon record size it is necessary to know how much points and polygons it contains
          my $record_size = 22+2*$$polygon_record_header[0][4]+8*$$polygon_record_header[0][5];
          $body_content .= pack("N N I d d d d I I",$polygon_id,$record_size,5,$$polygon_record_header[0][0],$$polygon_record_header[0][1],$$polygon_record_header[0][2],$$polygon_record_header[0][3],$$polygon_record_header[0][4],$$polygon_record_header[0][5]);
          $index_content .= pack("N N", $body_size, $record_size); # $body_size is used as offset
          $body_size += 26; # record header is 8 bytes or 4 16-bit words y polygon record header is 44 bytes or 22 16-bit words
          foreach my $ring_reference (@$polygon_record_rings) 
          {
            $body_content .= pack("I",$$ring_reference[0]);
            $body_size += 2; # each ring reference is 4 bytes or 2 16-bit words
          }
          foreach my $point_reference (@$polygon_record_data) 
          {
            $body_content .= pack("d d",$$point_reference[0],$$point_reference[1]);
            $body_size += 8; # each node is 16 bytes or 8 16-bit words
          }
          $record_count += 1;
        }

        my $shp_header = &vector_header($body_size,$shape_type,$irisheader);
        my $shx_header = &vector_header(50+4*$record_count,$shape_type,$irisheader);


        open(SHP,">$shp_file_name") or warn "unable to open $shp_file_name for write";
        binmode(SHP);
        print SHP $shp_header;
        print SHP $body_content;
        print "SHP $shp_file_name has been written\n";
        close(SHP); 

        open(SHX,">$shx_file_name") or warn "unable to open $shx_file_name for write";
        binmode(SHX);
        print SHX $shx_header;
        print SHX $index_content;
        print "SHX $shx_file_name has been written\n";
        close(SHX); 

      }
      elsif ($$irisheader[0][0] == 3) # polyline feature
      {
        print "IRIS of layer '$file_name_base' contains polyline features\n";

        my $shape_type = 3;
        my $body_size = 50; # header size is 100 bytes or 50 16-bit words
        my $record_count = 0;
        my $body_content = "";
        my $index_content = "";

        foreach my $polyline_record ( @$irxrecords )
        {
          my ($polyline_id,$polyline_address) = ($$polyline_record[0],$$polyline_record[1]);


          # polyline record header structure in IRIS file (36 bytes + 8 bytes)
          # [0-3] coordinates of 'box' in doble float (d)
          # [4] N - possibly iti is a part number
          # [5] N - polyline nodes number
          # [6] N - 0 possibly first part address
          my $polyline_record_header = &segment_read(2*$polyline_address,2*$polyline_address+40,40,$iris_file_name,"d d d d I I");
          my $polyline_record_parts = &segment_read(2*$polyline_address+40,2*$polyline_address+40+4*$$polyline_record_header[0][4]-1,4,$iris_file_name,"I");

          my $polyline_data_start_address = 2*$polyline_address+40+4*$$polyline_record_header[0][4];
          my $polyline_data_end_address = 2*$polyline_address+40+4*$$polyline_record_header[0][4]+16*$$polyline_record_header[0][5]-1;

          if ($verbose_level >= 1) {
            print "header of polyline $polyline_id include: box ($$polyline_record_header[0][0],$$polyline_record_header[0][1],$$polyline_record_header[0][2],$$polyline_record_header[0][3]) ";
            print "total of $$polyline_record_header[0][5] nodes and $$polyline_record_header[0][4] parts\n";
            print "node sequence from $polyline_data_start_address to $polyline_data_end_address\n";
          }

          my $polyline_record_data = &segment_read($polyline_data_start_address,$polyline_data_end_address,16,$iris_file_name,"d d");
          &segment_dump($polyline_record_data,"polyline $polyline_id data: ",$verbose_level);
          &segment_dump($polyline_record_parts,"polyline part $polyline_id references: ",$verbose_level);

          # SHP polyline consist of points and parts (similar to parts ofo polygons) Number of points and parts is included in polyline header 
          # then apperas index of parts (sequence of addresseses of first point of each part, then sequence of points
          # to calculate polyline record size it is necessary to know how much points and polylines it contains
          my $record_size = 22+2*$$polyline_record_header[0][4]+8*$$polyline_record_header[0][5];
          $body_content .= pack("N N I d d d d I I",$polyline_id,$record_size,5,$$polyline_record_header[0][0],$$polyline_record_header[0][1],$$polyline_record_header[0][2],$$polyline_record_header[0][3],$$polyline_record_header[0][4],$$polyline_record_header[0][5]);
          $index_content .= pack("N N", $body_size, $record_size); # $body_size is used as offset
          $body_size += 26; # record header is 8 bytes or 4 16-bit words y polyline record header is 44 bytes or 22 16-bit words
          foreach my $part_reference (@$polyline_record_parts) 
          {
            $body_content .= pack("I",$$part_reference[0]);
            $body_size += 2; # each part reference is 4 bytes or 2 16-bit words
          }
          foreach my $point_reference (@$polyline_record_data) 
          {
            $body_content .= pack("d d",$$point_reference[0],$$point_reference[1]);
            $body_size += 8; # each node is 16 bytes or 8 16-bit words
          }
          $record_count += 1;
        }

        my $shp_header = &vector_header($body_size,$shape_type,$irisheader);
        my $shx_header = &vector_header(50+4*$record_count,$shape_type,$irisheader);


        open(SHP,">$shp_file_name") or warn "unable to open $shp_file_name for write";
        binmode(SHP);
        print SHP $shp_header;
        print SHP $body_content;
        print "SHP $shp_file_name has been written\n";
        close(SHP); 

        open(SHX,">$shx_file_name") or warn "unable to open $shx_file_name for write";
        binmode(SHX);
        print SHX $shx_header;
        print SHX $index_content;
        print "SHX $shx_file_name has been written\n";
        close(SHX); 

      }
      else
      {
        print "\nIRIS of layer '$file_name_base' is of unknown type\n";
      }

    }
    else
    {
      warn "\nIRIS of layer '$file_name_base' was not found\n";
    }
}




sub vector_header {
  # form 100 bytes SHP o SHX header
  my ($vector_size,$vector_type,$irisheaderref) = @_;
  my $header = pack("N N N N N N N I I d d d d d d d d",9994,0,0,0,0,0,$vector_size,1000,$vector_type,$$irisheaderref[0][2],$$irisheaderref[0][3],$$irisheaderref[0][4],$$irisheaderref[0][5],0,0,0,0);
  return $header;
}

sub segment_read {
    # read some fragment of binary file as a sequence of records between start address and end address (in bytes)
    my ($startaddress, $endaddress, $recordsize, $file, $record_template) = @_;
    my @records = ();
    open(INPUT, $file);
    binmode(INPUT);
    seek(INPUT, $startaddress, 0) or warn "unable to seek address $startaddress in $file:$!\n";
    my $address = $startaddress;
    until ( ($address > $endaddress) or eof(INPUT) )
    {
      read(INPUT, my $record, $recordsize) == $recordsize 
      or warn "short read in $file while reading $recordsize bytes records on address $address\n";
      my @fields = unpack($record_template, $record);
      push (@records, \@fields );
      $address += $recordsize;
    }
    if ($address < $endaddress) 
    { 
      warn "read in file $file finished prematurely on adderss $address (instead of $endaddress) possibly due to EOF\n"; 
    }
    close(INPUT);
    return \@records;
}

sub segment_dump {
    # debug feature works on verbose level 2 or more
    my ($record_reference, $segment_title, $verbose_level) = @_;
    if ($verbose_level >= 2) {
      print "----$segment_title---\n";
      foreach my $test_value (@$record_reference)
      {
        foreach my $test_value2 (@$test_value) 
        {
          print "$test_value2 ";
        }
        print ":";
      }
      print "\n";
    } 
}


sub trim {
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  };
  return wantarray ? @out : $out[0];
}
