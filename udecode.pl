#!/usr/bin/perl -w
use strict;

BEGIN {
     use utf8;
     package Encode::myhtml;
     use base qw(Encode::Encoding);

     __PACKAGE__->Define('myhtml');

     my %subst = (
	'&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;',
	"\x{00a0}" => '&nbsp;', "\x{2014}" => '&mdash;', "\x{00df}" => 'ss'
     );

     sub encode ($$;$) {
	(my $str = $_[1]) =~ s/([&<">\x{0080}-\x{ffff}])/$subst{$1} || $1/ge;
	$_[1] = '' if $_[2];
	Encode::encode('koi8-r', $str, Encode::FB_HTMLCREF);
     }
};

use utf8;
use encoding 'utf8', STDOUT => 'myhtml';

print "\x{2020}?Ý?Ý???+?Ý?+?Ý\x{A0}\x{2014} Geschlo\x{DF}en";
