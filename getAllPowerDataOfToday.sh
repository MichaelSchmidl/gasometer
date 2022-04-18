#!/bin/bash

today=$(date +%Y-%m-%d)
curl -s http://smartpi.local:1080/api/chart/1/power/from/${today}T00:00:00.000Z/to/${today}T23:59:59.000Z  | sed s/},{/\\n/g | sed s/\"time\":\"//g | sed s/\"value\"://g | tr -d \" | tr T , | tr - . | tr + , | awk '{print $2","$4}' FS=, | tr -d "}]" | tail -n +2 > todaysPowerData.csv
gnuplot plotTodaysPowerConsumption.gnu
