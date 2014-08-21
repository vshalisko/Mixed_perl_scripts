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

	$line =~ s/"//g;

	my @chunks = split(/(\b(et|ex|in){1,1}\b)|[,:\)]{1,1}/gi,$line);
	foreach my $chunk (@chunks) {
		$id++; 
		$chunk =~ s/\(|\)//g;
		$chunk =~ s/^(\s|")*(.*?)(\s|")*$/$2/;
		$chunk =~ s/et//g;
		if ($chunk) {
			$line =~ s/\s$//g;
			$word = { 
				ID => $id,
				FULL_STRING => $chunk,
				COMPLETE_LINE => $line,
			};
			$words{ $word->{ID} } = $word;
		};
	};


}


foreach $rp (sort { $a->{COMPLETE_LINE} cmp $b->{COMPLETE_LINE} || 
		$a->{FULL_STRING} cmp $b->{FULL_STRING} } values %words) {
		if ($full_string_old ne $rp->{FULL_STRING}) {
			print $rp->{ID}."|";
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
