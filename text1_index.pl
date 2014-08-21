#!/usr/local/bin/perl 
#
##---------------------------------------------------------------------------##
##  Author:
##      Vjacheslav Shalisko       vshalisko@email.com
##  Description:
##      Program for creating index of text files
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

use Sys::Hostname;

my $dir = $ARGV[0];
my $outfile = $ARGV[1] || "index.html";

chdir $dir || die "\nCan`t open directory $dir\n";
if (-e $outfile) { 
  die "\nFile $outfile already exists.\nDefine another filename for index file.\n" 
};

my $koi_enc = "\xC0-\xFF";
my $win_enc = "\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6".
           "\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4".
           "\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9".
           "\xD7\xDA";
my $alt_enc = "\xEE\xA0\xA1\xE6\xA4\xA5\xE4\xA3\xE5\xA8-\xAF\xEF\xE0-\xE3\xA6".
           "\xA2\xEC\xEB\xA7\xE8\xED\xE9\xE7\xEA\x9E\x80\x81\x96\x84\x85\x94".
           "\x83\x95\x88-\x8F\x9F\x90-\x93\x86\x82\x9C\x9B\x87\x98\x9D\x99".
           "\x97\x9A";
my $iso_enc = "\xEE\xD0\xD1\xE6\xD4\xD5\xE4\xD3\xE5\xD8-\xDF\xEF\xE0-\xE3\xD6".
           "\xD2\xEC\xEB\xD7\xE8\xED\xE9\xE7\xEA\xCE\xB0\xB1\xC6\xB4\xB5\xC4".
           "\xB3\xC5\xB8-\xBF\xCF\xC0-\xC3\xB6\xB2\xCC\xCB\xB7\xC8\xCD\xC9".
           "\xC7\xCA";
my $mac_enc = "\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6".
           "\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\x9E\x80\x81\x96\x84\x85\x94".
           "\x83\x95\x88-\x8F\x9F\x90-\x93\x86\x82\x9C\x9B\x87\x98\x9D\x99".
           "\x97\x9A";

&SCANFILES;
&CREATEINDEX;

sub SCANFILES {

   my ($anchtorpath,$encoding,$title,$header);  
   my @htmlfilemask = ("*.htm", "*.html", "*.shtml");

   chdir $dir || die "\nCan`t open directory $dir\n";

   while(<*.txt>) {
     $anchtor{$_} = $_;
           $link{$_} = "unknown host";
   };

   while(<*.pdf>) {
     $anchtor{$_} = $_;
           $link{$_} = "unknown host";
   };

   while(<*.djvu>) {
     $anchtor{$_} = $_;
           $link{$_} = "unknown host";
   };


   while(<@htmlfilemask>) {

           $anchtorpath = $_;

           open(FILE,"<$anchtorpath");
                $header = ();
            while (<FILE>) { 
      if (1 .. /<body/oi) {
        $header = $header.$_;
      };
    };
           close(FILE);

     $encoding = ();
           if ($header =~ /<meta(.*?)charset=koi8-r(.*?)>/oi) { $encoding = "koi"; }
           elsif ($header =~ /<meta(.*?)charset=windows-1251(.*?)>/oi) { $encoding = "win"; }
           elsif ($header =~ /<meta(.*?)charset=(ibm|cp)866(.*?)>/oi) { $encoding = "alt"; }
           elsif ($header =~ /<meta(.*?)charset=ISO-8859-5(.*?)>/oi) { $encoding = "iso"; }
           elsif ($header =~ /<meta(.*?)charset=x-mac-cyrillic(.*?)>/oi) { $encoding = "mac"; }
           else { $encoding = "win"; };

           if (($header =~ /<title>(.*?)<\/title>/oi) and ($1 ne '')) {
    $title = $1;
    if ($encoding =~ /win/o) {
           $anchtor{$anchtorpath} = $title;
    }
    else {
           $anchtor{$anchtorpath} = &RECODE($title, $encoding);
    };
           }
           else {
               $anchtor{$anchtorpath} = "$anchtorpath";
           };
 
           if (($header =~ /<!-- saved from url=\(\d{4}\)(http:|ftp:|goopher:)\/\/(.*?)\/(.*?)-->/oi) and ($2 ne '')) {
               $link{$anchtorpath} = "$2";
           }
           else {
               $link{$anchtorpath} = "unknown host";
           };
    };
};

