#!/bin/bash
source ../fetch.sh

input=( $(fetch 10 | tr -d 'a-uw-z=<> ' | tr 'v' ',') )

points=( $(echo ${input[@]} | tr ' ' $'\n' | awk -F ',' '{print $1","$2}') )
speeds=( $(echo ${input[@]} | tr ' ' $'\n' | awk -F ',' '{print $3","$4}') )

echo ${points[@]}

function draw() {
  local x_list=( $(echo ${points[@]} | tr ' ' $'\n' | awk -F ',' '{print $1}') )
  local y_list=( $(echo ${points[@]} | tr ' ' $'\n' | awk -F ',' '{print $2}') )
  xsort="$(echo ${x_list[@]} | tr ' ' $'\n' | sort -n )"
  ysort="$(echo ${y_list[@]} | tr ' ' $'\n' | sort -n )"
  x_min=$(echo "$xsort" | head -n 1)
  x_max=$(echo "$xsort" | tail -n 1)
  y_min=$(echo "$ysort" | head -n 1)
  y_max=$(echo "$ysort" | tail -n 1)
  # w / div > 400
  # div / w > 1/400
  # div > w / 400
  div=$(( (x_max - x_min)/400 + 1))
  if [ $div -eq $last_div -a $div -gt 1 ]; then echo $div; return; fi
  echo $div
  (
    echo "# ImageMagick pixel enumeration: $(( (x_max - x_min) / div + 1 )),$(((y_max - y_min) / div + 1 )),255,rgb"
    for (( i = 0; i < ${#x_list[@]}; i++ )); do
      echo "$(( (${x_list[$i]} - $x_min) / div )),$(( (${y_list[$i]} - $y_min) / div )): (0,0,0)"
    done
  ) | convert txt:- $1
}

ctr=0
last_div=0
while true; do
  div=$(draw image.png)
  if [ $div -ne $last_div -o $div -eq 1 ]; then
    last_div=$div
    echo "Div changed to $div"
    mv image.png $ctr.png
  fi
  for (( j = 0; j < ${#points[@]}; j++ )); do
    point=( $(echo ${points[$j]} | tr ',' ' ') )
    vel=( $(echo ${speeds[$j]} | tr ',' ' ') )
    (( point[0] += ${vel[0]} * $div ))
    (( point[1] += ${vel[1]} * $div ))
    points[$j]=$(echo ${point[@]} | tr ' ' ',')
  done

  (( ctr += div ))
done
