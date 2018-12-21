#!/bin/bash
source ../fetch.sh

declare -A tracks
carts=( )

function render() {
  tput el
  echo "$( # Double-buffer the output so that we can see it
  # Usage: render <x> <y> [radius=5]
  local x=$1
  local y=$2
  echo "$x,$y:"
  [ -n "$3" ] && local r=$3 || local r=5
  declare -A cartxy
  for cart in ${carts[@]}; do
    if [ -n "${cartxy[$(echo $cart | cut -d ',' -f 2-3)]}" ]; then
      # Render crashes as a red X
      cartxy[$(echo $cart | cut -d ',' -f 2-3)]="X,1"
    else
      cartxy[$(echo $cart | cut -d ',' -f 2-3)]=$(echo $cart | cut -d ',' -f 1),$(( $(echo $cart | cut -d ',' -f 5) * 10 + 26 ))
    fi
  done
  for (( yy = y - r / 2; yy <= y + r / 2; yy++ )); do
    for (( xx = x - r; xx <= x + r; xx++ )); do
      track=${tracks[$xx,$yy]}
      cart=${cartxy[$xx,$yy]}
      if [ -z "$cart" ]; then
        echo -n "$track"
      else
        tput bold
        tput setaf $(echo $cart | cut -d ',' -f 2)
        echo -n "$(echo $cart | cut -d ',' -f 1)"
        tput sgr0
      fi
      [ -z "$track" ] && echo -n " "
    done
    echo
  done
  )"
}

function clockwise() {
  # Usage: clockwise <direction>
  # Direction: ^ is up, > is right, v is down, < is left
  case $1 in
    '^')
      echo '>';;
    '>')
      echo 'v';;
    'v')
      echo '<';;
    '<')
      echo '^';;
  esac
}

function cclockwise() {
  # Usage: see clockwise()
  case $1 in
    '^')
      echo '<';;
    '>')
      echo '^';;
    'v')
      echo '>';;
    '<')
      echo 'v';;
  esac
}

# Load carts
x=0
y=0
cartid=0
while IFS= read -r -n 1 c; do
  if [ -z "$c" ]; then
    # Newline reached
    x=0
    (( y++ ))
  else
    track=$c
    case "$c" in
      '^'|'v')
        track='|'
        carts[$cartid]=$c,$x,$y,0,$cartid
        echo "Cart $cartid ($c) @ $x,$y"
        (( cartid++ ))
        ;;
      '<'|'>')
        track='-'
        carts[$cartid]=$c,$x,$y,0,$cartid
        echo "Cart $cartid ($c) @ $x,$y"
        (( cartid++ ))
        ;;
    esac
    [ "$track" != " " ] && tracks[$x,$y]=$track
    (( x++ ))
  fi
done << EOF
$(fetch 13)
EOF

for c in ${carts[@]}; do
  echo
  echo "Cart ($c)"
  xy=( $(echo $c | cut -d ',' -f 2-3 | tr ',' ' ') )
  render ${xy[0]} ${xy[1]} 10
done

crash=0
tick=0
indexes=( ${!carts[@]} )
chosen=$(( indexes[$RANDOM % ${#indexes[@]}] ))
watching=8
# watching=$(echo ${carts[$chosen]} | cut -d , -f 5)
clear
while true; do
  [ $crash != 0 ] && break
  carts=( $(echo ${carts[@]} | tr ' ' $'\n' | sort -n -t , -k 2,3) )
  for cid in ${!carts[@]}; do
#    tput cup 15 0
#    tput el
#    echo ${carts[@]}
    if [ -z "${carts[$cid]}" ]; then continue; fi
    cartd=$(echo ${carts[$cid]} | cut -d ',' -f 1)
    cartx=$(echo ${carts[$cid]} | cut -d ',' -f 2)
    carty=$(echo ${carts[$cid]} | cut -d ',' -f 3)
    cart_state=$(echo ${carts[$cid]} | cut -d ',' -f 4)
    cartid=$(echo ${carts[$cid]} | cut -d ',' -f 5) # Solely for storage
    case $cartd in
      '^')
        (( carty-- ));;
      '>')
        (( cartx++ ));;
      'v')
        (( carty++ ));;
      '<')
        (( cartx-- ));;
    esac
    track=${tracks[$cartx,$carty]}
    for ci in ${!carts[@]}; do
      cx=$(echo ${carts[$ci]} | cut -d ',' -f 2)
      cy=$(echo ${carts[$ci]} | cut -d ',' -f 3)
      if [ $cx -eq $cartx -a $cy -eq $carty ]; then
        # Update the cart in question so that it draws properly
        carts[$cid]=$cartd,$cartx,$carty,$cart_state,$cartid
        crash=$cx,$cy
        crashid=$( echo ${carts[$ci]} | cut -d , -f 5 )
        echo "Crash! Cart $cartid crashes into cart $crashid"
        # render $cx $cy 15
#        unset carts[$cid]
#        unset carts[$ci]
#        if [ $watching -eq $cartid -o $watching -eq $crashid ]; then
#          indexes=( ${!carts[@]} )
#          if [ ${#indexes[@]} -eq 0 ]; then
#            echo "No more carts left!"
#            exit 1
#          fi
#          chosen=$(( indexes[$RANDOM % ${#indexes[@]}] ))
#          watching=$(echo ${carts[$chosen]} | cut -d , -f 5)
#          tput cup 15 0
#          echo "Now watching $watching"
#        fi
        break
      fi
    done
    if [ $crash != 0 ]; then
      break
    fi
    turn=1
    case $track in
      '/')
        case $cartd in
          '^'|'v') cartd=$(clockwise $cartd);;
          '<'|'>') cartd=$(cclockwise $cartd);;
        esac
        ;;
      '\')
        case $cartd in
          '^'|'v') cartd=$(cclockwise $cartd);;
          '<'|'>') cartd=$(clockwise $cartd);;
        esac
        ;;
      '+')
        case $cart_state in
          0) cartd=$(cclockwise $cartd);;
          # 1 goes straight
          2) cartd=$(clockwise $cartd);;
        esac
        (( cart_state = (cart_state + 1) % 3 )) # Update state
        ;;
      *)
        turn=0
        ;;
    esac
    carts[$cid]=$cartd,$cartx,$carty,$cart_state,$cartid
  done
  for cart in ${carts[@]}; do
    cartid=$( echo $cart | cut -d , -f 5 )
    if [ $cartid -eq $watching ]; then
      cartx=$( echo $cart | cut -d , -f 2 )
      carty=$( echo $cart | cut -d , -f 3 )
      tput cup 0 0
      tput el
      echo "Cart $cartid: $cart"
      render $cartx $carty 20
    fi
  done
  # render 75 75 75
  # sleep 1
  (( tick++ ))
done
echo $crash
render $( echo $crash | cut -d , -f 1 ) $( echo $crash | cut -d , -f 2 ) 20
