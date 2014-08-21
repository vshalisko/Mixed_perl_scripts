#!/usr/local/bin/perl


use MSDOS::Descript;

my $d = new MSDOS::Descript;

undef $/;

open(TEXT, "<$ARGV[0]") || die "Unable to open file $ARGV[0]";

print "Processing of file:\n$ARGV[0]\n\n";

$text=<TEXT>;

while ($text =~ m/<li>(.+?)<span(.*?)href='(.+?)'>/gism) {
	my $filename = $3;
	my $description = $1;
	chop $description;

	if ($d->description($filename)) {
		print "\nDescription for $filename already exists: ";
		print $d->description($filename);
	} else {
		print "\nNew description for $filename: ";
		print $description;
		$d->description($filename, $description);
	};

};

close(TEXT);

$d->update;


exit 1;