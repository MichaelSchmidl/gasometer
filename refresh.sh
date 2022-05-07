#!/bin/bash
TIMESTAMP_FILE=gasometerTimestamps.csv
TODAY_FILE=gasometerToday.csv
PNG_FILE=gasometerToday.png

cd /home/pi/gasometer
date
#pwd
#touch php_ran
sudo chmod 666 *.png
sudo chmod 666 *.csv


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


########################################################
# graphic for todays electrical power consumption
today=$(date +%Y-%m-%d)
curl -s http://smartpi.local:1080/api/chart/1/power/from/${today}T00:00:00.000Z/to/${today}T23:59:59.000Z  | sed s/},{/\\n/g | sed s/\"time\":\"//g | sed s/\"value\"://g | tr -d \" | tr T , | tr - . | tr + , | awk '{print $2","$4}' FS=, | tr -d "}]" | tail -n +2 > todaysPowerData.csv
gnuplot plotTodaysPowerConsumption.gnu

# log activity
date >> /home/pi/gasometer/log.txt

exit 0
