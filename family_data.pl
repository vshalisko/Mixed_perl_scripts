#!/usr/local/bin/perl

## This program will process database with data in CSV formta to sort data from 
## second and third field of each coloumn and writing this to separate file
## resulting files should be located in /out directory. Be careful! If any file 
## already is in this directory programm will not worc correctly
##
## How to use: perl species_data.pl directory datafile
##
## Database format:
## First field in row - ID
## Second field - Genus
## Third field - Specie
## More fields - anything else
##


use Text::ParseWords;
use HTML::Entities;

my $dir = $ARGV[0];
my $infile = $ARGV[1] || "data.txt";
my $outfile = "mod_".$ARGV[1] || "mod_data.txt";
#my ($header) = ();
my (@lines) = ();
my (%names,%actual) = ();

chdir $dir || die "\nUnable open directory $dir\n";

open(DATAFILE, "<$infile") || die "\nUnable to open file $infile\n";
	{
	local $/ = undef;
	@lines = split(/<br>/, <DATAFILE>);
	}
close(DATAFILE);

#$header = shift @lines;

open(OUTFILE, ">$outfile") || die "\nUnable to open file $outfile\n";

foreach my $item (@lines) {

	my @values = &parse_line($item);
	foreach (@values) { chomp; }
	my $name = shift @values;
	my $record = {
		NAME 	=> $name,
		AUTHORS => shift @values,
		YEAR	=> shift @values,
		};

	if ($item =~ m/(&nbsp;){14}/) {
		# synonime	
		$actual{'SYN'} = $actual{'SYN'}."$name $record->{AUTHORS} $record->{YEAR}; ";
	} elsif ($item =~ m/(&nbsp;){7}/) {
		# family - main procedure and reset of SYN
		print OUTFILE "$actual{'SYN'}";
		print OUTFILE "\n$name $record->{AUTHORS} $record->{YEAR}\t";
		print OUTFILE "$actual{'ORDEN'}\t$actual{'SUPERORDEN'}\t$actual{'SUBCLASS'}\t$actual{'CLASS'}\t";
		$actual{'SYN'} = ();
	} elsif ($item =~ m/(&nbsp;){5}/) {
		# orden
		$actual{'ORDEN'} = $name." ".$record->{AUTHORS}." ".$record->{YEAR}; 
	} elsif ($item =~ m/(&nbsp;){4}/) {
		# subclasse
		$actual{'SUPERORDEN'} = $name." ".$record->{AUTHORS}." ".$record->{YEAR}; 
	} elsif ($item =~ m/(&nbsp;){3}/) {
		# subclasse
		$actual{'SUBCLASS'} = $name." ".$record->{AUTHORS}." ".$record->{YEAR}; 
	} elsif ($item =~ m/(&nbsp;){2}/) {
		# classe
		$actual{'CLASS'} = $name." ".$record->{AUTHORS}." ".$record->{YEAR}; 
	};

}

print OUTFILE "$actual{'SYN'}";
if (OUTFILE) { close(OUTFILE); }

#open(OUTFILE, ">$outfile") || die "\nUnable to open file $outfile\n";
#print OUTFILE "$database{$id}";	
#if (OUTFILE) { close(OUTFILE); }
		
print "\n\nEnd of work. Database precessed.";

#sub parse_csv {
#	return quotewords(",",0, $_[0]);
#}

sub parse_line {
	my @result = ();
	my $string = decode_entities($_[0]);
	$string =~ s/\240/&nbsp;/g;
	if ($string =~ /(&nbsp;*)\d*\.?\s*?([A-Za-z]+)\s*((\D|\s)+?)\s*(\([\d-]*\))/s) {
#		print "$2 $3 $4\n";
		@result = ($2, $3, $5);
		foreach (@result) { 
			s/\n//;
			s/&nbsp;/ /g;
		}
	}
	return @result;
}