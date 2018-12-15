#!/bin/bash

source ../fetch.sh

items=( $(fetch 2) )
has2=0
has3=0

for id in "${items[@]}"; do
  declare -A ltrcounts
#  echo "$id"
  chars=( $(echo $id | sed 's/\(.\)/\1 /g') )
  for char in "${chars[@]}"; do
    ltrcounts[$char]=$(( ${ltrcounts[$char]} + 1 ))
  done

  for c in "${ltrcounts[@]}"; do
    if [ "$c" -eq 2 ]; then
      echo "$id has 2 of the same letters"
      has2=$(( $has2 + 1 ))
      break
    fi
  done

  for c in "${ltrcounts[@]}"; do
    if [ "$c" -eq 3 ]; then
      echo "$id has 3 of the same letters"
      has3=$(( $has3 + 1 ))
      break
    fi
  done
  unset ltrcounts
done

echo "$has2 IDs have 2 repeats"
echo "$has3 IDs have 3 repeats"
echo "Checksum: $(( $has2 * $has3 ))"
