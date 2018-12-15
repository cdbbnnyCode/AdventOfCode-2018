#!/bin/bash

# If you want to try out visual debugging, uncomment lines 20, 51-52, and 56-63
# Please be warned, though, that debugging is very laggy and requires ImageMagick to work!

source ../fetch.sh
lines=( $(fetch 3 | tr -d ' ') )

# First, we need to remove formatting on our line
function unformat() {
  echo $(echo "$1" | tr '#@:x,' ' ') # Second echo removes extra whitespace
};

# Now our line is: id x y w h

# Now we create our 1.5-dimensional playground
declare -A matx
declare -a noint
# Init our debugging canvas
# convert -size 1000x1000 xc:white image.png

for l in "${lines[@]}"; do
  data=($(unformat $l))
  # Index 0 is ID
  id=${data[0]}
  x0=${data[1]}
  y0=${data[2]}
  x1=$(( $x0 + ${data[3]} ))
  y1=$(( $y0 + ${data[4]} ))
  icount=0
  for ((x = x0; x < x1; x++ )); do
    for ((y = y0; y < y1; y++ )); do
      if [ -n "${matx[$x,$y]}" -a "${matx[$x,$y]}" != "y" ]; then
        unset noint[${matx[$x,$y]}]
        matx[$x,$y]="y"
        icount=$((icount+1))
      elif [ -z "${matx[$x,$y]}" ]; then
        matx[$x,$y]=$id
      else # It's definitely 'y' now
        icount=$((icount+1))
      fi
    done
  done

  echo "Intersections: $icount"
  if [ $icount -eq 0 ]; then
    echo "Has no intersections (for now)"
    noint[$id]=$(echo "${data[@]}" | tr ' ' '_')
  fi
  # Massively laggy visual debugging with ImageMagick; feel free to try it out!
#  color="rgb($(($RANDOM % 64 + 127)),$(($RANDOM % 64 + 127)),$(($RANDOM % 64 + 127)))"
#  convert image.png -fill "$color" -draw "rectangle $x0,$y0 $x1,$y1" image.png
done

echo ${!noint[@]}
# for v in ${noint[@]}; do
#   data=( $(echo $v |  tr '_' ' ') )
#   x0=${data[1]}
#   y0=${data[2]}
#   x1=$(( $x0 + ${data[3]} ))
#   y1=$(( $y0 + ${data[4]} ))
#   convert image.png -fill black -draw "rectangle $x0, $y0 $x1, $y1" image.png
# done
