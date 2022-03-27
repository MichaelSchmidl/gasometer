#!/bin/bash
TIMESTAMP_FILE=gasometerTimestamps.csv
TODAY_FILE=gasometerToday.csv
PNG_FILE=gasometerToday.png

cd /home/pi/gasometer
date
#pwd
#touch php_ran

#########################################################
# database for todays data
if [ ! -e $TODAY_FILE ]; then
   ./createTodaysGasometerData $TIMESTAMP_FILE >$TODAY_FILE
   printf "recreated CSV\n"
fi

srcTime=$(stat -c %Y $TIMESTAMP_FILE)
dstTime=$(stat -c %Y $TODAY_FILE)
#printf "src=%d dst=%d\n" $srcTime $dstTime
if [ $srcTime -gt $dstTime ]; then
   ./createTodaysGasometerData $TIMESTAMP_FILE >$TODAY_FILE
   printf "new data\n"
fi

########################################################
# graphic for todays data
if [ ! -e $PNG_FILE ]; then
   gnuplot gasometerToday.gnu
   printf "recreated graphic\n"
fi

srcTime=$(stat -c %Y $TODAY_FILE)
dstTime=$(stat -c %Y $PNG_FILE)
if [ $srcTime -gt $dstTime ]; then
   gnuplot gasometerToday.gnu
   printf "new graphic\n"
fi

exit 0
