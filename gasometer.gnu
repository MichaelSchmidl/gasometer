first = system("head -1 gasometerDaily.csv | awk '{print $1}' FS=,")
last = system("tail -1 gasometerDaily.csv | awk '{print $1}' FS=,")

set fit quiet
set fit logfile '/dev/null'
set macros
set terminal pngcairo size 800,480
set output 'gasometer.png'
set datafile separator ","
set format y "%.fkWh"
set ytics scale 0.2
set encoding utf8
set timefmt "%s"
set autoscale xfix
set format x "%b'%y"
set grid ytics lc rgb "black" lw 1 lt 0 front
set grid xtics lc rgb "black" lw 1 lt 0 front

oneyear="< tail -365 gasometerDaily.csv"
stats oneyear using 5 nooutput
last_kWha = STATS_sum

oneyear="< head -365 gasometerDaily.csv"
stats oneyear using 5 nooutput
first_kWha = STATS_sum

messwerte="< cat gasometerDaily.csv"
today = system("tail -n 1 gasometerDaily.csv | cut -d, -f 5") + 0.0
todayGas = system("tail -n 1 gasometerDaily.csv | cut -d, -f 2") + 0.0
todayStrom = system("tail -n 1 gasometerDaily.csv | cut -d, -f 4") + 0.0
todayPercentGas = (todayGas * 100) / (todayStrom + todayGas) 
todayPercentStrom = (todayStrom * 100) / (todayStrom + todayGas) 

# calulcate percentage of strom and gas
stats messwerte using 2 nooutput
numberOfDays = STATS_records
total_gas_kWh = STATS_sum
stats messwerte using 4 nooutput
total_strom_kWh = STATS_sum
strom_max = STATS_max
total_gas_percent = (total_gas_kWh * 100) / (total_gas_kWh + total_strom_kWh) 
total_strom_percent = (total_strom_kWh * 100) / (total_gas_kWh + total_strom_kWh) 

# min/max calculation
stats messwerte using 5 name "power" nooutput
stats messwerte using 5 name "Y_" nooutput
stats messwerte using (timecolumn(1)) every ::Y_index_min::Y_index_min nooutput
X_min = STATS_min
stats messwerte using (timecolumn(1)) every ::Y_index_max::Y_index_max nooutput
X_max = STATS_max

# must be define AFTER statistic functions
set xdata time

# define Y range
set yrange [0:Y_max/1000*1.20]

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

set title sprintf("Total Energy Consumption (%.1f%% Strom, %.1f%% Gas)\ntoday %.1f%% overMin, %.1f%% underMax and %.1f%% ofAvg (%.1f%% Strom, %.1f%% Gas)", total_strom_percent, total_gas_percent, aboveMin, belowMax, ofAvg, todayPercentStrom, todayPercentGas)

expectedKWa = ((total_gas_kWh + total_strom_kWh)*365)/numberOfDays
percentExpectedKWa = (expectedKWa * 100) / 17678000
set label sprintf("FCST: %.1f MWh/a\n%.f%% of avg household", expectedKWa/1000/1000, percentExpectedKWa) left at graph 0.02, graph 0.955
set label sprintf("%.1f MWh/a", first_kWha/1000/1000) left at graph 0.001, first strom_max/1000 offset 0,0.4
set label sprintf("%.1f MWh/a", last_kWha/1000/1000) right at graph 0.999, first strom_max/1000 offset 0,0.4
set label sprintf("%.1f kWh (%.f W)", (Y_min/1000), (Y_min/24)) center at first X_min,Y_min/1000 point pt 7 ps 1 offset 0,-0.8
set label sprintf("%.1f kWh (%.f W)", (Y_max/1000), (Y_max/24)) center at first X_max,Y_max/1000 point pt 7 ps 1 offset 0,0.3

set style histogram rowstacked
set style fill transparent solid 0.25 

plot today/1000 title sprintf("today %.1f kWh (%.f W)", (today/1000), (today/24)) with lines dashtype 2 lw 1 lc rgb "black", \
     power_mean/1000 title sprintf("avg. %.1f kWh (%.f W)", (power_mean/1000), (power_mean/24)) with lines lw 2 lc rgb "red", \
     messwerte using 1:($5/1000) notitle lw 3 lc "dark-blue" with histeps, \
     messwerte using 1:($4/1000) notitle lw 1 lc "blue" with histeps, \
     messwerte using 1:(avg_n($5/1000)) with lines lw 2 lc rgb "dark-red" notitle

