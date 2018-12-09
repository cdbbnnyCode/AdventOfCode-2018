#!/bin/bash
source ../fetch.sh

input=( $(fetch 6 | tr -d ' ' ) ) # Items separated by comma and space

declare -A table
# Table: 'x,y' -> 'source'
sources=( ${input[@]} )
# Sources: 'source' -> 'x,y'
growing=( ${input[@]} )
nGrowing=50
# Growing: 'source' -> 'x,y_x,y_..._x,y'

areas=( )
infin=( )
colors=( )

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

function udlr() {
  local spl=( $(echo $1 | tr ',' ' ') )
  out=( ${spl[0]},$((${spl[1]}+1)) $((${spl[0]}+1)),${spl[1]} \
        ${spl[0]},$((${spl[1]}-1)) $((${spl[0]}-1)),${spl[1]} )
  if [ ${spl[0]} -le 0 ]; then
    unset out[3]
  elif [ ${spl[0]} -ge 399 ]; then
    unset out[1]
  fi
  if [ ${spl[1]} -le 0 ]; then
    unset out[2]
  elif [ ${spl[1]} -ge 399 ]; then
    unset out[0]
  fi
  echo ${out[@]}
}

function grow() {
  nGrowing=0
  for s in ${!sources[@]}; do # s = source index
    gr=$( echo ${growing[$s]} | tr '_' ' ' )
    ngrow=( )
    echo -n '.'
    for g in ${gr[@]}; do
      # 1. Attempt to place
      if [ -z "${table[$g]}" ]; then
        # This space has not been claimed; claim it!
        table[$g]=$s
        (( areas[$s] += 1 ))
        # Since we succeeded, grow
        local u=( $(udlr $g) )
        if [ ${#u[@]} -lt 4 ]; then
          echo "Area of $s is infinite"
          (( infin[$s] = 1 ))
        fi
        ngrow+=( ${u[@]} )
      elif [ "${table[$g]}" = "n" ]; then
        # This point is uninhabitable
        true
      elif [ "${table[$g]}" -eq "$s" ]; then
        # WE already claimed this space; ignore it
        true
        # If distance from the point to its source is equal to the distance from the point to our source
      elif [ "$(distance ${sources[${table[$g]}]} $g)" -eq "$(distance ${sources[$s]} $g)" ]; then
        # Cancel them
        (( areas[${table[$g]}] -= 1 ))
        table[$g]="n"
      fi
    done
    (( nGrowing += ${#ngrow[@]} ))
    growing[$s]=$( echo ${ngrow[@]} | tr ' ' '_' )
  done
}

function draw() {
  (
    echo "# ImageMagick pixel enumeration: 400,400,255,hsb"
    for xy in ${!table[@]}; do
      s=${table[$xy]}
      if [ "$s" = "n" ]; then continue; fi
      if [ -z "${colors[$s]}" ]; then
        colors[$s]="$(( $RANDOM % 255 )),$(( $RANDOM % 127 + 127 ))"
      fi
      echo "$xy: (${colors[$s]},200)"
    done
    for s in ${!sources[@]}; do
      xy=${sources[$s]}
      echo "$xy: (${colors[$s]},255)"
    done
    for g in ${!growing[@]}; do
      gr=( $( echo ${growing[$g]} | tr '_' ' ' ) )
      for xy in ${gr[@]}; do
        echo "$xy: (${colors[$g]},63)"
      done
    done
  ) | convert txt:- -colorspace rgb -fill white -opaque red -brightness-contrast 25 image.png
}

while [ $nGrowing -gt 0 ]; do
  echo -ne "\nGrowing... n=$nGrowing"
  grow
  draw
done
echo "Done! n=$nGrowing"

for v in ${!infin[@]}; do
  if [ ${infin[$v]} -gt 0 ]; then
    unset areas[$v]
  fi
done
echo "${areas[@]}" | tr ' ' $'\n' | sort -rn
