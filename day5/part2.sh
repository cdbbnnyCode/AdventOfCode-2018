#!/bin/bash
# set -x ;
# set -o functrace

source ../fetch.sh

input=$(fetch 5) # It's one string today!!

letters=( {a..z} )

function deletePoly() {
  inp=$1
  ltr=$2
  upper=${ltr^^} # Only works on Bash 4.0+
  lower=${ltr,,}
  init_len=${#inp}
  out=$(echo $inp | sed -e "s/${lower}${upper}//g" -e "s/${upper}${lower}//g")
  echo "$out"
}

function react() {
  in=$1
  for l in ${letters[@]}; do
    in=$(deletePoly $in $l)
  done
  echo "$in"
}


function reactAll() {
  m_input=$1
  echo ${#m_input} >&2
  while true; do
    len=${#m_input}
    m_input=$(react $m_input)
    echo "${#m_input}"
    echo "-> ${#m_input}" >&2
    if [ $len -eq ${#m_input} ]; then
      echo "Fully reacted" >&2
      break
    fi
  done
}

for v in ${letters[@]}; do
  modified=$(echo $input | tr -d "$v${v^^}")
  length=$(reactAll $modified | tail -n 1)
  ltable="$ltable$length $v"$'\n'
done

echo "$ltable" | sort
