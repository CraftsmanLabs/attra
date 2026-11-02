#!/bin/bash
# bench.sh <label> <cmd...> : prints label, wall seconds, max RSS MB (macOS /usr/bin/time -l)
label=$1; shift
/usr/bin/time -l "$@" > ${TMPDIR:-/tmp}/bench.out 2> ${TMPDIR:-/tmp}/bench.err
rc=$?
real=$(grep -aE ' real ' ${TMPDIR:-/tmp}/bench.err | awk '{print $1}')
rss=$(grep -a 'maximum resident set size' ${TMPDIR:-/tmp}/bench.err | awk '{printf "%.0f", $1/1048576}')
echo -e "$label\trc=$rc\twall=${real}s\trss=${rss}MB"
[ $rc -ne 0 ] && tail -5 ${TMPDIR:-/tmp}/bench.err
true
