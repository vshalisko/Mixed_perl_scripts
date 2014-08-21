#!/usr/local/bin/perl

## Created 9.2005 by Viacheslav Shalisko for PC-ORD application data processing
## Writing of Compact data format Presence List of Species
## Initial data should be field data from 10 samples in .csv format
## How to use: perl sitio_pcord_presence.pl datafile.csv
##
## Exaple of input data:
## ---------------------
## No.,Especies,S1C2,S1C3,S1C5,S1C6,S1C9,S1C10,S1C11,S1C13,S1C16,S1C17,Total
## 1,Stevia ovata,,,,,,,,,1,,1
## 2,Agrostis sp. 1 (panicula abierta),,,1,,,,,1,1,1,4
## 3,Quercus planipocula,,,,,,,,,,1,1
## ...
## ---------------------
## Exaple of output data:
## ---------------------
## S1C2
## 4 9 13 14 23 25 29 31 36  /
## S1C3
## 4 10 13 14 22 25 30 34 40 41  /
## ...
## ---------------------


use Text::ParseWords;

my $input = $ARGV[0];
my $output = $input."presence.data.txt";
my ($header, $header1) = ();
my (@lines, @names) = ();


open(DATAFILE, "<$input") || die "\nUnable to open file $input\n";
	@lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines;
#$header1 = shift @lines;

@names = &parse_csv($header);
foreach (@names) { 
	chomp;
	$_ .= "\n"; 
}

foreach my $item (@lines) {
	my @values = &parse_csv($item);
	foreach (@values) { chomp; }
	if ( $values[2] =~ /\d/ ) {
		$names[2] .= $values[0]." ";
	}; 
	if ( $values[3] =~ /\d/ ) {
		$names[3] .= $values[0]." ";
	}; 
	if ( $values[4] =~ /\d/ ) {
		$names[4] .= $values[0]." ";
	};
	if ( $values[5] =~ /\d/ ) {
		$names[5] .= $values[0]." ";
	};
	if ( $values[6] =~ /\d/ ) {
		$names[6] .= $values[0]." ";
	};
	if ( $values[7] =~ /\d/ ) {
		$names[7] .= $values[0]." ";
	};
	if ( $values[8] =~ /\d/ ) {
		$names[8] .= $values[0]." ";
	};
	if ( $values[9] =~ /\d/ ) {
		$names[9] .= $values[0]." ";
	};
	if ( $values[10] =~ /\d/ ) {
		$names[10] .= $values[0]." ";
	}; 
	if ( $values[11] =~ /\d/ ) {
		$names[11] .= $values[0]." ";
	};
}


if (-e $output) { 
	die "\nFile $output already exists.\nRemove it.\n" 
}


open(DATAFILE, ">$output") || die "\nUnable to open file $output\n";
	shift @names;
	shift @names;
	foreach my $item (@names) {
		print DATAFILE "$item/\n";
	};
close(DATAFILE);

sub parse_csv {
	return quotewords(",",0, $_[0]);
}


################################

