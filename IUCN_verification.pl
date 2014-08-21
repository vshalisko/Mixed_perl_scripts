#!/usr/bin/perl
 
use strict;
use HTML::Selector::XPath::Simple;
use LWP::UserAgent;
use Text::Wrap;

my $input = $ARGV[0];


open(DATAFILE, "<$input") || die "\nUnable to open input table $input\n";
	my @input_lines = <DATAFILE>;
close(DATAFILE);

foreach my $species (@input_lines) {

	$species = &trim($species); 
	print "\n$species, ";
	$species =~ s/\s+/-/g;
 
	my $response = LWP::UserAgent->new->request(
	  HTTP::Request->new( GET => "http://api.iucnredlist.org/go/$species" )
	);
 
	my $selector = HTML::Selector::XPath::Simple->new($response->content);
	my $cat = $selector->select('#red_list_category_title');
	my $code = $selector->select('#red_list_category_code');
#	my $criteria = $selector->select('#red_list_criteria');
	my $year = $selector->select('#modified_year');
	my $version = $selector->select('#category_version');

	if ($cat) {
#	        print "IUCN Red List Status: $cat \($code\) ver. $version, updated $year\n";
	        print "$cat \($code\), ver. $version updated $year";
	} else {
		print "No IUCN Red List entry";
	}
	

#	my $justification = $selector->select('#justification');
 
#	print wrap("","",$justification);


}

sub trim {
	my @out = @_;
	for (@out) {
		s/^\s+//;
		s/\s+$//;
	};
	return wantarray ? @out : $out[0];
}
