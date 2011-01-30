<?php header('Content-Type: text/xml'); ?>
<?php include('lib.php'); ?>
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="http://sodnpoo.com/sodnpoo.xsl"?>
<xml>
<post>
  <title>weathoscope</title>
  <date><?php echo date("d M Y"); ?></date>
  <p>
  <span class="header">Current temperature: <?php echo getAvgTempAPC('1 hour'); ?> &#176;C</span>
  </p>
  <image src="<?php echo buildTempGraphAPC('1 day', 8, 'Temperature'); ?>"/>
  <p>
  </p>
  <image src="<?php echo buildTempGraphAPC('1 week', 7, 'Temperature'); ?>"/>
  <p>
  </p>
  <image src="<?php echo buildTempGraphAPC('1 month', 8, 'Temperature'); ?>"/>
  <p>
  </p>
</post>
</xml>

