#!/bin/bash

pgrep -fa "component-planner"
pids=$(pgrep -f component-planner)

for pid in $pids
do
    ps --ppid $pid
done
