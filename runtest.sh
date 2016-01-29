#!/bin/bash

capdir=$(dirname $(readlink -ef $0))

prob=$1
dir=$2
# planner=$3
# options="$(eval "echo \$$planner") $4"
options="$3 $4"
domain=$(basename $dir)

mkdir -p /tmp/captest
tmpdir=$(mktemp --tmpdir=/tmp/captest -d $domain.$prob.XXXXXXXXXXX)

mkdir -vp /sys/fs/cgroup/cpu/$(whoami)/$$
mkdir -vp /sys/fs/cgroup/cpuacct/$(whoami)/$$
mkdir -vp /sys/fs/cgroup/memory/$(whoami)/$$

cd $tmpdir
echo "-*- truncate-lines : t -*-" > log
echo "-*- truncate-lines : t -*-" > err
cgexec -g cpu,cpuacct,memory:/$(whoami)/$$ /usr/bin/time $capdir/component-planner \
    -t 1800 -m 1000000 --preprocess-limit 900 \
     -v --validation \
    $options $dir/p$prob.pddl >> log 2>> err


#  --preprocess-only
