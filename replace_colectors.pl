#!/usr/local/bin/perl 
#
# This script replaces elements in text file
# How to use: perl replace.pl input_file > output_file
#


use locale;
use Text::ParseWords;

my $input = $ARGV[0];

open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	@input_lines = <DATAFILE>;
close(DATAFILE);

foreach my $line (@input_lines) {

####==Regexp to search and replace===========================================

	$line =~ s/(.*)/ $1 /g;
        $line =~ s/(\s)(and|et|y)(\s)/$1&$3/ig;
        $line =~ s/(\.)(and|et|y)(\s)/$1&$3/ig;
        $line =~ s/;/,/g;
        $line =~ s/(\s|-)([A-Z]{1,1})([\.\-]?)(,?)(\s|$)/$1\u$2.$4 /ig;	
        $line =~ s/([A-Zбуйнъс]{5,})(\.)/$1/ig;
        $line =~ s/\.(\w)/. $1/g;
        $line =~ s/\.(\s)(\s)/.$2/g;
        $line =~ s/(\.?)(\s),/$1,/g;
        $line =~ s/(\.|,|&)(\s*)\1/$1/g;
        $line =~ s/,*\s+(&|et)\s*al\.?/ et al./ig;

####=========================================================================

	$line = &trim($line);
	print $line."\n";
}


sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}
