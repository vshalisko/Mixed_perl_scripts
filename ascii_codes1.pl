#!/usr/local/bin/perl -w
#
##---------------------------------------------------------------------------##
##  Author:
##      Vjacheslav Shalisko       vshalisko@email.com
##  Description:
##      Program to get ASCII codes of symbols & more
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

my $num_format = (@ARGV && $ARGV[0] eq '-hex' && shift);
my $filename = $ARGV[0];
my $newfilename = $ARGV[1] || "$filename.ascii";

my (@filelines,@hexline) = ();

open(FILE, "<$filename") || die "Unable to open file $filename!";
while (<FILE>) {
	push(@filelines, $_);
};
close(FILE);

open(FILE, ">$newfilename") || die "Unable to open output file $newfilename!";
foreach my $line (@filelines) {
	@hexline = ();
	if ($num_format) {
		@hexline = unpack("H*", $line);
		foreach my $h (@hexline) { $h =~ s/((\d|[A-F])(\d|[A-F]))/$1 /gi };
	} else {
		@hexline = unpack("C*", $line);
	};
        chomp ($line);
	print FILE "$line\n";
	print FILE "@hexline\n";
};
close(FILE);
exit 1;

__END__

=head1 NAME

ascii_codes - Get ASCII numbers of symbols & more

=head1 SYNOPSIS

ascii_codes.pl [-hex] filename [output_filename]

=head1 DESCRIPTION

No doc yet

=head1 NOTES

No doc yet

=head1 AUTHOR

Vjacheslav Shalisko, vshalisko@email.com

September 2000

=cut

