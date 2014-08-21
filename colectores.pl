#!/usr/local/bin/perl 
# Script to generate column of corrected colectors

use locale;
use Text::ParseWords;

my $input = $ARGV[0];
my $output = $input."corrected.csv";

my ($header) = ();
my (@lines) = ();


open(DATAFILE, "<$input") || die "\nUnable to open file $input\n";
	@lines = <DATAFILE>;
close(DATAFILE);

$header = shift @lines;

open(DATAFILE, ">$output") || die "\nUnable to open file $output\n";

print DATAFILE "$header,Corrected NombreColector";
 
foreach my $item (@lines) {
	my @values = &parse_csv($item);
	my $corrected = &format_colector($values[1]);
	push(@values, $corrected);
	print_csv(@values);
};
close(DATAFILE);




sub parse_csv {
	return quotewords(",",0, $_[0]);
}

sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
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
			print DATAFILE ",$item";
		} else {
			print DATAFILE "$item"; 
			$line_start = 1;
		};		
	};
	print DATAFILE "\n";
}

sub format_colector {
	my $string = shift;
	$string =~ s/[^\w\s\d-\.,;:()&]//g;
	if (!(trim($string))) {
		$string = "Sin colector";
	        return $string;
	};
	$string = lc($string);
	$string =~ s/;/,/g;	
        $string =~ s/(\w+)\./$1. /g;
	$string =~ s/(\S{4,})\./$1 /g;
	$string =~ s/\b([^\WYy]{1})\b/$1\./g;
	$string =~ s/(\w+)\s+(\.|,)\.?/$1$2/g;	
	$string =~ s/\.\././g;	
	$string =~ s/\.\s+\.?,/.,/g;	
        $string =~ s/\s{2,}/ /g;
	$string =~ s/(\w+)/\u$1/g;

	$string =~ s/et\.?\sal\.?/et al./ig;
	$string =~ s/\b(de|del|la|lo|el|los|las|et|and|y)\b/\L$1/ig;
        $string =~ s/\bMcVaugh\b/McVaugh/ig;
        $string =~ s/\bDePuga\b/de Puga/ig;
        $string =~ s/\bCarbajal\b/Carvajal/ig;

	return $string;
}
