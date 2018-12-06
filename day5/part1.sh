#!/bin/bash

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

function reactAll() {
  in=$1
  for l in ${letters[@]}; do
    in=$(deletePoly $in $l)
  done
  echo "$in"
}

echo ${#input}

while true; do
  len=${#input}
  input=$(reactAll $input)
  echo "-> ${#input}"
  if [ $len -eq ${#input} ]; then
    echo "Cannot reduce anymore"
    break
  fi
done
