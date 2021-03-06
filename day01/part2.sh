#!/bin/bash
source ../fetch.sh

freqs=( $(fetch 1) )
declare -A found

echo "Parsing ${#freqs[@]} values"
current=0
has=0

iter=0
while [ $has -eq 0 ]; do
  echo "Iteration $iter -- searched ${#found[@]} numbers"
  for delta in "${freqs[@]}"; do
    found[$current]=1
    prev=$current
    current=$(( $current $delta ))
    # echo "Current: $prev, delta: $delta, result: $current"
    if [ -n "${found[$current]}" ]; then
      echo "$current found twice!"
      has=1
      break
    fi
  done
  iter=$((iter+1))
done
