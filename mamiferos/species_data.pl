#!/usr/local/bin/perl

## This program will process database with data in CSV formta to sort data from 
## second and third field of each coloumn and writing this to separate file
## resulting files should be located in /out directory. Be careful! If any file 
## already is in this directory programm will not worc correctly
##
## How to use: perl species_data.pl datafile
##
## Database format:
## First field in row - ID
## Second field - Genus
## Third field - Specie
## More fields - anything else
##
## Look documentation for more details
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


my $dir = 'E:\\out\\';


use Text::ParseWords;

my $infile = $ARGV[0] || "data.csv";
my ($header,$specie_previous,$outfile) = ();
my (@lines) = ();
my (%database,%species,%generos) = ();

chdir $dir || die "\nUnable open directory $dir\n";

open(DATAFILE, "<$infile") || die "\nUnable to open file $infile\n";
	@lines = <DATAFILE>;
close(DATAFILE);

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

chdir $dir."out\\" || die "\nUnable open directory $dir\\out\\\n";

foreach my $id (sort {$generos{$a} cmp $generos{$b}
									||
					  $species{$a} cmp $species{$b}
					  				||
					  $a <=> $b} 	keys %generos) {
	if ($specie_previous ne $species{$id}) {
		print "\nNew specie: $generos{$id} $species{$id} .$id";
		if (OUTFILE) { close(OUTFILE); }
		$outfile = $generos{$id}."_".$species{$id}.".csv";
		open(OUTFILE, ">$outfile") || die "\nUnable to open file $outfile\n";
		print OUTFILE "$header\n";
		print OUTFILE "$database{$id}";	
	} else {
		print ".$id";	
		print OUTFILE "$database{$id}";
	}
	$specie_previous = $species{$id};

}

if (OUTFILE) { close(OUTFILE); }
print "\n\nEnd of work. Database precessed.";

sub parse_csv {
	return quotewords(",",0, $_[0]);
}

sub clean_filename {
	my $s = $_[0];
	$s =~ s/ //g;
	$s =~ tr/a-zA-Z0-9/_/c;
	return $s;
}