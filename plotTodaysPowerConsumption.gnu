set fit quiet
set fit logfile '/dev/null'
set macros
set terminal pngcairo size 800,480
set datafile separator ","
set yrange [0:]
set format y "%.fW"
set format x "%H:%M"
set encoding utf8
set output 'todaysPower.png'
set timefmt "%H:%M:%S"
set grid ytics lc rgb "black" lw 1 lt 0 front
set grid xtics lc rgb "black" lw 1 lt 0 front

messwerte="< cat todaysPowerData.csv"
now = system("tail -n 1 todaysPowerData.csv | cut -d, -f 2") + 0.0

stats messwerte using 2 name "Y_" nooutput
stats messwerte using (timecolumn(1)) every ::Y_index_min::Y_index_min nooutput
X_min = STATS_min
stats messwerte using (timecolumn(1)) every ::Y_index_max::Y_index_max nooutput
X_max = STATS_max

set yrange [0:Y_max*1.15]

# must be define AFTER statistic functions
set xdata time
set autoscale xfix

# set min/max marker with their value
set label sprintf("%.fW", Y_min) center at first X_min,Y_min point pt 7 ps 1 offset 0,0.4
set label sprintf("%.fW", Y_max) center at first X_max,Y_max point pt 7 ps 1 offset 0,0.4

# set title with accumulated electrical energie consumption so far
sofarkWh= system("smartpick/smartpick.py smartpi.local") + 0.0
set title sprintf("today %.2f kWh electrical energy so far", sofarkWh)

plot now title sprintf("now %.f W", now) with lines dashtype 2 lw 1 lc rgb "black", \
          messwerte using 1:2 notitle lw 2 lc "blue" with lines

