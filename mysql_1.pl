#!/usr/local/bin/perl
#
# Script to launch MySQL request and store resulting table in .csv
# How to use: perl mysql.pl > table.csv

use locale;
use DBI();

$database = "ibug";
$hostname = "localhost";
$port = "3306";
$user = "admin";
$password = "S1fg76RE821paA";


#$sqlrequest = "SELECT author, kindom FROM (SELECT author, kindom FROM temp_authors WHERE (kindom = 4) OR (kindom = 3)) AS t GROUP BY author;";
#$sqlrequest = "SELECT * FROM main WHERE Genero IS NULL ORDER BY Familia, IdEjemplar;";
#$sqlrequest = "SELECT Estado, Pais, COUNT(*) FROM main GROUP BY Pais, Estado ORDER BY Pais, Estado;";
#$sqlrequest = "SELECT Genero, Familia, COUNT(*) FROM main GROUP BY Familia, Genero ORDER BY Familia, Genero;";
#$sqlrequest = "SELECT Genero, Especie, Autor, COUNT(*) FROM main GROUP BY Genero, Especie, Autor ORDER BY Genero, Especie, Autor;";
#$sqlrequest = "SELECT Familia, COUNT(*) AS Count FROM main GROUP BY Familia ORDER BY Familia";
#$sqlrequest = "SELECT NombreColector FROM temp_colectores GROUP BY NombreColector ORDER BY NombreColector";

$sqlrequest = "
    SELECT 
    *
    FROM col_det_agent
    
";


my $header_flag = ();

$dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";

$dbh = DBI->connect($dsn, $user, $password, {'RaiseError' => 1});

  my $sth = $dbh->prepare (qq{
  SET 
  character_set_client = 'utf8',
  character_set_results = 'utf8',
  character_set_server = 'utf8',
  character_set_database = 'utf8',
  character_set_connection = 'utf8'
  });
  $sth->execute();
  $sth->finish();


  $sth = $dbh->prepare($sqlrequest);

  $sth->execute();

while (my $ref = $sth->fetchrow_hashref()) {

  my $line_start = ();  
  if (!($header_flag)) {
    for my $key (sort keys %$ref) { 
      push(@header, $key);
      my $item = &trim($key);

      if ($item =~ /,/g) {
        $item =~ s/"/\\"/g;
        $item = '"'.$item.'"';
      }
      if ($line_start) {
        print ",$item";
      } else {
        print "$item"; 
        $line_start = 1;
      };    

                        $line_start = 1;  
    };
    $header_flag = 1;
    $line_start = ();      # Set line flag to Undef to print first data line      
    print "\n";
  };

  foreach my $key (@header) {

#         my $item = &trim($ref->{$key});
          my $item = $ref->{$key};

    if ($item =~ /,/g) {
      $item =~ s/"/\\"/g;
      $item = '"'.$item.'"';
    }
    if ($line_start) {
      print ",$item";
    } else {
      print "$item"; 
      $line_start = 1;
    };    

  };
  print "\n";

}

  $sth->finish();

      
$dbh->disconnect();


sub trim {
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  };
  return wantarray ? @out : $out[0];
}
