#!/usr/local/bin/perl
print "Наше вам с кисточкой!\n";
print "Скрипт должен вырезать из html теги <font> с прибамбасами\n";
print "копия файла до модификации записывается как *.old\n";
print "файлы размером в сотни килобайт могут обрабатываться _очень_ долго :-)\n";
print "\n";
print "Формат запуска: fontreplace.pl <arg1>\n";
print "где <arg1> - имя обраратывемого файла\n";
print "\n";
print "(c) Vjacheslav Shalisko, June 2000\n";
#
$newfilename = $ARGV[0].".old";
open(TEXT, "<$ARGV[0]") || die "Файл для чтения не найден!";
open(FILE, ">$newfilename") || die "Файл для записи не найден!";
while (<TEXT>) {
	$text = $text.$_;
	print FILE $_;
};
close(FILE);
close(TEXT);
#
print "\n";
print "Прочитали файл ".$ARGV[0]."\nи перезаписали как ".$newfilename."\n";
print "Поиск... ";
#
while ($text =~ m/<font((.|\n)*?)>|<\/font>/i) {
	$text =~ s/<font((.|\n)*?)>|<\/font>//i;
};
@textlines = split(/\n/, $text);
#
print "поиск завершен, запись результата... ";
#
open(TEXT1, ">$ARGV[0]") || die "Файл вывода не найден!";
foreach $line (@textlines) {
	print TEXT1 $line."\n";
};
close(TEXT1);
print "записали. Всё.\n";
#
exit 1;