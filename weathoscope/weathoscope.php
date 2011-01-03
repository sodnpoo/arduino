<?php header('Content-Type: text/xml'); ?>
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="http://sodnpoo.com/sodnpoo.xsl"?>
<xml>
<post>
  <title>weathoscope</title>
  <date></date>
  <p>
  <span class="header">Current temperature:
  <?php 
    $out = file_get_contents("/htdocs/weathoscope.out");
    $keyvals = explode('/', $out);
    foreach($keyvals as $keyval){
      //echo $keyval."\n";
      $kv = explode(':', $keyval);
      if($kv[0] == 'degreesC'){
        echo $kv[1];
      }
    }
  ?>
  </span></p>
  <p>
  <a href="/weathoscope.csv">log file (csv)</a>
  </p>
</post>
</xml>

