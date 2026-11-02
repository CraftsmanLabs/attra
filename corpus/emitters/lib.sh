# Sourced by every emitter's run.sh inside its container.
# Records what ran so manifest.py can write reports/<emitter>/manifest.json.
set -euo pipefail
OUT=/out
LOG="$OUT/.log.tsv"
mkdir -p "$OUT"
: > "$LOG"

# tool NAME CMD...: record the first line of CMD's output as NAME's version.
tool() {
  local name=$1; shift
  local v; v=$("$@" 2>&1 | head -n1); v=${v//$'\t'/ }
  printf 'tool\t%s\t%s\n' "$name" "$v" >> "$LOG"
}

# step CMD...: record CMD and its working directory, then run it.
step() {
  local cmd="$*"
  cmd=${cmd//$'\n'/\\n}; cmd=${cmd//$'\t'/\\t}
  printf 'step\t%s\t%s\n' "$PWD" "$cmd" >> "$LOG"
  "$@"
}

# keep FORMAT SRC DEST: copy report SRC to $OUT/DEST and record its format.
keep() {
  mkdir -p "$OUT/$(dirname "$3")"
  cp -R "$2" "$OUT/$3"
  printf 'report\t%s\t%s\t%s\n' "$3" "$1" "$PWD/$2" >> "$LOG"
}

# note TEXT: record a fact about this emitter's run (a quirk, a missing feature).
note() { printf 'note\t%s\n' "$*" >> "$LOG"; }

# fresh SAMPLE: copy a read-only sample into /work/SAMPLE and cd there.
fresh() {
  rm -rf "/work/$1"; mkdir -p /work
  cp -R "/corpus/samples/$1" "/work/$1"
  cp /corpus/samples/gen-big.sh /work/gen-big.sh
  cd "/work/$1"
}
