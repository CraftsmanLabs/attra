#!/usr/bin/env bash
# Regenerate the report corpus. Usage: corpus/generate.sh [emitter...]
# With no arguments, runs every emitter under corpus/emitters/.
# Each emitter builds its pinned image, runs its run.sh against the read-only
# samples, and writes reports/<emitter>/ plus a manifest.json.
# An optional emitters/<emitter>/docker-args holds extra `docker run` flags.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
cd "$here"

if [ $# -eq 0 ]; then
  set -- $(ls -d emitters/*/ | xargs -n1 basename)
fi

status=0
for e in "$@"; do
  echo "== $e"
  image="attra-corpus-$e"
  docker build -q -t "$image" "emitters/$e" > /dev/null
  rm -rf "reports/$e"; mkdir -p "reports/$e"
  extra=()
  if [ -f "emitters/$e/docker-args" ]; then read -ra extra < "emitters/$e/docker-args"; fi
  if docker run --rm ${extra[@]+"${extra[@]}"} \
      -v "$here:/corpus:ro" \
      -v "$here/reports/$e:/out" \
      "$image" bash "/corpus/emitters/$e/run.sh"; then
    python3 scripts/manifest.py "$e" "$(head -n1 "emitters/$e/Dockerfile" | sed 's/^FROM //')"
  else
    echo "!! $e failed" >&2; status=1
  fi
done
python3 scripts/index.py
exit $status
