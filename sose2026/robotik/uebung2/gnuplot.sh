cd "$(dirname "$0")"
gnuplot -e "set terminal png size 1000,1000; set output 'B2.2.png'; plot 'odometry.txt' using 1:2 with lines title 'Odometrie Trajektorie'"
