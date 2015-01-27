#!/bin/bash

export FD_DIR=$(dirname $(readlink -ef $0))/downward

./component-planner --dynamic-space-size 2000 --default -t 1800 -m 2000000 test/p20.pddl



