#!/usr/local/bin/perl 
#
##---------------------------------------------------------------------------##
##  Author:
##      Viacheslav Shalisko       vshalisko@gmail.com
##  Description:
##      Program for creating index of text (or other) files with descriptions
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
##
##  How this script works?
##  Directory for indexing should contain text, document or image files, 
##  descriptions to those files could be stored in descript.ion file, as
##  well this descript.ion can contaio description of index.htm file that 
##  will be interpreted as title for whole directory. Script will built 
##  new index.htm file (renaming old as index.htm.bak) with included 
##  descriptions of files and directory. All first level subdirectories 
##  containing index.htm file would be included as links with descriptions.
##
##
##---------------------------------------------------------------------------##



use Sys::Hostname;
use File::stat;
use File::Copy;
use MSDOS::Descript;


my $dir = $ARGV[0];
my $outfile = $ARGV[1] || "index.htm";
my (%anchtor,%description,%link,%lang);

chdir $dir || die "\nCan`t open directory $dir\n";
if (-e $outfile) { 
# die "\nFile $outfile already exists.\nDefine another filename for index file.\n" 
  my $outfile_rename = $outfile.".bak";
  print "\nFile $outfile already exists.\nExisting index file will be renamed as $outfile_rename.\n"; 
  move("$outfile", "$outfile_rename") or die "Rename failed: $!";
};

my $d = new MSDOS::Descript;

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
   my @textfilemask = ("*.doc", "*.wpd", "*.pdf", "*.djvu", "*.doc", "*.xls", "*.pdb", "*.nfo", "*.txt", "*.chm");
   my @imagefilemask = ("*.jpg", "*.jpeg", "*.gif", "*.tiff", "*.tif",, "*.png", "*.bmp");
   my @indexfilemask = ("index.htm");

   chdir $dir || die "\nCan`t go to directory $dir\n";

   opendir(DIR, $dir) or (warn "\nCannot open $dir: $!" and next);
    my @dircontents = readdir DIR; 
   closedir(DIR);
   my @subdirs = grep {-d and not /^\.{1,2}$/} @dircontents;

   foreach my $subdir (@subdirs) {
     chdir $subdir || die "\nCan`t go to directory $subdir\n";
           my $sd = new MSDOS::Descript;
           while (<@indexfilemask>) {
    my $path=$subdir."\\".$_;
    my $path_with_slash="\\".$path;
             if ($sd->description($_)) {
        $description{$path_with_slash}=$sd->description($_);
          };

    $anchtor{$path_with_slash} = "indexed&nbsp;directory&nbsp;<a href='$path'><b>$path<\/b><\/a>";
     };
      chdir $dir || die "\nCan`t go to directory $dir\n";
   };


   while(<@textfilemask>) {
     my $inode=stat("$_");
     my $size=sprintf("%.2f", ($inode->size)/1024);
           if ($d->description($_)) {
      $description{$_}=$d->description($_);
    if ($description{$_} =~ /(L|l)=(ru|sp|en|de|fr|la|gr)/) {
      $lang{$_}=$2;
      $description{$_} =~ s/(L|l)=(ru|sp|en|de|fr|la|gr)//;
    };
     };
           $anchtor{$_} = "text&nbsp;file&nbsp;<a href=\"$_\"><b>$_<\/b><\/a>,&nbsp;$size&nbsp;k";
   };

   while(<@imagefilemask>) {
     my $inode=stat("$_");
     my $size=sprintf("%.2f", ($inode->size)/1024);
           if ($d->description($_)) {
      $description{$_}=$d->description($_);
     };

           $anchtor{$_} = "image&nbsp;file&nbsp;<a href=\"$_\"><b>$_<\/b><\/a>,&nbsp;$size&nbsp;k";
   };


   while(<@htmlfilemask>) {

           $anchtorpath = $_;
     my $inode=stat("$_");
     my $size=sprintf("%.2f", ($inode->size)/1024);
           if ($d->description($_)) {
      $description{$_}=$d->description($_);
    if ($description{$_} =~ /(L|l)=(ru|sp|en|de|fr|la|gr)/) {
      $lang{$_}=$2;
      $description{$_} =~ s/(L|l)=(ru|sp|en|de|fr|la|gr)//;
    };
     };

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
           $anchtor{$anchtorpath} = "html&nbsp;file&nbsp;<a href=\"$anchtorpath\"><b>$anchtorpath<\/b><\/a> with title <i>$title<\/i>,&nbsp;$size&nbsp;k";
    }
    else {
           $anchtor{$anchtorpath} = "html&nbsp;file&nbsp;<a href=\"$anchtorpath\"><b>$anchtorpath<\/b><\/a> with title <i>".&RECODE($title, $encoding)."<\/i>,&nbsp;$size&nbsp;k";
    };
           }
           else {
               $anchtor{$anchtorpath} = "html&nbsp;file&nbsp;<a href=\"$anchtorpath\"><b>$anchtorpath<\/b><\/a>,&nbsp;$size&nbsp;k";
           };
 
           if (($header =~ /<!-- saved from url=\(\d{4}\)(http:|ftp:|goopher:)\/\/(.*?) -->/i) and ($2 ne '')) {
               $link{$anchtorpath} = "$2";
           };
    };
};

