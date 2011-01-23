<?php
  $x = $_GET['x'];

  $title = "Temperature";

  include('credentials.php');

  $NUMDATES = 8;
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

    switch($x){
      case 'm':
        $interval = '1 month';
        $numdates = 8;
      break;
      case 'w':
        $interval = '1 week';
        $numdates = 7;
      break;
      case 'd':
      default:
        $interval = '1 day';
        $numdates = 8;
    }
    $title .= " ($interval)";

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

    if (!$result) {
      $title = "error";
    }else{
      $numrows = pg_num_rows($result);
      $datestep = $numrows / $numdates;
      $plotstep = ceil($numrows / $NUMPLOTS);
      
      $i = 0;
      while($row = pg_fetch_array($result)){
        if(($i % $plotstep)==0){
          if($row['temp'] > $max){
            $max = $row['temp'];
          }
          if($row['temp'] < $min){
            $min = $row['temp'];
          }
          $chd .= $row['temp'] . ',';
        }
        
        if(($i % $datestep)==0){
          $datelabels[] = $row['ts'];
        }
        $lastrow = $row;
        $i++;
      }
      //$chd .= $lastrow['temp'];
    }
    
    $chd = substr($chd, 0, -1);
    /*
      $result = pg_query($dbh, "        
        SELECT 
          date_trunc('day', ts)as ts,
          round(avg(temp),1) as temp 
        FROM 
          log 
        GROUP BY 
          date_trunc('day', ts) 
        ORDER BY
          ts DESC
        LIMIT 1;
      ");
      
      if (!$result) {
        echo "error";
      }else{
        $chd .= '|';
        while($row = pg_fetch_array($result)){
          //echo $row['temp'];
          $chd .= $row['temp'] . ',';
        }
        $chd = substr($chd, 0, -1);        
      }
    */
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
    'chco'=> '7D26CD|00ffFF',
//    'chls'=> '1|1',
//    'chdl'=> 'Temp|Avg',
//    'chof'=>'validate',
  );
  //TODO check length of url
  //~350 for everything except chd...

  foreach($chart as $k => $c){
//    $url .= "&".$k."=".urlencode($c);
    $url .= "&".$k."=".$c;
  }
  
  //error_log("strlen(url): ".strlen($url));

  header('Location: '.$url);
  die;

/*
  // Send the request, and print out the returned bytes.
  header('content-type: image/png');
  $context = stream_context_create(
    array('http' => array(
      'method'  => 'POST',
      'header'  => "Content-Type: application/x-www-form-urlencoded\r\n",
      'content' => http_build_query($chart))));
  fpassthru(fopen($url, 'r', false, $context));
*/
?>
