set fit quiet
set fit logfile '/dev/null'
set macros
set terminal pngcairo size 800,480
set datafile separator ","
set format y "%.fkW"
set encoding utf8
set output 'gasometerToday.png'
set timefmt "%s"

messwerte="< cat gasometerToday.csv"
today = system("tail -n 1 gasometerToday.csv | cut -d, -f 2") + 0.0
todayWh = system("tail -1 gasometerToday.csv | awk '{print $3}' FS=,")

stats messwerte using 2 nooutput
set yrange [0:STATS_max/1000*1.1]

set xdata time
set autoscale xfix
set format x "%H:%M"
set grid ytics lc rgb "black" lw 1 lt 0 front
set grid xtics lc rgb "black" lw 1 lt 0 front

set title sprintf("today %.2f kWh heat energy so far", todayWh/1000)

plot today/1000 title sprintf("now %.2f kW", (today/1000)) with lines dashtype 2 lw 1 lc rgb "black", \
     messwerte using 1:($2/1000) notitle lw 2 lc "blue" with lines
#     messwerte using 1:($2/1000) notitle lw 1 lc "black" with p, \
#     messwerte using 1:($2/1000) notitle lw 1 lc "blue" with histeps
