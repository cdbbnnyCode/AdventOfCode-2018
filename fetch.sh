#!/bin/bash

SESSION_COOKIE='session=***REMOVED***'

function fetch ()
{
  curl -s --cookie "$SESSION_COOKIE" "https://adventofcode.com/2018/day/$1/input"
};
