#!/bin/bash
source ../fetch.sh

 input=( $(fetch 8) )
# input=( $(cat sample.txt) )

# Node list:
# [<x>,o] = offset of node x
# [<x>,n] = number of child nodes
# [<x>,m] = number of metadata entries
# [<x>,m<m>] = value of metadata entry m
# [<x>,v] = node value
# Nodes use Unix-esque paths as IDs:
#   /    is the root node
#   /0   is the base node
#   /0/2 is the 3rd child of the base node
declare -A ntree

# ptree is a list of all of the paths
ptree=( )

echo "Building node tree"
path=( )
idx=0

# Populate root node data
ntree['/,o']=0
ntree['/,n']=1
ntree['/,m']=0
ptree+=( '/' )

ptr=0

while [ $ptr -lt ${#input[@]} ]; do
  pathstr='/'$(echo ${path[@]} | tr ' ' '/')
  tld_ccount=${ntree[$pathstr,n]}
  echo "Path: $pathstr, ptr = $ptr, tld has $tld_ccount child(ren), idx = $idx"
  if [ $idx -lt $tld_ccount ]; then
    # Read node data
    nChildren=${input[$ptr]}
    (( ptr += 1 ))
    nMeta=${input[$ptr]}
    (( ptr += 1 ))

    path+=( $idx )
    idx=0
    pathstr='/'$(echo ${path[@]} | tr ' ' '/')
    echo "  Node $pathstr: $nChildren children, $nMeta metadata"
    ntree[$pathstr,o]=$ptr
    ntree[$pathstr,n]=$nChildren
    ntree[$pathstr,m]=$nMeta
    ptree+=( $pathstr )
  else
    metacount=${ntree[$pathstr,m]}
    for (( m = 0; m < metacount; m++ )); do
      ntree[$pathstr,m$m]=${input[$ptr]}
      echo "  Metadata $m = ${input[$ptr]}"
      (( ptr += 1 ))
    done
    # Drop one level and increment index
    idx=${path[-1]}
    unset path[-1]
    (( idx += 1 ))
    echo "  Drop ($metacount metadata)"
  fi
done

sum=0
# Iterate backwards through the array so that child nodes are evaluated before their
# parents
for (( i = ${#ptree[@]}-1; i >= 0; i-- )); do
  v=${ptree[$i]}
  if [ ${ntree[$v,n]} -eq 0 ]; then
    total=0
    for (( j = 0; j < ${ntree[$v,m]}; j++ )); do
      (( total += ${ntree[$v,m$j]} ))
    done
    ntree[$v,v]=$total
  else
    total=0
    for (( j = 0; j < ${ntree[$v,m]}; j++ )); do
      index=${ntree[$v,m$j]}
      if [ -n "${ntree[$v/$((index-1)),v]}" ]; then
        (( total += ${ntree[$v/$((index-1)),v]} ))
      fi
    done
    ntree[$v,v]=$total
  fi
  echo "$v -- ${ntree[$v,v]}"
done

echo "Root value: ${ntree[/0,v]}"
