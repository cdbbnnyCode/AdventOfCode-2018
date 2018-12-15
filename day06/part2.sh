#!/bin/bash
source ../fetch.sh

input=( $(fetch 6 | tr -d ' ' ) ) # Items separated by comma and space

function distance() {
  local p1=( $(echo $1 | tr ',' ' ') )
  local p2=( $(echo $2 | tr ',' ' ') )
  if [ ${p1[0]} -lt ${p2[0]} ]; then
    local x1=${p1[0]}
    local x2=${p2[0]}
  else
    local x1=${p2[0]}
    local x2=${p1[0]}
  fi
  if [ ${p1[1]} -lt ${p2[1]} ]; then
    local y1=${p1[1]}
    local y2=${p2[1]}
  else
    local y1=${p2[1]}
    local y2=${p1[1]}
  fi
  echo $(( $y2 - $y1 + $x2 - $x1 ))
}

function distanceToAll() {
  local in_pt="$1,$2"
  local sum=0
  for coord in ${input[@]}; do
    (( sum += $(distance $in_pt $coord) ))
    if [ $sum -ge 10000 ]; then
      break
    fi
  done
  echo $sum
}

area=0
min_x=400
max_x=0
min_y=400
max_y=0

for coord in ${input[@]}; do
  x=$(echo $coord | cut -d ',' -f 1)
  y=$(echo $coord | cut -d ',' -f 2)
  if [ $x -lt $min_x ]; then
    min_x=$x
  elif [ $x -gt $max_x ]; then
    max_x=$x
  fi
  if [ $y -lt $min_y ]; then
    min_y=$y
  elif [ $y -gt $max_y ]; then
    max_y=$y
  fi
done

echo "Checking rectangle ($min_x,$min_y) - ($max_x,$max_y)"

checked=0
total=$(( (max_x - min_x + 1) * (max_y - min_y + 1) ))
for (( x = $min_x; x <= $max_x; x++ )); do
  for (( y = $min_y; y < $max_y; y++ )); do
    dist=$(distanceToAll $x $y)
    if [ $dist -lt 10000 ]; then
      ((area += 1))
    fi
    ((checked += 1))
    percent=$(( checked * 100 / total ))
    printf "Checked: %6d (%3d%%), area: %6d; distance=%5d\r" $checked $percent $area $dist
  done
done
