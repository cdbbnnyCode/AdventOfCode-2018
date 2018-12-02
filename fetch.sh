#!/bin/bash

SESSION_COOKIE="session=$(cat ../session.txt)"

function fetch ()
{
  mkdir -p /tmp/adventofcode/
  if [ -e "/tmp/adventofcode/$1" ]; then
    cat "/tmp/adventofcode/$1"
  else
    if [ -z "$SESSION_COOKIE" ]; then
      echo "Unable to fetch inputs without a session cookie!"
      echo "Put your session cookie in a file called 'session.txt' in the same"
      echo "directory as fetch.sh"
    fi
    curl -s --cookie "$SESSION_COOKIE" "https://adventofcode.com/2018/day/$1/input" | tee "/tmp/adventofcode/$1"
  fi
};
