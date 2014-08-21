#!/usr/local/bin/perl 
#
# This script convert sql output table to .csv formtat
# How to use: perl clean_sql_output.pl table.txt > table.csv
#


use locale;
use Text::ParseWords;

my $input = $ARGV[0];

open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	@input_lines = <DATAFILE>;
close(DATAFILE);

foreach my $line (@input_lines) {
	$line =~ s/\+?-+\+//g; 
	$line =~ s/^\|//g; 
	$line =~ s/\|$//g;
	if (&trim($line)) {
		my @values = &trim(&parse_table($line));
		&print_csv(@values);
	} 
}

sub parse_table {
	return quotewords('\|',0, $_[0]);
}                          


sub print_csv {
	my @out = @_;
	my $line_start = ();
	for my $item (@out) {
		$item = &trim($item);
		if ($item =~ /,/g) {
			$item =~ s/"/\\"/g;
			$item = '"'.$item.'"';
		}
		if ($line_start) {
			print ",$item";
		} else {
			print "$item"; 
			$line_start = 1;
		};		
	};
	print "\n";
}

sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}
