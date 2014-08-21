#!/usr/local/bin/perl
#
# Script to launch MySQL request to correct autor strings and store results 
# in separate file
# How to use: perl correct_autors.pl > output_file.csv

use locale;
use DBI();

$database = "ibug_1";
$hostname = "localhost";
$port = "3306";
$user = "viacheslav";
$password = "Skila";


$sqlrequest = "SELECT Autor FROM main GROUP BY Autor;";

my $header_flag = ();

$dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";

$dbh = DBI->connect($dsn, $user, $password, {'RaiseError' => 1});

  my $sth = $dbh->prepare($sqlrequest);

  $sth->execute();

while (my $ref = $sth->fetchrow_hashref()) {

	my $line_start = ();	
	if (!($header_flag)) {
		for my $key (sort keys %$ref) { 
			push(@header, $key);
			my $item = &trim($key);
			my $item = $key;

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

                      	$line_start = 1;	
		};
		$header_flag = 1;
		$line_start = ();      # Set line flag to Undef to print first data line			

## Lines that contains header of corrected columns with result of correction
		print ",Corrected_value";

##

		print "\n";
	};

	foreach my $key (@header) {

	        my $item = &trim($ref->{$key});

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

## Lines that contains column with result of correction, this column should be manually identified here

		my $corrected_item = &trim(&format_autor($ref->{'Autor'}));

		if ($corrected_item =~ /,/g) {
			$corrected_item =~ s/"/\\"/g;
			$corrected_item = '"'.$corrected_item.'"';
		};
		print ",$corrected_item";
##


	print "\n";

}

  $sth->finish();

      
$dbh->disconnect();


sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}

sub format_autor {
	my $string = shift;
	$string =~ s/[^\.,&:'\s\w-()]//g;
        $string =~ s/&/ et /g;
        $string =~ s/\./. /g;
        $string =~ s/,/, /g;
        $string =~ s/\(\s*/ (/g;
        $string =~ s/\s*\)/) /g;
        $string =~ s/\s{2,}/ /g;
	return $string;
}
