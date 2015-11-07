#!/bin/bash
# -*- truncate-lines : t -*-

export FD_DIR=$(dirname $(readlink -ef $0))/downward

MORE_OPTIONS=$@
capdir=$(dirname $(readlink -ef $0))

#### lama 1st iteration

export lama2011="--search-options --if-unit-cost --heuristic hlm,hff=lm_ff_syn(lm_rhw(reasonable_orders=true)) --search lazy_greedy([hff,hlm],preferred=[hff,hlm]) --if-non-unit-cost --heuristic hlm1,hff1=lm_ff_syn(lm_rhw(reasonable_orders=true,lm_cost_type=one,cost_type=one)) --search lazy_greedy([hff1,hlm1],preferred=[hff1,hlm1],cost_type=one,reopen_closed=false) --always"

export ff="--both-search ff-clean - --remove-component-problem-cost --remove-main-problem-cost"
export fd="--add-macro-cost --both-search fd-clean $lama2011 -"
export pr='--add-macro-cost --both-search probe-clean -'
export cea='--both-search fd-clean --search-options --search lazy_greedy(cea()) -'
export mv='--both-search marvin2-clean - --remove-component-problem-cost --remove-main-problem-cost'

rm -r /tmp/lisptmp /tmp/captest /tmp/newtmp

# gnu parallel
parallel $MORE_OPTIONS --joblog test.log \
    ./runtest.sh \
    ::: 01 02 \
    ::: $capdir/unsolvable/*/ \
    ::: "$fd"

    # ::: --compatibility \


# --force-single-node-components --force-variable-factoring --compatibility
# to use the other planners, see src/planner-scripts


    # "$ff" "$fd" "$pr" \
