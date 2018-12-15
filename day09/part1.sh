#!/bin/bash
source ../fetch.sh

input=( $(fetch 9 | awk '{print $1" "$7}') )
input=( 9 25 )
# (( input[1] /= 10 ))
echo "${input[@]}"

marbles=( 0 )
nm=1
scores=( )
current=0 # Index of current item
elf=0

for i in $(seq 0 ${input[1]}); do
  (( elf = $elf % ${input[0]} + 1 ))

  marble=$(( i+1 ))
  if [[ $(( $marble % 23 )) = 0 ]]; then
    current=$(( (current - 7 < 0) ? nm + (current-7) : current-7 ))
    (( scores[$elf] += $marble + ${marbles[$current]} ))
    unset marbles[$current]
    (( nm -= 1 ))
    marbles=( ${marbles[@]} )
  else
    (( current = ($current + 1) % $nm + 1 ))
    (( nm += 1 ))
    marbles=( ${marbles[@]:0:$current} $marble ${marbles[@]:$current} )
  fi
done

echo "${scores[@]}" | tr ' ' $'\n' | sort -r
