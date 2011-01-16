<?php header('Content-Type: text/xml'); ?>
<?php include('credentials.php'); ?>
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="http://sodnpoo.com/sodnpoo.xsl"?>
<xml>
<post>
  <title>weathoscope</title>
  <date></date>
  <p>
  <span class="header">Current temperature:
  <?php 
    $dbh = pg_connect("host=localhost dbname=$dbname user=$dbuser password=$dbpass");
    if (!$dbh) {
      echo "error";
    }else{
      $result = pg_query($dbh, "SELECT temp FROM log ORDER BY ts DESC LIMIT 1");
      if (!$result) {
        echo "error";
      }else{
        if($row = pg_fetch_array($result)){
          echo $row['temp'];
        } 
      }
    }  
  ?>
  &#176;C
  </span>
  </p>
  <image src="/weathoscope/temp_chart_db.php"/>
  <p>
  </p>
  <image src="/weathoscope/temp_chart_db.php?x=w"/>
  <p>
  </p>
</post>
</xml>

