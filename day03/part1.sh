#!/bin/bash
source ../fetch.sh
lines=( $(fetch 3 | tr -d ' ') )

# First, we need to remove formatting on our line
function unformat() {
  echo $(echo "$1" | tr '#@:x,' ' ') # Second echo removes extra whitespace
};

# Now our line is: id x y w h

# Now we create our 1.5-dimensional playground
declare -A matx
icount=0

for l in "${lines[@]}"; do
  data=($(unformat $l))
  # Index 0 is ID
  x0=${data[1]}
  y0=${data[2]}
  x1=$(( $x0 + ${data[3]} ))
  y1=$(( $y0 + ${data[4]} ))
  for ((x = x0; x < x1; x++ )); do
    for ((y = y0; y < y1; y++ )); do
      if [ "0${matx[$x,$y]}" -eq 1 ]; then
        matx[$x,$y]=2
        icount=$((icount+1))
      elif [ "0${matx[$x,$y]}" -ne 2 ]; then
        matx[$x,$y]=1
      fi
    done
  done

  echo "Intersections: $icount"
done
