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
	$line =~ s/-/ /g;
	$line =~ s/Dr\.\s+//g;
        $line =~ s/,\s+&/ &/ig;
        $line =~ s/\.&\s+al(\.?)/. et al./ig;
        $line =~ s/(w+)etal((\.|,)?)/$1 et al./ig;
        $line =~ s/,"/"/ig;
	$line =~ s/&\set\sal\./et al./ig;


        $line =~ s/(\s|-)([A-Z]{1,1})([\.\-]?)(,?)(\s|$)/$1\u$2.$4 /ig;	
        $line =~ s/(\.|,|&)(\s*)\1/$1/g;

	$string =~ s/\b(de|del|la|lo|el|los|las)\b/\L$1/ig;

        $line =~ s/\s*de\s*Puga/ de Puga/ig;
        $line =~ s/\s*de\s*la\s*Rosa/ de la Rosa/ig;
        $line =~ s/Ram('|i)rez/Ramírez/ig;
        $line =~ s/\bCarbajal\b/Carvajal/ig;


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
