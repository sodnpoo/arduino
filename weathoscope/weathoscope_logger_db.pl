#!/usr/bin/perl

use Device::SerialPort;
#use Data::Dumper;
use DBI;

require "/root/bin/credentials.pl";

$dbh = DBI->connect("dbi:Pg:dbname=$dbname", $dbuser, $dbpass, {AutoCommit => 1});

$PORT      = "/dev/ttyU0";
#$PORT      = "/dev/ttyUSB1";

my $port = Device::SerialPort->new($PORT);
$port->databits(8);
$port->baudrate(9600);
$port->parity("none");
$port->stopbits(1);

while (1) {
  my $data = $port->lookfor();
  if ($data) {
    #print "$data\n";

    #looking for these
    my $degreesC = "";

    $data =~ s/\r|\n//g;
    
    my @keyvals = split(/\//, $data);
    foreach(@keyvals){
      my @keyval = split(/:/, $_);
      #degreesC
      if(@keyval[0] =~ /degreesC/){
        $degreesC = @keyval[1];
      }
      #blahblah
      #if(@keyval[0] =~ /blahblah/){
      #  $blahblah = @keyval[1];
      #}
      
    }
    
    if($degreesC){
      my $insert = "INSERT INTO LOG (ts,temp) VALUES (NOW(),$degreesC);";
      $dbh->do($insert);
    }
    
  } else {
    sleep(1);
  }
}