sub CREATEINDEX {

   my ($linknumber,$anchtorpath,$item,$i,$host);
   $host = hostname;


   if ($d->description("index.htm")) {
    $directory_title=$d->description("index.htm");
   } else { 
  $directory_title="&nbsp;";
   };

   chdir $dir  || die "\nCan`t open directory $dir\n";
   open(TEXT1, ">>$outfile") || die "\nCan`t open output file $outfile\n";

print TEXT1 <<"HTML_OUT";
<HTML><HEAD>\n<TITLE>Archive of articles & books index</TITLE>
<META http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=windows-1251\">
<META NAME=\"Generator\" CONTENT=\"Perl script by Viacheslav Shalisko\">

<style type=text/css>

<!--                                              
BODY {font-family: Arial, sans-serif; font-size: 12; color: #505050; background-color: #FFFFFF}
A    {text-decoration: underline}
A:link    {color: dimgray}
A:visited {color: dimgray}
A:active  {color: steelblue}
A:hover   {color: steelblue}
SUP {font-size: 10; text-decoration: none}
LI {margin-top: 7px}
OL {font-size: 11}
.lang {font-size: 9px; color: blue;}
.desc {font-size: 13px}
.file {font-size: 11px}
-->

</style>

</HEAD><BODY>
<H3>Article & book index
<BR>$directory_title</H3><BR>
<ADDRESS><A HREF="../index.htm">One level up directory</A>. Indexed directory on \u$host: $dir.</ADDRESS>

<UL>

HTML_OUT


      $i = 1;
      foreach $anchtorpath (sort { ($description{$a} cmp $description{$b}) ||
   ($anchtor{$a} cmp $anchtor{$b}) || ($a cmp $b) } keys %anchtor) {
           print TEXT1 "<LI><SPAN CLASS=lang>".$lang{$anchtorpath}."&nbsp;</SPAN>\n<SPAN CLASS=desc>".$description{$anchtorpath}." (<\/SPAN><SPAN CLASS=file>".$anchtor{$anchtorpath}."<\/SPAN><SPAN CLASS=desc>)<\/SPAN>";

     if ($link{$anchtorpath}) {
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
            print TEXT1 "&nbsp;<A HREF=#from_".$item."><SUP>".$item."</SUP></A>";
     };

     print TEXT1 "\n";
      };

      print TEXT1 "</UL>\n\n";

      if ((values %linklist) > 0) {
       print TEXT1 "<OL>\n";

       for (my $j = 1; $j <= values %linklist; ++$j)  {
      print TEXT1 "<LI TYPE=1 VALUE=".$j."><A NAME=from_".$j."></A>from ".$linklist{$j}."\n";
       };

       print TEXT1 "</OL>\n\n";
      };

      use Time::localtime;

      print TEXT1 "<BR><ADDRESS>Y".(localtime->year()+1900).", \u$host, "; 

      printf TEXT1 "%02d.%02d.%d %02d:%02d:%02d\n\n",
      localtime->mday(), localtime->mon()+1, localtime->year()+1900, localtime->hour(), localtime->min(), localtime->sec();

      print TEXT1 "</ADDRESS></BODY></HTML>\n";

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

article_index - Program for creating indexlist of article, e-book & text files

=head1 SYNOPSIS

article_index.pl directory_to_indexing [html_index_filename]

html_index_filename - filename output file (index.htm is the default value)

=head1 DESCRIPTION

This script will list documents from folder and link it to html file index.htm 
(or html_index_filename), as well it will include to this list descriptions from 
descript.ion file and will link similar index.htm files from subdirectories. 
For html documents that were indexed will be noted also title information and 
url if available. Russian titles would be recoded to windows-1251 encoding. 
Image files also could be indexed.  
        
=head1 NOTES

Require MSDOS::Descript module from CPAN.
This program was created for my own use.

=head1 AUTHOR

Viacheslav Shalisko, vshalisko@mail.ru, vshalisko@gmail.com

2003 - 2005

=cut
