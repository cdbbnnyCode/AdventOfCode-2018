#!/bin/bash
source ../fetch.sh

input=( $(fetch 7 | awk '{print $2$8}') )

letters=( {A..Z} )

declare -A deps
declare -A allsteps

for v in ${input[@]}; do
  step=${v:1:2}
  req=${v:0:1}
  echo "$req is required by $step"
  deps[$step]=${deps[$step]}$req,
  allsteps[$step]=1
  allsteps[$req]=1
done

remaining=( ${!allsteps[@]} )
has=( )

while [ ${#remaining[@]} -gt 0 ]; do
  for ltr in ${remaining[@]}; do
    depstring=$(echo ${deps[$ltr]} | tr ',' $'\n')
    compstring=$(echo ${has[@]} | tr ' ' $'\n')
    depend=( $(comm -23 <(echo "$depstring" | sort) <(echo "$compstring" | sort)) )
    echo "$ltr: ${depend[@]}"
    if [ ${#depend[@]} -eq 0 ]; then
      echo "  Doing $ltr"
      has+=( $ltr )
      remaining=( "${remaining[@]/$ltr}" )
      remaining=( ${remaining[@]} )
      break
    fi
  done
  echo "Remaining: ${#remaining[@]}"
done

echo "${has[@]}" | tr -d ' '
