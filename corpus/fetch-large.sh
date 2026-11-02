#!/usr/bin/env bash
# Download large real-world reports into corpus/large/ (git-ignored; too big to commit).
# Usage: corpus/fetch-large.sh [kubernetes] [home-assistant]
# Writes corpus/large/<source>/SOURCE.txt recording exactly what was fetched.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$here/large"
[ $# -eq 0 ] && set -- kubernetes home-assistant

kubernetes() {
  # Prow publishes ci-kubernetes-coverage-unit artifacts to a public bucket.
  local dir="$here/large/kubernetes" bucket=https://storage.googleapis.com/kubernetes-ci-logs
  local list="https://storage.googleapis.com/storage/v1/b/kubernetes-ci-logs/o?prefix=logs/ci-kubernetes-coverage-unit/&delimiter=/"
  mkdir -p "$dir"
  # The bucket lists 1000 prefixes per page; collect every build id, newest first.
  local builds
  builds=$(python3 - "$list" <<'PY'
import json, sys, urllib.parse, urllib.request
url, token, ids = sys.argv[1], None, []
while True:
    page = json.load(urllib.request.urlopen(url + (f"&pageToken={urllib.parse.quote(token)}" if token else "")))
    ids += [p.rstrip("/").rsplit("/", 1)[1] for p in page.get("prefixes", [])]
    token = page.get("nextPageToken")
    if not token:
        break
print("\n".join(sorted((i for i in ids if i.isdigit()), key=int, reverse=True)[:10]))
PY
)
  # The newest build may still be running or have failed; take the newest with a profile.
  local build=""
  for b in $builds; do
    if curl -fsS -o "$dir/combined-coverage.out" "$bucket/logs/ci-kubernetes-coverage-unit/$b/artifacts/combined-coverage.out" 2>/dev/null; then
      build=$b; break
    fi
  done
  [ -n "$build" ] || { echo "no recent build has combined-coverage.out" >&2; return 1; }
  local commit
  commit=$(curl -fsS "$bucket/logs/ci-kubernetes-coverage-unit/$build/started.json" | python3 -c 'import sys,json; print(json.load(sys.stdin)["repo-commit"])')
  printf 'source: kubernetes/kubernetes ci-kubernetes-coverage-unit\nbuild: %s\ncommit: %s\nurl: %s\nfetched: %s\nformat: go-coverprofile (mode: atomic)\n' \
    "$build" "$commit" "$bucket/logs/ci-kubernetes-coverage-unit/$build/artifacts/combined-coverage.out" "$(date -u +%FT%TZ)" > "$dir/SOURCE.txt"
}

home_assistant() {
  # One coverage-* artifact per pytest shard, uploaded by the CI workflow. Artifacts expire after ~7 days.
  local dir="$here/large/home-assistant"
  rm -rf "$dir"; mkdir -p "$dir"
  local run
  run=$(gh run list -R home-assistant/core --workflow CI --branch dev --status success --limit 1 --json databaseId --jq '.[0].databaseId')
  gh run download "$run" -R home-assistant/core -p 'coverage-*' -D "$dir"
  local commit
  commit=$(gh run view "$run" -R home-assistant/core --json headSha --jq .headSha)
  printf 'source: home-assistant/core CI workflow, coverage-* artifacts\nrun: %s\ncommit: %s\nfetched: %s\nformat: cobertura (coverage.py), one per shard\n' \
    "$run" "$commit" "$(date -u +%FT%TZ)" > "$dir/SOURCE.txt"
}

for s in "$@"; do
  echo "== $s"
  case $s in
    kubernetes) kubernetes ;;
    home-assistant) home_assistant ;;
    *) echo "unknown source: $s" >&2; exit 2 ;;
  esac
done
