#!/bin/bash
source ../fetch.sh

calc $(fetch 1 | tr -d '\n')
