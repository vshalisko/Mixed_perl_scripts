#!/usr/local/bin/perl

## This script was designed to convert coma separated 
## text table to independent files and to convert them into ERSI shapefiles
## 
## It requires gen2shp.exe program installed in directory $basedir and works 
## with data files located there
##
## Created by Viacheslav Shalisko
## Modification 28.5.2005 - for work with SAGA GIS or ArcView GIS
## 
## shp format extension 6.2.2006 - convert data to ERSI shp format
##
## This program will process database with data in CSV formta to sort data from 
## second and third field of each coloumn and writing this to separate file
## resulting files should be located in \out directory. Be careful! If any file 
## already is in this directory programm will not worc correctly
##
## How to use: perl species_data_shp1.pl datafile
##
## Database format:
## First field in row - ID numeric field
## Second field - Genus text field
## Third field - Specie text field
## Forth field - Latitude numeric field
## Fith field - Longitude numeric field
## Optional text field "Origen"
## Optional text field "Municipio"
## 
## All fields behind comments are ignored
## 
##
## Look documentation for more details.
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


$programdir = 'E:\\Perl\\script\\mamiferos\\';
$basedir = 'E:\\out\\';

#=============================================================================




use Text::ParseWords;
use XBase;
use File::Copy;


my $dir = $basedir;
my $infile = $ARGV[0] || "data.csv";


$program = 'gen2shp.exe';
$type = 'points <';

$program_full = $basedir.$program;


my ($header,$specie_previous,$outfile) = ();
my (@lines) = ();
my (%database,%species,%generos) = ();

#=============================================================================

chdir $dir || die "\nUnable open directory $dir\n";

open(DATAFILE, "<$infile") || die "\nUnable to open file $infile\n";
	@lines = <DATAFILE>;
close(DATAFILE);

#=============================================================================

$header = shift @lines;

foreach my $item (@lines) {
	my @values = &parse_csv($item);
	foreach (@values) { chomp; }
	my $i = shift @values;
#	@{$database{$i}} = @values;
	$database{$i} = $item;
	$generos{$i} = &clean_filename(ucfirst (lc (shift (@values))));
	$species{$i} = &clean_filename(lc shift @values);
	print "$i: $generos{$i} $species{$i}\n";
}

#=============================================================================
print "\nMoving to $basedir";
chdir $basedir || die "\nUnable open directory $basedir\n";
#chdir $dir."out\\" || die "\nUnable open directory $dir\\out\\\n";

foreach my $id (sort {$generos{$a} cmp $generos{$b}
									||
					  $species{$a} cmp $species{$b}
					  				||
					  $a <=> $b} 	keys %generos) {
	if ($specie_previous ne $species{$id}) {
		print "\nNew specie: $generos{$id} $species{$id} .$id";
		if (OUTFILE) { 
			print OUTFILE "end";
			close(OUTFILE); 
		}
		if (OUTFILE1) { 
			close(OUTFILE1); 
		}
		$outfile = $generos{$id}."_".$species{$id}.".csv";
		$outfile1 = $generos{$id}."_".$species{$id}.".txt";		
		open(OUTFILE, ">$outfile") || die "\nUnable to open file $outfile\n";
		open(OUTFILE1, ">$outfile1") || die "\nUnable to open file $outfile1\n";
		my @fields = &parse_csv($database{$id});
		print OUTFILE "$fields[0],$fields[4],$fields[3]\n";	
		print OUTFILE1 "$fields[0],$fields[1],$fields[2],$fields[3],$fields[4],$fields[5],$fields[6]\n";	

	} else {
		print ".$id";	
		my @fields = &parse_csv($database{$id});
		print OUTFILE "$fields[0],$fields[4],$fields[3]\n";
		print OUTFILE1 "$fields[0],$fields[1],$fields[2],$fields[3],$fields[4],$fields[5],$fields[6]\n";		
	}
	$specie_previous = $species{$id};

}

if (OUTFILE) { close(OUTFILE); }
if (OUTFILE1) { close(OUTFILE1); }

print "\n\nEnd of .csv & .txt writing. Database processed. \nStart of .csv to .shp converting.";

#=============================================================================
print "\nCoping of gen2shp components to $basedir";
	my $gen2shp_file = $programdir."gen2shp.exe";
	my $gen2shp_file_new = $basedir."gen2shp.exe";
	my $shapelib_file = $programdir."shapelib.dll";
	my $shapelib_file_new = $basedir."shapelib.dll";
	copy($gen2shp_file,$gen2shp_file_new);
	copy($shapelib_file,$shapelib_file_new);

print "\nMoving to $basedir";
chdir $basedir || die "\nUnable open directory $basedir\n";
#chdir $dir."out\\" || die "\nUnable open directory $dir\\out\\\n";

while(<*.csv>) {
     $filename = $_;
     $csvfile = $filename;
     $filename =~ s/\.csv$//i;
     $shapefile = $filename;
     $csvfullfile = $filename.".txt";


     print "\nConverting of $filename to .shp";

# Use of gen2shp	
     eval{$status = system("$program_full $shapefile $type $csvfile");};
     die "Extenal component $program exited not normally: $?" unless $status == 0;

     print "\nNow correcting $filename .dbf file";

     open(DATAFILE, "<$csvfullfile") || die "\nUnable to open file $csvfullfile\n";
	my $dbffile = $shapefile.".dbf";
	my $olddbffile = $shapefile.".dbf.bak";
# Rename .dbf file created by gen2shp.exe to .dbf.bak
	rename($dbffile, $olddbffile) or warn "Couldn't rename $dbffile to $olddbffile: $!\n";
	&dbf_create($dbffile);
     	while (<DATAFILE>) {
		my @csv = &parse_csv($_);
		&dbf_line_output($dbffile,$csv[0],$csv[4],$csv[3],$csv[1],$csv[2],$csv[5],$csv[6]);		
     	}
     close(DATAFILE);
};


print "\nMoving to $basedir";
chdir $basedir || die "\nUnable open directory $basedir\n";
print "\nDeleting of temporal gen2shp components in $basedir";

unlink("gen2shp.exe") or warn "\nCan't unlink file $gen2shp_file_new: $!\n";
unlink("shapelib.dll") or warn "\nCan't unlink file $shapelib_file_new: $!\n";

print "\n\nEnd of work.";

#=============================================================================

sub parse_csv {
	return quotewords(",",0, $_[0]);
}

sub clean_filename {
	my $s = $_[0];
	$s =~ s/ //g;
	$s =~ tr/a-zA-Z0-9/_/c;
	return $s;
}

sub dbf_create {
#   format of use: dbf_create("filename")
	my $first_column = substr($_[0],0,10);
	$dbf = XBase->create("name" => $_[0],
                "field_names" => [  $first_column, "Longitude", "Latitude", "Genero", "Especie", "Origen", "Municipio"  ],
                "field_types" => [ "N", "N", "N", "C", "C", "C", "C" ],
                "field_lengths" => [ 16, 16, 16, 20, 20, 20, 20 ],
                "field_decimals" => [ 8, 8, 8, undef, undef, undef, undef ]) or die XBase->errstr;
        $dbf->close();
}

sub dbf_line_output {
#   format of use: dbf_line_output("filename","arg1","arg2","arg3","arg4","arg5","arg6","arg7","arg8")
	$dbf = new XBase $_[0] or die XBase->errstr;
	my $i = $dbf->last_record + 1; 
	$dbf->set_record($i,$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7]);
        $dbf->undelete_record($i);
        $dbf->close();
}




