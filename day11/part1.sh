#!/bin/bash
source ../fetch.sh

input=$(fetch 11)

echo "Grid serial number: $input"

# Power level = hundereds( ((x + 10) * y + sn) * (x + 10) ) - 5
# Range: -5..4
# 300 * 300 = 90000
declare -A grid
declare -A totals

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
  ) | convert txt:- totals.png
}

for (( x = 0; x < 300; x++ )); do
  for (( y = 0; y < 300; y++ )); do
    printf "x=%03d, y=%03d\r" $x $y
    val=$(( ((x + 11) * (y + 1) + $input) * (x + 11) ))
    hdr=0${val:(-3):(-2)}
    grid[$x,$y]=$((10#$hdr - 5))
  done
done

for (( x = 1; x <= 298; x++ )); do
  for (( y = 1; y <= 298; y++ )); do
    printf "Totaling... x=%03d, y=%03d\r" $x $y
    totals[$x,$y]=0
    for (( xx = 0; xx < 3; xx++ )); do
      for (( yy = 0; yy < 3; yy++ )); do
        (( totals[$x,$y] += ${grid[$((x+xx-1)),$((y+yy-1))]}))
      done
    done
  done
done

draw

echo
(
  for key in ${!totals[@]}; do
    echo "${totals[$key]} <- $key"
  done
) | sort -rn | head -n 20
