<?php
  exec('/usr/bin/bash /home/pi/gasometer/refresh.sh', $output, $retval);
  echo "REFRESH returned $retval and says: ";
  print_r($output);
?>
<html>
  <head>
    <meta http-equiv="refresh" content="123">
    <title>Gasverbrauch</title>
  </head>
  <body>
    <img src=gasometerToday.png>
    <h1>gesamter Gasverbrauch</h1>
    <img src=gasometer.png>
  </body>
</html>

