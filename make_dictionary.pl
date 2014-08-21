#!/usr/local/bin/perl 
#
# This script replaces elements in text file
# How to use: perl replace.pl input_file > output_file
#


use locale;
use Text::ParseWords;

%words = ();
my $id = 0;

my $input = $ARGV[0];


open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	@input_lines = <DATAFILE>;
close(DATAFILE);

foreach my $line (@input_lines) {

	my @chunks = split(/,|&/m,$line);
	foreach my $chunk (@chunks) {
		$id++; 
		$chunk =~ /(^|-|"|\s)+([A-Zбуйнъс]{3,})((\s|-|"|\.)+|$)/i;
		$main_word = $2;
		$chunk =~ s/^(\s|")*(.*?)(\s|")*$/$2/;
		$line =~ s/\s$//;
		$word = { 
			ID => $id,
			MAIN_WORD => $main_word,
			FULL_STRING => $chunk,
			COMPLETE_LINE => $line,
		};
		$words{ $word->{ID} } = $word;
	};


}


foreach $rp (sort { $a->{MAIN_WORD} cmp $b->{MAIN_WORD} || 
		$a->{FULL_STRING} cmp $b->{FULL_STRING} } values %words) {
		if ($full_string_old ne $rp->{FULL_STRING}) {
			print $rp->{ID}."|";
			print $rp->{MAIN_WORD}."|";
			print $rp->{FULL_STRING}."|";
			print $rp->{COMPLETE_LINE}."\n";
			$full_string_old = $rp->{FULL_STRING};
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
