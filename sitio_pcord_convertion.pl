#!/usr/local/bin/perl

## Created 9.2005 by Viacheslav Shalisko for PC-ORD application data processing
## Writing of Compact data format List of Individual Trees
## Initial data should be field data from 10 samples in .csv format
## How to use: perl sitio_pcord_convertion.pl datafile.csv
##
## Exaple of input data:
## ---------------------
## Sitio 1 Bosque de Quercus y Pinus 1800 msnm,,,,,,,
## No.,Especies,Perimetro cm,Diam cm,Area basal de rama dm2,Area basal de arbol dm2,,
## S1C2,,,,,,,
## 25,Pinus oocarpa,,18,2.545,2.545,,
## 4,Quercus resinosa,,7,0.385,0.385,,
## 4,Quercus resinosa,,6.4,0.322,0.322,,
## 4,Quercus resinosa,,7.4,0.430,0.430,,
## 4,Quercus resinosa,,17.6,2.433,2.433,,
## 
## ---------------------
## Exaple of output data:
## ---------------------
## S1C2
## 25 2.545 4 0.385 4 0.322 4 0.430 4 2.433 /
## S1C3
## 4 0.053 25 0.196 25 0.679 25 0.126 25 0.264 25 0.080 /
## ...
## ---------------------




use Text::ParseWords;

my $input = $ARGV[0];
my $output = $input."AB.data.txt";
my ($header, $header1) = ();
my (@lines) = ();


open(DATAFILE, "<$input") || die "\nUnable to open file $input\n";
	@lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines;
$header1 = shift @lines;

if (-e $output) { 
	die "\nFile $output already exists.\nRemove it.\n" 
}

open(DATAFILE, ">$output") || die "\nUnable to open file $output\n"; 
foreach my $item (@lines) {
	my @values = &parse_csv($item);
	foreach (@values) { chomp; }
	if ( $values[0] =~ /S\dC\d/i ) {
		print DATAFILE "/\n$values[0]\n";
	} elsif ( ($values[0] =~ /\d+/) && ($values[5] =~ /\d+.?\d*/) ) {
		print DATAFILE "$values[0] $values[5] ";
	};
}
close(DATAFILE);

sub parse_csv {
	return quotewords(",",0, $_[0]);
}


################################

