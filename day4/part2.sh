#!/bin/bash
source ../fetch.sh

inputs=( $(fetch 4 | tr ' ' '_' | sort ) )

function unformat() {
  echo "$1" | tr -d '[]#' | tr ':-' '_'
}

# 2-D array; 'd' is sleep duration, 0-59 are number of days asleep at that minute
declare -A guards
max_guard=0

echo    "Date   ID    Minute"
echo    "             000000000011111111112222222222333333333344444444445555555555"
echo -n "             012345678901234567890123456789012345678901234567890123456789"
#       11-01  1234  ....#######.......##############............................
#       0    012   012

end_min=60
for i in ${inputs[@]}; do
  data=( $(unformat $i | tr '_' ' ') )
  if [ "${data[5]}" = "Guard" ]; then
    # echo "Guard changes to ${data[6]}"

    for (( i = end_min; i < 60; i++ )); do
      echo -n '.'
    done
    echo " $guard total: ${guards[$guard,d]}"

    guard=${data[6]}
    if [ -z "${guards[$guard,d]}" ]; then
      guards[$guard,d]=0
    fi
    for (( i = 0; i < $end_min; i++ )); do
      if [ -z "${guards[$guard,$i]}" ]; then
        guards[$guard,$i]=0
      fi
    done
    if [ $guard -gt $max_guard ]; then
      max_guard=$guard
    fi
    printf '%s-%s %s:%s  %-4d  ' ${data[1]} ${data[2]} ${data[3]} ${data[4]} ${data[6]}
    end_min=0
  elif [ "${data[5]}" = "falls" ]; then
    # echo "Guard $guard falls asleep at minute ${data[4]}"
    start_min=$(echo ${data[4]} | sed 's/^0//') # Remove leading zeroes so that Bash doesn't think our numbers are octal
    for (( i = $end_min; i < $start_min; i++ )); do
      echo -n '.'
    done
  elif [ "${data[5]}" = "wakes" ]; then
    # echo "Guard $guard wakes up at minute ${data[4]}"
    end_min=$(echo ${data[4]} | sed 's/^0//')
    duration=$(( $end_min - $start_min ))
    guards[$guard,d]=$(( ${guards[$guard,d]} + $duration ))
    for (( i = $start_min; i < $end_min; i++ )); do
      guards[$guard,$i]=$(( ${guards[$guard,$i]} + 1 ))
      echo -n '#'
    done
  fi
done

for (( i = end_min; i < 60; i++ )); do
  echo -n '.'
done
echo " $guard total: ${guards[$guard,d]}"


for (( g=0; g < $max_guard; g++ )); do
  for (( i=0; i < 60; i++ )); do
    if [ -n "${guards[$g,$i]}" ]; then
      timetable=${timetable}$(printf '%02d %04d %02d' ${guards[$g,$i]} $g $i)$'\n'
    fi
  done
done

echo "$timetable" | sort -r
best_time=( $(echo "$timetable" | sort -r | head -n 1) )
echo
echo "Guard #${best_time[1]} was sleeping ${best_time[0]} times on minute ${best_time[2]}"
echo
echo "Result: $(( 10#${best_time[1]} * 10#${best_time[2]} ))"
