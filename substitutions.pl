#!/usr/bin/perl -w
#
# How to use: substitutions.pl file > output

use strict;

my $input = $ARGV[0];
my $line = ();
my @input_lines = ();

my $code = "foreach my \$line (\@input_lines) {\n";

while (<DATA>) {
	chomp;
	my ($in, $out) = split /\s*=>\s*/;
	next unless $in && $out;
	$in =~ s/@?([^@]*)@?/$1/;
	$out =~ s/@?([^@]*)@?/$1/;
	$code .= "\$line =~ s/(\\s+|\"|^)$in(\\s+|\"|\$)/\$1$out\$3/g";
	$code .= ";\n";
}

$code .= "print \$line;\n";
$code .= 'print "\n";';
$code .= "\n}\n";

print $code;

open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	@input_lines = <DATAFILE>;
close(DATAFILE);

#eval "{ $code }" || die;

__END__
@w+,\s+&@ => @ &@
@w+\.&\s+al\.@ => @. et al.@
@w+\.&\s+al@ => @. et al.@
@w+,"@ => @"@

@& et al.@ => @et al.@


Ram'rez => Ramírez
@J,A,PérezdelaRosa@ => @J. A. Perez de la Rosa@


