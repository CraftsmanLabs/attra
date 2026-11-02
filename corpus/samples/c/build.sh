#!/usr/bin/env bash
# build.sh CC CXX FLAGS...: generate big.c, build tests/test_main into ./build/test.
set -euo pipefail
cc=$1; cxx=$2; shift 2
mkdir -p build gen
../gen-big.sh c > gen/big.c
for f in src/classify.c lib/util.c gen/big.c; do
  "$cc" "$@" -Isrc -Ilib -c "$f" -o "build/$(basename "$f" .c).o"
done
"$cxx" "$@" -Isrc -Ilib -c src/templates.cpp -o build/templates.o
"$cxx" "$@" -Isrc -Ilib -c tests/test_main.cpp -o build/test_main.o
"$cxx" "$@" build/*.o -o build/test
