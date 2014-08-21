#!/usr/local/bin/perl 
#
# How to use: perl table_to_sql.pl table.csv > substitution_table.sql
#
# First line - header with names of Database columns to work
# Other lines - data values to work with
#
# First column - field to search for
# Second column - first field to change
# Third column - optional seconf field to change add $columns[2]='$values[2]' to SQL_OUT
# Forth column - optional third field to change add $columns[3]='$values[3]' to SQL_OUT


use locale;


$database_table = "temp_colectores";



use Text::ParseWords;

my $input = $ARGV[0];

open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	@input_lines = <DATAFILE>;
close(DATAFILE);

my $header = shift @input_lines;
my @columns = &trim(&parse_csv($header));

foreach my $item (@input_lines) {
	my @values = &escape_sql(&trim(&parse_csv(&escape_single_quote($item))));
#	my @values = &escape_sql(&parse_csv(&escape_single_quote($item)));
#========================================
print <<"SQL_OUT";

UPDATE $database_table
SET $columns[1]='$values[1]'
WHERE $columns[0]='$values[0]';
SQL_OUT
#========================================
}

sub parse_csv {
	return quotewords(",",0, $_[0]);
}

sub escape_single_quote {
	my @out = @_;
	for (@out) {
		s/\'/\\\'/g;
	};
	return wantarray ? @out : $out[0];
}


sub escape_sql {
	my @out = @_;
	for (@out) {
		s/\"/\\\"/g;	
		s/\'/\\\'/g;
	};
	return wantarray ? @out : $out[0];
}

sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}