sub CREATEINDEX {

   my ($linknumber,$anchtorpath,$item,$i,$host);
   $host = hostname;


   chdir $dir  || die "\nCan`t open directory $dir\n";
   open(TEXT1, ">>$outfile") || die "\nCan`t open output file $outfile\n";

print TEXT1 <<"HTML_OUT";
<HTML><HEAD>\n<TITLE>Index</TITLE>
<META http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=windows-1251\">
<META NAME=\"Generator\" CONTENT=\"Perl script by Vjacheslav Shalisko\">

<style type=text/css>

<!--
BODY {font-family: Arial, sans-serif; font-size: 12; color: #505050; background-color: #E8E8E8}
A    {font-size: 12px; text-decoration: underline}
A:link    {color: dimgray}
A:visited {color: dimgray}
A:active  {color: steelblue}
A:hover   {color: steelblue}
SUP {font-size: 10; text-decoration: none}
OL {font-size: 11}
-->

</style>

</HEAD><BODY>
<TABLE cellpadding=10 cellspacing=1 border=0><TR>
<TD><H3>Texts list :</H3><TD><H3>$dir :</H3>\n
HTML_OUT

      use Time::localtime;
      printf TEXT1 "<TD><H3> %02d.%02d.%d %02d:%02d:%02d</H3></TABLE>\n\n",
      localtime->mday(), localtime->mon()+1, localtime->year()+1900, localtime->hour(), localtime->min(), localtime->sec();
      print TEXT1 "<UL>\n";

      $i = 1;
      foreach $anchtorpath (sort {my ($c,$d) = ($a,$b); my ($c_str,$c_dig) = ($c =~ m/(.*?)(\d+)/); my ($d_str,$d_dig) = ($d =~ m/(.*?)(\d+)/); return ($c_str cmp $d_str) || ($c_dig <=> $d_dig); } keys %anchtor) {
           print TEXT1 "<LI><A HREF='".$anchtorpath."'>".$anchtor{$anchtorpath}."</A>";
     $item = 0;
     foreach $linknumber (keys %linklist) {
     if ($linklist{$linknumber} =~ /$link{$anchtorpath}/i) {
            $item = $linknumber;
     };
     };
           if ($item == 0) {
    $linklist{$i} = $link{$anchtorpath};
    $item = $i;
    $i++;
     };
#          print TEXT1 "&nbsp;<A HREF=#from_".$item."><SUP>".$item."</SUP></A>";
     print TEXT1 "\n";
      };

      print TEXT1 "</UL>\n\n";
#     print TEXT1 "<OL>\n";
#
#     for (my $j = 1; $j <= values %linklist; ++$j)  {
#   print TEXT1 "<LI TYPE=1 VALUE=".$j."><A NAME=from_".$j."></A>from ".$linklist{$j}."\n";
#     };
#
#     print TEXT1 "</OL>\n\n";

      print TEXT1 "<BR><ADDRESS>Y".(localtime->year()+1900).", \u$host</ADDRESS></BODY></HTML>\n";

   close(TEXT1);
};

sub RECODE {

  my ($str, $enc) = @_;
  my ($res, $hex, $from_enc) = ();

  if ($enc =~ /koi/o) { $from_enc = $koi_enc; }
  elsif ($enc =~ /alt/o) { $from_enc = $alt_enc; }
  elsif ($enc =~ /iso/o) { $from_enc = $iso_enc; }
  elsif ($enc =~ /mac/o) { $from_enc = $mac_enc; }
  elsif ($enc =~ /win/o) { $res = $str; }
  else { $res = $str; };

  if (not(defined($res))) {
      foreach $hex (split(//, $str)) {
    eval qq{ \$hex =~ tr|$from_enc|$win_enc|; };
          $res .= $hex;
      };
  };

  $res;
};

exit 1;

__END__

=head1 NAME

text_index - Program for creating indexlist of text files

=head1 SYNOPSIS

text_index.pl directory_to_indexing [html_index_filename]

html_index_filename - filename output file (index.htm is the default value)

=head1 DESCRIPTION

No doc yet

=head1 NOTES

No doc yet

=head1 AUTHOR

Vjacheslav Shalisko, vshalisko@email.com

Aug 2000

=cut
