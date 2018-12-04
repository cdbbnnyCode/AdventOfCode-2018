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
declare -a noint

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
      elif [ "${matx[$x,$y]}" != "y" ]; then
        matx[$x,$y]=$id
      fi
    done
  done

  echo "Intersections: $icount"
  if [ $icount -eq 0 ]; then
    echo "Has no intersections (for now)"
    noint[$id]=1
  fi
done

echo ${!noint[@]}
