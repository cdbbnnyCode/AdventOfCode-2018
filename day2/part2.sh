#!/bin/bash
source ../fetch.sh

ids=( $(fetch 2) )


for id in "${ids[@]}"; do
  echo "Checking $id"
  split1=$(echo $id | sed 's/\(.\)/\1\n/g')
  for cmp in "${ids[@]}"; do
    split2=$(echo $cmp | sed 's/\(.\)/\1\n/g')
    diffs=$(diff -y --suppress-common-lines <(echo "$split1") <(echo "$split2") | wc -l)
    if [ $diffs -eq 1 ]; then
      sim1=$id
      sim2=$cmp
      break
    fi
  done
  if [ -n "$sim1" ]; then
    break
  fi
done

echo "$sim1 and $sim2 are similar"

split1=$(echo $sim1 | sed 's/\(.\)/\1\n/g')
split2=$(echo $sim2 | sed 's/\(.\)/\1\n/g')
differ=$(diff -y <(echo "$split1") <(echo "$split2"))
cn=$(echo "$differ" | grep -n '|' | awk -F ':' '{print $1}')
echo "$sim1" | cut -c "-$(($cn-1)) $(($cn+1))-"
