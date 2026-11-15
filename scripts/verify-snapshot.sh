#!/usr/bin/env bash
# verify-snapshot.sh - re-checks a 4R snapshot list against a folder, on any machine.
#
# Usage:  bash verify-snapshot.sh <folder> <the -snapshot.tsv file> [in]
#
# The snapshot list (written by copy-target.sh) holds 1 fingerprint per file: SHA-256, a code
# built from the file's exact bytes. This script builds each fingerprint again from the folder
# named on the command line and says which files MATCH, which CHANGED and which are MISSING.
#   <folder> = the audit's copy      add the word  in  (the copy never held the LEFT OUT files)
#   <folder> = the real workspace    checks every line that carries a fingerprint
# Reads only. Writes nothing into the folder.
# Exit 0 = every fingerprint matches. Exit 1 = a file changed or is missing. Exit 2 = bad arguments.

set -u
F="${1:?usage: bash verify-snapshot.sh <folder> <snapshot.tsv> [in]}"
S="${2:?usage: bash verify-snapshot.sh <folder> <snapshot.tsv> [in]}"
ONLY="${3:-all}"
[ -d "$F" ] || { echo "verify-snapshot: no folder at $F"; exit 2; }
[ -f "$S" ] || { echo "verify-snapshot: no snapshot list at $S"; exit 2; }
S="$(cd "$(dirname "$S")" && pwd)/$(basename "$S")"
if command -v sha256sum >/dev/null 2>&1; then HASH="sha256sum"; else HASH="shasum -a 256"; fi
want="$(mktemp)"; got="$(mktemp)"; trap 'rm -f "$want" "$got"' EXIT
awk -F'\t' -v only="$ONLY" '!/^#/ && length($4) == 64 && (only != "in" || $1 == "IN") { print $4 "\t" $5 }' "$S" > "$want"
total=$(wc -l < "$want" | tr -d ' ')
[ "$total" -gt 0 ] || { echo "verify-snapshot: no fingerprints in $S, nothing was checked"; exit 2; }
(cd "$F" && cut -f2 "$want" | tr '\n' '\0' | xargs -0 $HASH 2>/dev/null) \
  | awk '{ if (substr($0, 1, 1) == sprintf("%c", 92)) $0 = substr($0, 2); print substr($0, 1, 64) "\t" substr($0, 67) }' > "$got"
res="$(awk -F'\t' 'NR == FNR { g[$2] = $1; next }
  { if (!($2 in g)) { print "MISSING  " $2; ms++ } else if (g[$2] != $1) { print "CHANGED  " $2; ch++ } else ok++ }
  END { printf "COUNTS %d %d %d\n", ok, ch, ms }' "$got" "$want")"
printf '%s\n' "$res" | grep -v '^COUNTS' | head -n 100
set -- $(printf '%s\n' "$res" | grep '^COUNTS'); match=$2; changed=$3; missing=$4
echo "VERIFY  $match of $total fingerprints match, $changed changed, $missing missing"
[ "$changed" -eq 0 ] && [ "$missing" -eq 0 ] && exit 0
exit 1
