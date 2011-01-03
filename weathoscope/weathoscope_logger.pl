#!/usr/bin/perl

use Device::SerialPort;
use DateTime;
use Data::Dumper;

$LOGDIR    = "/var/www/htdocs";
#$LOGDIR    = "/tmp";
$LOGFILE   = "weathoscope.out";
$CSVFILE   = "weathoscope.csv";
$PORT      = "/dev/ttyU0";
#$PORT      = "/dev/ttyUSB1";

my $port = Device::SerialPort->new($PORT);
$port->databits(8);
$port->baudrate(9600);
$port->parity("none");
$port->stopbits(1);

open(LOG,">${LOGDIR}/${LOGFILE}") || die "can't open log file\n";
open(CSV,">>${LOGDIR}/${CSVFILE}") || die "can't open csv file\n";

while (1) {
  my $data = $port->lookfor();
  if ($data) {
    #print "$data\n";

    #write latest to LOG
    truncate(LOG, 0);
    seek(LOG, 0, 0);
    syswrite LOG, $data;

    #now decode for the CSV
    my $dt = DateTime->now();

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
    #write csv
    my $csv = "$dt, $degreesC\n";
    syswrite CSV, $csv;
  } else {
    sleep(1);
  }
}

