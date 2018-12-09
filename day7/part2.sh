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

declare -A delays
i=61
for l in ${letters[@]}; do
  delays[$l]=$i
  (( i += 1 ))
done

remaining=( ${!allsteps[@]} )
has=( )
elapsed=0
workers=( 0 0 0 0 0 )
tasks=( )

while [ ${#remaining[@]} -gt 0 -o ${#tasks[@]} -gt 0 ]; do
  echo "Time: ${elapsed}s"
  for ltr in ${remaining[@]}; do
    depstring=$(echo ${deps[$ltr]} | tr ',' $'\n')
    compstring=$(echo ${has[@]} | tr ' ' $'\n')
    depend=( $(comm -23 <(echo "$depstring" | sort) <(echo "$compstring" | sort)) )
    if [ ${#depend[@]} -eq 0 ]; then
      echo "  $ltr available for processing"
      for wid in ${!workers[@]}; do
        if [ ${workers[$wid]} -eq 0 ]; then
          echo "    Dispatching $ltr to worker $wid"
          tasks[$wid]=$ltr
          workers[$wid]=${delays[$ltr]}

          remaining=( "${remaining[@]/$ltr}" )
          remaining=( ${remaining[@]} )
          break
        fi
      done
    fi
  done
  echo "  Remaining: ${remaining[@]}"
  for wid in ${!workers[@]}; do
    if [ ${workers[$wid]} -gt 0 ]; then
      (( workers[$wid] -= 1 ))
    fi
    if [ ${workers[$wid]} -le 0 ]; then
      if [ -n "${tasks[$wid]}" ]; then
        echo "  Worker $wid completed task ${tasks[$wid]}"
        has+=( ${tasks[$wid]} )
        unset tasks[$wid]
      fi
    fi
  done
  (( elapsed += 1 ))
  sleep .1
done

echo "$elapsed seconds total"
