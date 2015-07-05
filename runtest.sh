#!/bin/bash

capdir=$(dirname $(readlink -ef $0))

prob=$1
dir=$2
# planner=$3
# options="$(eval "echo \$$planner") $4"
options="$3 $4"
domain=$(basename $dir)

tmpdir=$(mktemp --tmpdir -d $domain.$prob.XXXXXXXXXXX)

cd $tmpdir
echo "-*- truncate-lines : t -*-" > log
echo "-*- truncate-lines : t -*-" > err
$capdir/component-planner \
    --dynamic-space-size 2000 \
    -t 1800 -m 500000 \
    --default \
    --validation \
    $options $dir/p$prob.pddl >> log 2>> err


