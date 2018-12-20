#!/bin/bash
source ../fetch.sh

declare -A rules
declare -A plants
declare -A nplants

i=0
while read line; do
  if [ $i -eq 0 ]; then
    init_state=$(echo $line | awk '{print $3}' | tr '.#' '01')
    echo $init_state
  elif [ $i -ge 2 ]; then
    inp=$(echo $line | awk '{print $1}' | tr '.#' '01')
    res=$(echo $line | awk '{print $3}' | tr '.#' '01')
    rules[$inp]=$res
    echo "$inp -> $res"
  fi
  (( i++ ))
done << EOF
$(fetch 12)
EOF

i=0
min_check=-3
max_check=$(( ${#init_state} + 3 ))
num_plants=0
for v in $(echo $init_state | sed 's/\(.\)/\1 /g'); do
  plants[$i]=$v
  (( i++ ))
done

for (( iter = 0; iter <= 20; iter++ )); do
  printf "%2d: " $iter
  num_plants=0
  for (( i = $min_check; i < $max_check; i++ )); do
    if [ -z "${plants[$i]}" ]; then
      echo -n '.'
    else
      echo -n $(echo "${plants[$i]}" | tr '01' '.#')
      if [ ${plants[$i]} = 1 ]; then
        (( num_plants += i ))
      fi
    fi
  done
  echo " -- $num_plants"
  # echo "Iterating from $min_check to $max_check"
  for (( c = min_check; c <= max_check; c++ )); do
    state=
    for (( j = c - 2; j <= c + 2; j++ )); do
      if [ "${plants[$j]}" = "1" ]; then
        state+=1
      else
        state+=0
      fi
    done
    nplants[$c]=${rules[$state]}
    if [ -z "${nplants[$c]}" ]; then
      nplants[$c]=0
    fi
    if [ "${nplants[$c]}" = "1" ]; then
      if [ $((c - 3)) -lt $min_check ]; then
        min_check=$((c - 3))
        # echo "Increase minimum to $min_check"
      elif [ $((c + 3)) -gt $max_check ]; then
        max_check=$((c + 3))
        # echo "Increase maximum to $max_check"
      fi
    fi
  done

  for ((i = $min_check; i <= $max_check; i++)); do
    plants[$i]=${nplants[$i]}
  done

done
echo $num_plants
