#!/usr/local/bin/perl

use Geo::Shapelib qw /:all/;
use Test::Simple tests => 20;



my $shape = new Geo::Shapelib  { 
    Shapetype => POLYLINE,
};

for (0..0) {
    push @{$shape->{Shapes}}, {
	Vertices=>[[0,0],[1,1]]
	};
}
for (0..0) {
    $s = $shape->get_shape($_);
    @l = $shape->lengths($s);
    ok(abs($l[0] - sqrt(2)) < 0.00001,'lengths');
}

my $test;

my $shapefile = 'test_shape';

my $shape = new Geo::Shapelib { 
    Name => $shapefile,
    Shapetype => POINT,
    FieldNames => ['Name','Code','Founded'],
    FieldTypes => ['String:50','String:10','Integer:8']
    };

while (<DATA>) {
    chomp;
    ($station,$code,$founded,$x,$y) = split /\|/;
    push @{$shape->{Shapes}}, {
	Vertices=>[[$x,$y]]
	};
    push @{$shape->{ShapeRecords}}, [$station,$code,$founded];
}

$rec = $shape->get_record_hashref(0);

$shape->dump("$shapefile.dump");

$shape->save();
