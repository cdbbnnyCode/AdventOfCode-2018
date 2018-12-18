#!/bin/bash
source ../fetch.sh

input=$(fetch 11)

echo "Grid serial number: $input"

# Power level = hundereds( ((x + 10) * y + sn) * (x + 10) ) - 5
# Range: -5..4
# 300 * 300 = 90000
declare -A grid
declare -A totals
maxtotal=-999999
maxcoord=0,0,0

function draw() {
  (
    echo "# ImageMagick pixel enumeration: 298,298,255,rgb"
    for (( x = 1; x <= 298; x++ )); do
      for (( y = 1; y <= 298; y++ )); do
        printf "Drawing -- x=%03d, y=%03d\r" $x $y >&2
        val=${totals[$x,$y]}
        if [ $val -lt 0 ]; then
          color="($((-val * 8)),0,0)"
        else
          color="(0,0,$((val * 8)))"
        fi
        echo "$((x-1)),$((y-1)): $color"
      done
    done
  ) | convert txt:- totals_.png
}

for (( x = 0; x < 300; x++ )); do
  for (( y = 0; y < 300; y++ )); do
    printf "x=%03d, y=%03d\r" $x $y
    val=$(( ((x + 11) * (y + 1) + $input) * (x + 11) ))
    hdr=0${val:(-3):(-2)}
    grid[$x,$y]=$((10#$hdr - 5))
  done
done

for (( n = 1; n <= 300; n++ )); do
  for (( x = 1; x <= $((300-n+1)); x++ )); do
    total=0
    printf "Totaling... x=%03d, y=%03d, n=%03d\r" $x $y $n
    for (( y = 1; y <= $((300-n+1)); y++ )); do
      if [ $n -eq 1 ]; then
        totals[$x,$y]=${grid[$((x-1)),$((y-1))]}
      else
        dx=$((n-1))
        for (( dy = 0; dy < $n; dy++ )); do
          (( totals[$x,$y] += ${grid[$((x+dx-1)),$((y+dy-1))]} ))
          [ $dy -ne $dx ] && (( totals[$x,$y] += ${grid[$((x+dy-1)),$((y+dx-1))]} ))
        done
      fi
      total=${totals[$x,$y]}
      if [ $total -gt $maxtotal ]; then
        echo -ne "\r$total ($x,$y,$n) is the current maximum                       \n"
        maxtotal=$total
        maxcoord=$x,$y,$n
      fi
    done
  done
done
echo
echo $maxtotal -- $maxcoord
