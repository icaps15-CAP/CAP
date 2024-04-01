#!/bin/bash
# -*- truncate-lines : t -*-

export FD_DIR=$(dirname $(readlink -ef $0))/downward

MORE_OPTIONS=$@
capdir=$(dirname $(readlink -ef $0))

#### lama 1st iteration

export ffff="--both-search ff-clean - --remove-component-problem-cost --remove-main-problem-cost"
export fdfd="--add-macro-cost --preprocessor fd-latest-clean --alias lama-first - --main-search fd-latest-clean --alias lama -"
export prpr='--add-macro-cost --both-search probe-clean -'

export mv='--both-search marvin2-clean - --remove-component-problem-cost --remove-main-problem-cost'

export yhfd="--add-macro-cost --preprocessor yahsp3-clean - --main-search fd-clean $lama2011 -"

export yh="--add-macro-cost --both-search yahsp3-clean -"

export yhar="--add-macro-cost --preprocessor yahsp3-clean - --main-search ipc-arvandherd-sat-clean -"
export yhib="--add-macro-cost --preprocessor yahsp3-clean - --main-search ipc-ibacop-mco-clean -"


rm -r /tmp/lisptmp /tmp/captest /tmp/newtmp

echo "results goes to /tmp/captest/"

# gnu parallel
parallel $MORE_OPTIONS --joblog test.log \
    ./runtest.sh \
    ::: 01 \
    ::: $capdir/test/*/ \
    ::: "$fdfd"

#  --ipc-threads
# --force-single-node-components --force-variable-factoring --compatibility
# to use the other planners, see src/planner-scripts

# "--threads 4"

    # "$ff" "$fd" "$pr" \
# "" --iterative-resource "--ipc-threads"
