#!/usr/local/bin/perl
print "��� ��� � ����窮�!\n";
print "��ਯ� ������ ��१��� �� html ⥣� <font> � �ਡ����ᠬ�\n";
print "����� 䠩�� �� ����䨪�樨 �����뢠���� ��� *.old\n";
print "䠩�� ࠧ��஬ � �⭨ �������� ����� ��ࠡ��뢠���� _�祭�_ ����� :-)\n";
print "\n";
print "��ଠ� ����᪠: fontreplace.pl <arg1>\n";
print "��� <arg1> - ��� �����뢥���� 䠩��\n";
print "\n";
print "(c) Vjacheslav Shalisko, June 2000\n";
#
$newfilename = $ARGV[0].".old";
open(TEXT, "<$ARGV[0]") || die "���� ��� �⥭�� �� ������!";
open(FILE, ">$newfilename") || die "���� ��� ����� �� ������!";
while (<TEXT>) {
	$text = $text.$_;
	print FILE $_;
};
close(FILE);
close(TEXT);
#
print "\n";
print "���⠫� 䠩� ".$ARGV[0]."\n� ��१���ᠫ� ��� ".$newfilename."\n";
print "����... ";
#
while ($text =~ m/<font((.|\n)*?)>|<\/font>/i) {
	$text =~ s/<font((.|\n)*?)>|<\/font>//i;
};
@textlines = split(/\n/, $text);
#
print "���� �����襭, ������ १����... ";
#
open(TEXT1, ">$ARGV[0]") || die "���� �뢮�� �� ������!";
foreach $line (@textlines) {
	print TEXT1 $line."\n";
};
close(TEXT1);
print "����ᠫ�. ���.\n";
#
exit 1;