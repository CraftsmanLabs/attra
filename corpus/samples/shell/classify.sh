#!/usr/bin/env bash
# Shell sample for kcov.
source "$(dirname "$0")/lib/util.sh"

# Branches: the run below only takes the "negative even" and "positive" arms.
classify() {
  local n=$1
  if [ "$n" -lt 0 ] && [ $((n % 2)) -eq 0 ]; then
    echo "negative even"
  elif [ "$n" -lt 0 ]; then
    echo "negative odd"
  elif [ "$n" -eq 0 ]; then
    echo "zero"
  else
    echo "positive"
  fi
}

# Partial line: only the "small" side runs.
size() { if [ "$1" -gt 100 ]; then echo big; else echo small; fi; }

# Never called.
never_called() {
  echo $(($1 * 2))
}

# Excluded by the user.
excluded() { # LCOV_EXCL_LINE
  echo $(($1 * 3)) # LCOV_EXCL_LINE
} # LCOV_EXCL_LINE

classify -2
classify 5
size 3
add 1 2
