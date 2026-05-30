#!/bin/bash
# =============================================================================
# Erzeugt die Abbildungen der Ausarbeitung aus den Mess-CSVs (gnuplot).
# Wird vor latex_comp.sh aufgerufen, damit die PDFs aktuell sind.
# =============================================================================

DIR="$(cd "$(dirname "$0")" && pwd)"
CASES="$DIR/../sammelsorium/cases"
OUT="$DIR/assets/img"
mkdir -p "$OUT"

CSV2="$CASES/case2_ram_disk_spof/results/case2_disk_usage_timeseries.csv"
CSV3="$CASES/case3_log_queue_cascade/results/queue_depth_timeseries.csv"

echo "[1/2] Case 2 – Bildspeicher Images/Out über die Zeit..."
gnuplot <<EOF
set terminal pdfcairo size 13cm,7cm font "Linux Libertine,11"
set output "$OUT/case2_image_out_usage.pdf"
set datafile separator ","
set key off
set grid ytics lc rgb "#dddddd"
set border 3
set tics nomirror
set xlabel "Zeit seit Messbeginn [s]"
set ylabel "Images/Out Belegung [MB]"
set xrange [0:47]
# Spalte 4 (images_out_mb); Header-Zeile via 'every ::1' überspringen
plot "$CSV2" every ::1 using 1:4 with lines lw 2 lc rgb "#1f4e79"
EOF

echo "[2/2] Case 3 – Queue-Tiefe über die Zeit (mit Freeze-Fenster)..."
gnuplot <<EOF
set terminal pdfcairo size 13cm,7cm font "Linux Libertine,11"
set output "$OUT/case3_queue_depth.pdf"
set datafile separator ","
set key off
set grid ytics lc rgb "#dddddd"
set border 3
set tics nomirror
set xlabel "Zeit seit Messbeginn [s]"
set ylabel "Queue-Tiefe (qsize)"
set xrange [0:47]
set yrange [0:8]
# Freeze-Fenster (LoggerProcess via SIGSTOP angehalten): ca. 9.6 s bis 40 s.
# In diesem Bereich pausiert der Monitoring-Thread mit, daher keine Messpunkte.
set object 1 rect from 9.6,0 to 40,8 fc rgb "#f2c0c0" fs solid 0.5 noborder behind
set label 1 "LoggerProcess eingefroren\n(qsize {/Symbol \273} 1000, inferiert)" \
    at 24.8,5.6 center font "Linux Libertine,9" tc rgb "#902020"
set arrow 1 from 9.6,4.6 to 9.6,0.2 lc rgb "#902020" lw 1
set arrow 2 from 40,4.6 to 40,0.2 lc rgb "#902020" lw 1
# Impulse statt Linie: keine irreführende Überbrückung der Messlücke im Freeze.
plot "$CSV3" every ::1 using 1:3 with impulses lw 1.5 lc rgb "#1f4e79", \
     "$CSV3" every ::1 using 1:3 with points pt 7 ps 0.3 lc rgb "#1f4e79"
EOF

echo "Fertig. Abbildungen in $OUT/"
ls -la "$OUT"/*.pdf
