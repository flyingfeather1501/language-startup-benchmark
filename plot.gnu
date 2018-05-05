# vim: ft=gnuplot
set terminal qt size 1024,768
set xlabel "Language"
set ylabel "Startup Time (seconds)"
set title "Startup time for various languages"
set yrange [0:1]

set xtics border in scale 1,0.5 nomirror rotate by -45 offset character 0, 0, 0
set ytics 0.1
set y2tics 0.1
# set grid y

set style fill solid
# set style histogram rowstacked
# set style data histograms

plot "_reports/data.dat" using 1:xtic(2) with histogram, \
  "" using 0:($1+.05):(sprintf("%3.3f",$1)) with labels notitle
