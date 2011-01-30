<?php 

include('credentials.php'); 

function getAvgTempAPC($interval){
  if(!($avgtemp = apc_fetch("weathoscope_temp_avg_$interval"))){
    $avgtemp = getAvgTemp($interval);
    apc_store("weathoscope_temp_avg_$interval", $avgtemp, 60);
  }
  return $avgtemp;
}

function getAvgTemp($interval){
  global $dbname;
  global $dbuser;
  global $dbpass;

  $dbh = pg_connect("host=localhost dbname=$dbname user=$dbuser password=$dbpass");
  if (!$dbh) {
    echo "error";
  }else{
    $result = pg_query($dbh, "
      SELECT 
        ROUND(AVG(temp),1)as temp 
      FROM 
        log 
      WHERE 
        ts > (CURRENT_TIMESTAMP(0) - INTERVAL '$interval')
    ");
    
    if (!$result) {
      return "error";
    }else{
      if($row = pg_fetch_array($result)){
        return $row['temp'];
      } 
    }
  }  
}

function buildTempGraphAPC($interval, $numdates, $title, $cachetime=1500){
  $cachetag = "weathoscope_temp_chart:i=$interval,n=$numdates,t=$title";
  if(!($url = apc_fetch($cachetag))){
    $url = buildTempGraph($interval, $numdates, $title);
    apc_store($cachetag, $url, $cachetime);
  }
  return $url;
}

function buildTempGraph($interval, $numdates, $title){
  global $dbname;
  global $dbuser;
  global $dbpass;

//  $title = "Temperature";

  $NUMPLOTS = 240;
  
  $url = 'http://chart.googleapis.com/chart?chid=' . md5(uniqid(rand(), true));
  $chd = 't:';
 
  $min = 100;
  $max = -100;
  $datelabels = array();
  
  $dbh = pg_connect("host=localhost dbname=$dbname user=$dbuser password=$dbpass");
  if (!$dbh) {
    $title = "error";
  }else{

    $title .= " ($interval)";

    $avg = getAvgTemp($interval);
    $chd .= "$avg,$avg|";
    
/*
    $result = pg_query($dbh, "
      SELECT 
        to_char(date_trunc('hour', ts), 'DD Mon HH24:MI')as ts, 
        round(avg(temp), 1)as temp 
      FROM 
        log 
      WHERE 
        ts > (CURRENT_TIMESTAMP(0) - INTERVAL '$interval') 
      GROUP BY 
        date_trunc('hour', ts) 
      ORDER BY 
        ts;    
    ");
*/

    $result = pg_query($dbh, "
        SELECT
          to_char(fullts, 'DD Mon HH24:MI')as ts,
          log.temp as temp
        FROM
          (SELECT 
            (date_trunc('hour', CURRENT_TIMESTAMP(0)-interval '$interval')) + (generate_series(0,(CAST(EXTRACT(epoch from (CURRENT_TIMESTAMP(0) - (CURRENT_TIMESTAMP(0)-interval '$interval')))/60/60 AS INTEGER))) * interval '1 hour') as fullts
          ) as x          
          LEFT OUTER JOIN (
            SELECT 
              date_trunc('hour', ts) as ts, 
              round(avg(temp), 1)as temp 
            FROM 
              log 
            WHERE 
              ts > (CURRENT_TIMESTAMP(0) - INTERVAL '$interval') 
            GROUP BY 
              date_trunc('hour', ts) 
          ) AS log 
            ON (x.fullts = log.ts);    
    ");

    if (!$result) {
      $title = "error";
    }else{
      $numrows = pg_num_rows($result);
      $datestep = $numrows / $numdates;
      $plotstep = ceil($numrows / $NUMPLOTS);
      
      $i = 0;
      while($row = pg_fetch_array($result)){
        if(($i % $plotstep)==0){
          if($row['temp']===NULL){
            $row['temp'] = (string)-99;
          }else{
            if($row['temp'] > $max){
              $max = $row['temp'];
            }
            if($row['temp'] < $min){
              $min = $row['temp'];
            }          
          }
          $chd .= $row['temp'] . ',';
        }
        
        if(($i % $datestep)==0){
          $datelabels[] = $row['ts'];
        }
        $i++;
      }
    }
    
    $chd = substr($chd, 0, -1);

  }  

  $chxl = '1:|';
  $chxl .= implode('|', $datelabels);

  $min -= 1;
  $max += 1;
  
  $min = round($min);
  $max = round($max);
  
  $range = $max - $min;
  $tempgrid = 100 / $range;
  $dategrid = 100 / (count($datelabels)-1);

  // Add data, chart type, chart size, and scale to params.
  $chart = array(
    'cht' => 'lc',
    'chs' => '700x250',
    'chds'=> "$min,$max",
    'chxt'=> 'y,x',
    'chd' => $chd,
    'chxr'=> "0,$min,$max",
    'chtt'=> $title,
    'chxl'=> $chxl,
    'chxtc'=>'1,10',
    'chg' => "$dategrid,$tempgrid",
    'chco'=> '00cc00,7D26CD',
//    'chls'=> '1|1',
//    'chdl'=> 'Avg|Temp',
//    'chof'=>'validate',
  );
  //TODO check length of url
  //~350 for everything except chd...

  foreach($chart as $k => $c){
    $url .= htmlentities("&".$k."=".$c);
    //$url .= "&".$k."=".urlencode($c);
//    $url .= "&".$k."=".$c;
  }

  return $url;
}

?>
