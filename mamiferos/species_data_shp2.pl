#!/usr/local/bin/perl

## This is not working version of script to work with shapefiles
## Created by Viacheslav Shalisko
## Modification 28.5.2005 - for work with SAGA GIS or ArcView GIS
## dbf format extension 28.6.2005
## shp format extension 16.1.2006
##
## This program will process database with data in CSV formta to sort data from 
## second and third field of each coloumn and writing this to separate file
## resulting files should be located in /out directory. Be careful! If any file 
## already is in this directory programm will not worc correctly
##
## How to use: perl species_data_shp.pl directory datafile
##
## Database format:
## First field in row - ID numeric field
## Second field - Genus text field
## Third field - Specie text field
## Latitude - Latitude numeric field
## Comments - Comments numeric field
## All fields behind comments are ignored
## 
##
## Copyright 2005, 2006 by Viacheslav Shalisko (vshalisko@gmail.com)
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


use Text::ParseWords;
use Geo::ShapeFile::Point;
use Geo::ShapeFile;
 

my $dir = $ARGV[0];
my $infile = $ARGV[1] || "data.txt";
my ($header,$specie_previous,$outfile) = ();
my (@lines,@header) = ();
my (%database,%species,%generos) = ();

chdir $dir || die "\nUnable open directory $dir\n";

open(DATAFILE, "<$infile") || die "\nUnable to open file $infile\n";
	@lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines;

foreach my $item (@lines) {
	my @values = &parse_csv($item);
	foreach (@values) { chomp; }
	my $i = $values[0];

#	@{$database{$i}} = @values;
	$database{$i} = $item;
	$generos{$i} = &clean_filename(ucfirst (lc $values[1]));
	$species{$i} = &clean_filename(lc $values[2]);
	print "$i: $generos{$i} $species{$i}\n";
}

chdir $dir."out\\" || die "\nUnable open directory $dir\\out\\\n";

foreach my $id (sort {$generos{$a} cmp $generos{$b}
									||
					  $species{$a} cmp $species{$b}
					  				||
					  $a <=> $b} 	keys %generos) {
	if ($specie_previous ne $species{$id}) {
		print "\nNew specie: $generos{$id} $species{$id} .$id";

		$outfile = $generos{$id}."_".$species{$id};
		&shp_create($outfile);
		&shp_point_output($outfile,$database{$id});	
	} else {
		print ".$id";	
		&shp_point_output($outfile,$database{$id});
	}
	$specie_previous = $species{$id};

}


print "\n\nEnd of work. Database precessed.";

sub parse_csv {
	return quotewords(",",0, $_[0]);
#	return quotewords("\t",0, $_[0]);
}


sub shp_create {
#   format of use: dbf_create("filename")
	$shp = new Geo::Shapefile($_[0]) or die Geo:Shapefile->errstr;

#	$dbf = XBase->create("name" => $_[0],
#                "field_names" => [  "IdReg", "Genero", "Especie", "Latitude", "Longitude", "Comment" ],
#                "field_types" => [ "N", "C", "C", "N", "N", "C" ],
#                "field_lengths" => [ 16, 20, 20, 16, 16, 20 ],
#                "field_decimals" => [ 8, undef, undef, 8, 8, undef ]) or die XBase->errstr;
#        $dbf->close();
}

sub shp_point_output {
#   format of use: dbf_line_output("filename","line")
#	$dbf = new XBase $_[0] or die XBase->errstr;


	my @row = &parse_csv($_[1]);
	my $point = new Geo::ShapeFile::Point(X => $row[4], Y => $row[3]);

#	my $i = $dbf->last_record + 1; 
#	$dbf->set_record($i, @row);

#	$dbf->set_record_hash($i, 
#		"IdReg" => $row[0], 
#		"Genero" => $row[1], 
#		"Especie" => $row[2], 
#		"Latitude" => $row[3], 
#		"Longitude" => $row[4], 
#		"Comment" => $row[5] 
#			) or die $dbf->errstr();

#        $dbf->undelete_record($i);
#	print $dbf->last_record." ".$row[0]." ";
#       $dbf->close();
}


sub clean_filename {
	my $s = $_[0];
	$s =~ s/ //g;
	$s =~ tr/a-zA-Z0-9/_/c;
	return $s;
}