#!/bin/bash
source ../fetch.sh

input=( $(fetch 9 | awk '{print $1" "$7}') )
echo "${input[@]}"
(( input[1] *= 100 ))

# Compile
echo "Compiling..."
g++ -Wall helper.cpp -o helper

./helper ${input[0]} ${input[1]}
