first = system("head -1 gasometerDaily.csv | awk '{print $1}' FS=,")
last = system("tail -1 gasometerDaily.csv | awk '{print $1}' FS=,")

set fit quiet
set fit logfile '/dev/null'
set macros
set terminal pngcairo size 800,480
set datafile separator ","
set yrange [0:]
set format y "%.fkWh"
set ytics ( "0kWh" 0, "10kWh" 10000, "20kWh" 20000, "30kWh" 30000, "40kWh" 40000, "50kWh" 50000, "60kWh" 60000, "70kWh" 70000, "80kWh" 80000, "90kWh" 90000)
set encoding utf8
set output 'gasometer.png'
set timefmt "%s"
set autoscale xfix
set format x "%b'%y"
set grid ytics lc rgb "black" lw 1 lt 0 front
set grid xtics lc rgb "black" lw 1 lt 0 front

oneyear="< tail -365 gasometerDaily.csv"
stats oneyear using 2 nooutput
last_kWha = STATS_sum

oneyear="< head -365 gasometerDaily.csv"
stats oneyear using 2 nooutput
first_kWha = STATS_sum

messwerte="< cat gasometerDaily.csv"
today = system("tail -n 1 gasometerDaily.csv | cut -d, -f 2") + 0.0

stats messwerte using 2 name "Y_" nooutput
stats messwerte using 2 name "power" nooutput

stats messwerte using (timecolumn(1)) every ::Y_index_min::Y_index_min nooutput
X_min = STATS_min
stats messwerte using (timecolumn(1)) every ::Y_index_max::Y_index_max nooutput
X_max = STATS_max

# must be define AFTER statistic functions
set xdata time

##############################################################################
# average function over N sample points
##############################################################################
# number of points in moving average
n = 14

# initialize the variables
do for [i=1:n] {
    eval(sprintf("back%d=0", i))
}

# build shift function (back_n = back_n-1, ..., back1=x)
shift = "("
do for [i=n:2:-1] {
    shift = sprintf("%sback%d = back%d, ", shift, i, i-1)
} 
shift = shift."back1 = x)"
# uncomment the next line for a check
# print shift

# build sum function (back1 + ... + backn)
sum = "(back1"
do for [i=2:n] {
    sum = sprintf("%s+back%d", sum, i)
}
sum = sum.")"
# uncomment the next line for a check
# print sum

# define the functions like in the gnuplot demo
# use macro expansion for turning the strings into real functions
samples(x) = $0 > (n-1) ? n : ($0+1)
avg_n(x) = (shift_n(x), @sum/samples($0))
shift_n(x) = @shift
##############################################################################

belowMax = ((today * 100) / Y_max) - 100
aboveMin = ((today * 100) / Y_min) - 100
ofAvg    = ((today * 100) / power_mean)

set title sprintf("today %.1f%% overMin, %.1f%% underMax and %.1f%% ofAvg", aboveMin, belowMax, ofAvg)

set label sprintf("%.f kWh/a", first_kWha/1000) left at graph 0.001, graph 0.04
set label sprintf("%.f kWh/a", last_kWha/1000) right at graph 0.999, graph 0.04

set label sprintf("%.2f kWh (%.f W)", (Y_min/1000), (Y_min/24)) center at first X_min,Y_min point pt 7 ps 1 offset 0,-1
set label sprintf("%.2f kWh (%.f W)", (Y_max/1000), (Y_max/24)) center at first X_max,Y_max point pt 7 ps 1 offset 0,0.5
plot (power_mean+power_stddev) notitle with filledcurves y1=(power_mean-power_stddev) lt 1 lc rgb "light-grey", \
     today title sprintf("today %.2f kWh (%.f W)", (today/1000), (today/24)) with lines dashtype 2 lw 1 lc rgb "black", \
     power_mean title sprintf("avg. %.2f kWh (%.f W)", (power_mean/1000), (power_mean/24)) with lines lw 2 lc rgb "red", \
     messwerte using 1:2 notitle lw 1 lc "blue" with lines, \
     messwerte using 1:(avg_n($2)) with lines lw 2 lc rgb "dark-red" title sprintf("%d days average",n)

