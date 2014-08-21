#!/usr/local/bin/perl 
#
# This script looks for list elements from .csv file and 
# How to use: perl web_search_IPNI.pl input_file > output_file
#


use locale;
use Text::ParseWords;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Heuristic;


my $url_part1 = "http://www.ipni.org/ipni/authorsearch?find_forename=&find_surname=&find_abbreviation=";
my $url_part2 = "&find_isoCountry=&output_format=normal&back_page=authorsearch&query_type=by_query";



my $input = $ARGV[0];

open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	@input_lines = <DATAFILE>;
close(DATAFILE);

foreach my $line (@input_lines) {
        my @columns = &trim(&parse_csv($line));
	my $found = 0;

        $url_complete = $url_part1.$columns[1].$url_part2;
	
	$web_content = &web_browser($url_complete);

	if ($web_content =~ /No\srecords\sfound\./g) {
		$found = 0;
	} elsif ($web_content =~ /(\d*)\srecord\sfound\./g) {
		$found = $1;
	}; 
	
	&print_csv($columns[0],$columns[1],$found);
}



sub parse_csv {
	return quotewords(",",0, $_[0]);
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

sub web_browser {
	my $url_draft =$_[0];
	my $url = URI::Heuristic::uf_urlstr($url_draft);
	my $ua = LWP::UserAgent->new();
	$ua->agent("Schmozilla/v9.14 Platinum");
	my $req = HTTP::Request->new(GET => $url);
	my $response = $ua->request($req);
	if ($response->is_error()) {
		my $content = $response->status_line;		
	} else {
		my $content = $response->content();
		return $content;
	};
}
