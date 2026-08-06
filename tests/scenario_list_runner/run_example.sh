#!/bin/bash

cd "$(dirname "$0")"
# Runs each scenario in the example 1 list for 7 steps
source run_scenario_list.sh scenario_lists/example1.txt 8 300
