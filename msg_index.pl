#!/usr/local/bin/perl
print "\n\nНаше вам с кисточкой!\n";
print "Скрипт для создания индекса msg файлов (т.е. базы сообщений)\n";
print "\n";
print "Формат запуска: msg_index.pl <arg1> <arg2>\n";
print "где <arg1> - путь к каталогу файлов *.msg для индексирования\n";
print "    <arg2> - имя html-файла индекса\n";
print "\n";
print "(c) Vjacheslav Shalisko, June 2000\n";
#
sub RECODE {
	($hex, $encoding) = @_;
	if ($encoding == "koi") {
	$hex =~ tr/\xC0-\xFF/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9\xD7\xDA/;	
	}
	elsif ($encoding == "alt") {
	$hex =~ tr/\xEE\xA0\xA1\xE6\xA4\xA5\xE4\xA3\xE5\xA8-\xAF\xEF\xE0-\xE3\xA6\xA2\xEC\xEB\xA7\xE8\xED\xE9\xE7\xEA\x9E\x80\x81\x96\x84\x85\x94\x83\x95\x88-\x8F\x9F\x90-\x93\x86\x82\x9C\x9B\x87\x98\x9D\x99\x97\x9A/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9\xD7\xDA/;
	}
	elsif ($encoding == "iso") {
        $hex =~ tr/\xEE\xD0\xD1\xE6\xD4\xD5\xE4\xD3\xE5\xD8-\xDF\xEF\xE0-\xE3\xD6\xD2\xEC\xEB\xD7\xE8\xED\xE9\xE7\xEA\xCE\xB0\xB1\xC6\xB4\xB5\xC4\xB3\xC5\xB8-\xBF\xCF\xC0-\xC3\xB6\xB2\xCC\xCB\xB7\xC8\xCD\xC9\xC7\xCA/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9\xD7\xDA/;
	}
	elsif ($encoding == "mac") {
       	$hex =~ tr/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\x9E\x80\x81\x96\x84\x85\x94\x83\x95\x88-\x8F\x9F\x90-\x93\x86\x82\x9C\x9B\x87\x98\x9D\x99\x97\x9A/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9\xD7\xDA/;	
	}
	elsif ($encoding == "win") {
	}
	else {};
	$hex;
};
#
chdir "$ARGV[0]";
open(TEXT1, ">>$ARGV[1]") || die "Файл вывода не найден!";
      print TEXT1 "<HTML><HEAD>\n<TITLE>Message archive</TITLE>\n";
      print TEXT1 "<META http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=windows-1251\">\n";
      print TEXT1 "<META NAME=\"author\" CONTENT=\"Vjacheslav Shalisko\">\n";
      print TEXT1 "<style type=text/css>\n";
      print TEXT1 "<!--\n";
      print TEXT1 "BODY {font-family: Arial, sans-serif; color: black; background-color: ghostwhite}\n";
      print TEXT1 "A         {font-size: 12px}\n";
      print TEXT1 "A:link    {color: dimgray}\n";
      print TEXT1 "A:visited {color: dimgray}\n";
      print TEXT1 "A:active  {color: steelblue}\n";
      print TEXT1 "A:hover   {color: steelblue}\n";
      print TEXT1 "#heada {font-size: 12px; color: blue};\n";
      print TEXT1 "#myaddr {font-size: 12px; color: red};\n";
      print TEXT1 "#info {font-size: 12px};\n";
      print TEXT1 "-->\n";
      print TEXT1 "</style>\n";
      print TEXT1 "</HEAD><BODY>\n";
      print TEXT1 "<TABLE cellpadding=10 cellspacing=1 border=0><TR>\n";
      print TEXT1 "<TD><H3>Message archive</H3>\n";
	use Time::localtime;
	printf TEXT1 "<TD><H3>(%02d.%02d.%d %02d:%02d:%02d)</H3></TABLE>\n\n",
        localtime->mday(), localtime->mon(), localtime->year() + 1900, localtime->hour(), localtime->min(), localtime->sec();
      print TEXT1 "<TABLE cellpadding=10 cellspacing=1 border=0>\n";
	while(<*.MSG>) {
		print TEXT1 "\n<TR valign=top><TD width=120px><A HREF='".$_."'>".$_."</A>\n<TD ID=info>\n";
		open(FILE, "<$_");
			while(<FILE>) {
			if (m/(\AFrom:|\ATo:|\ASubject:|\ADate:)/i) {
				chomp $_;
				s/</&lt;/;
				s/>/&gt;/;
				push @header, $_;
				};
			};
		        @header = sort @header;
		        @header = reverse @header;
			
			while(@header) {
				$curstr = pop @header;
				if ($curstr =~ m/(=\?)/i) {
					if ($curstr =~ m/(koi8-r)/i) {$encoding = "koi";}
					elsif ($curstr =~ m/(ibm866)/i) {$encoding = "alt";}
					elsif ($curstr =~ m/(Windows-1251)/i) {$encoding = "win";}
					elsif ($curstr =~ m/(ISO-8859-5)/i) {$encoding = "iso";}
					elsif ($curstr =~ m/(x-mac-cyrillic)/i) {$encoding = "mac";}
					else {$encoding = "non";};
					if ($curstr =~ m/(\?(koi8-r|Windows-1251|ibm866|ISO-8859-5|ISO-8859-1|x-mac-cyrillic)\?B\?)/i) {$type = "Quot";}
					elsif ($curstr =~ m/(\?(koi8-r|Windows-1251|ibm866|ISO-8859-5|ISO-8859-1|x-mac-cyrillic)\?Q\?)/i) {$type = "Quot";}
					else {$type = "non";};
					@symbarray = split(/=/, $curstr);
					@symbarray = reverse @symbarray;
					$curstr = "";
					while (@symbarray) {
						$symb = pop @symbarray;
						if ($type =~ m/Quot/i) {                        	
							if ((length($symb) >= 2) & not($symb =~ m/(\AFrom:|\ATo:|\ASubject:|\ADate:|koi8-r|Windows-1251|ibm866|ISO-8859-1|ISO-8859-1|x-mac-cyrillic|&lt;|&gt;)/i)) {
								$hexstr = substr($symb, 0, 2);
								$hexstr = hex ($hexstr);
								$hexstr = chr ($hexstr);
        							$strrel = substr($symb, 2);
								$hexstr = &RECODE($hexstr, $encoding);
 								$curstr = $curstr.$hexstr.$strrel;}
							else {$curstr = $curstr.$symb};
						}
						elsif ($type =~ m/Base/i) {
							while ($symb =~ m/(\?(koi8-r|Windows-1251|ibm866|ISO-8859-5|ISO-8859-1|x-mac-cyrillic)\?[QB]\?)/i) {
								$symb =~ s/((koi8-r|Windows-1251|ibm866|ISO-8859-5|ISO-8859-1|x-mac-cyrillic)\?[QB])//i;
							};
							while (@symbarray) {
								$symbarrayget = pop @symbarray;
								@symbarray1 = split(/\?/, $symbarrayget);
								while (@symbarray1) {
									$symb1 = pop @symbarray1;
									if ((length($symb1) >= 4) & not($symb1 =~ m/(\AFrom:|\ATo:|\ASubject:|\ADate:)/i)) {							
								
									while (length($symb1) >= 4) {
										$hexstr = substr($symb1, 0, 4);
										@hexarray = split(//, $hexstr);
#										$hexarray[0] = ord $hexarray[0];
#										$hexarray[1] = ord $hexarray[1];
#										$hexarray[2] = ord $hexarray[2];
#										$hexarray[3] = ord $hexarray[3];
	                                                	        	$symb1 = substr($symb1, 4);
										$curstr = $curstr.$hexarray[0].$hexarray[1].$hexarray[2].$hexarray[3];
									};}
									else {$curstr = $curstr.$symb};
								};
							};
						}
						else {$curstr = $curstr.$symb};

					};
					while ($curstr =~ m/(\?(koi8-r|Windows-1251|ibm866|ISO-8859-5|ISO-8859-1|x-mac-cyrillic)\?[QB]\?)/i) {
						$curstr =~ s/(\?(koi8-r|Windows-1251|ibm866|ISO-8859-5|ISO-8859-1|x-mac-cyrillic)\?[QB]\?)//i;
					};
					while ($curstr =~ m/(\? |\?)/i) {
						$curstr =~ s/(\? |\?)//i;
					};
				};
				$curstr =~ s/(\AFrom:)/<SPAN ID=heada>From : <\/SPAN>/i;
				$curstr =~ s/(\ATo:)/<SPAN ID=heada>To : <\/SPAN>/i;
				$curstr =~ s/(Subject:)/<SPAN ID=heada>Subject : <\/SPAN>/i;
				$curstr =~ s/(\ADate:)/<SPAN ID=heada>Date : <\/SPAN>/i;
				$curstr =~ s/(vshalisko\@mail.ru|vshalisko\@chat.ru|vshalisko\@mail.spbnit.ru|vshalisko\@emailcom|vshalisko\@usa.net|vshalisko\@hotmail.com)/<SPAN ID=myaddr>$1<\/SPAN>/i;
					print TEXT1 $curstr."<BR>\n";
			};
			close(FILE);
	};
      print TEXT1 "\n</TABLE>\n";
      print TEXT1 "</BODY></HTML>\n";
close(TEXT1);
exit 1;
