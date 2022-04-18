<?php
  exec('/usr/bin/bash /home/pi/gasometer/refresh.sh', $output, $retval);
  echo "REFRESH returned $retval and says: ";
  print_r($output);
?>
<html>
  <head>
    <meta http-equiv="refresh" content="123">
    <title>Energieverbrauch</title>
  </head>
  <body>
    <img src=gasometerToday.png>
    <img src=todaysPower.png>
    <img src=gasometer.png>
    <img src=daily.png>
  </body>
</html>

