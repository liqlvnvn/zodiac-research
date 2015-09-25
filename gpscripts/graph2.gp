cd "data"
set terminal png
set key off
set output "graph2.png"
set title "Distribution of actors by their second sign of the zodiac"
plot [] [11000:14000] "data2.txt" using 2:xtic(1) with linespoints
