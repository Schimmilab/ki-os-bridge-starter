#!/bin/sh
# guard-scan.sh — blocks the other sphere's internals. Exit 1 on a hit, 0 if clean.
# Usage: guard-scan.sh <file> [<file> ...]
set -u
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
# collect generic + local patterns, strip comments/blank lines
{ cat "$ROOT/deny-patterns.txt" 2>/dev/null; cat "$ROOT/deny-patterns.local.txt" 2>/dev/null; } \
  | grep -vE '^[[:space:]]*(#|$)' > "$tmp" 2>/dev/null || true
# no patterns defined -> nothing to check (an empty pattern file would match everything)
[ -s "$tmp" ] || exit 0
hit=0
for f in "$@"; do
  [ -f "$f" ] || continue
  if grep -E -i -n -f "$tmp" "$f" >/dev/null 2>&1; then
    echo "BLOCKED: $f contains a block pattern:" >&2
    grep -E -i -n -f "$tmp" "$f" >&2
    hit=1
  fi
done
exit $hit
