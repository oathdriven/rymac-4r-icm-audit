#!/usr/bin/env bash
# examined.sh - 4R audit, the EXAMINED LIST: which files the auditor actually opened.
#
# Usage:  bash examined.sh <the -snapshot.tsv file> <opened.txt> [more opened lists]
#
# "In the copy" and "opened by the auditor" are 2 different claims (a member's point, v1.5.5).
# The snapshot list proves the first. This script records the second: each opened list is plain
# text, 1 path per line, relative to the copy, in the order the files were opened. The stranger
# writes 1 in layer 2, and the auditor writes 1 for the files opened by hand.
# Every path gets matched to the snapshot list:
#   EXAMINED   opened, and in the copy (carries the same fingerprint as the snapshot list)
#   WANTED     the reader went looking for a file the copy LEFT OUT (with the reason)
#   UNKNOWN    opened or named, and not on the snapshot list at all
# Writes <scratch>-examined.tsv beside the snapshot list. An opened list is the reader's own
# account of what the reader opened, so the report says so.
# Exit 0 = written. Exit 2 = bad arguments.

set -u
S="${1:?usage: bash examined.sh <snapshot.tsv> <opened.txt> [more]}"
[ -f "$S" ] || { echo "examined: no snapshot list at $S"; exit 2; }
shift
[ "$#" -gt 0 ] || { echo "examined: give at least 1 opened list"; exit 2; }
for f in "$@"; do [ -f "$f" ] || { echo "examined: no opened list at $f"; exit 2; }; done
out="${S%-snapshot.tsv}-examined.tsv"
cat "$@" | tr -d '\r' | sed 's#^\./##; s#^[[:space:]]*##; s#[[:space:]]*$##' | grep -v '^$' | awk '!seen[$0]++' \
  | awk -F'\t' -v snap="$S" 'BEGIN {
        while ((getline l < snap) > 0) { if (l ~ /^#/) continue; n = split(l, c, "\t"); st[c[5]] = c[1]; why[c[5]] = c[2]; h[c[5]] = c[4]; if (c[1] == "IN") total++ }
        print "# 4R examined list. order\tstatus\tsha256 or reason\tpath"
      }
      { o++
        if (st[$0] == "IN") { ex++; printf "%d\tEXAMINED\t%s\t%s\n", o, h[$0], $0 }
        else if (st[$0] == "LEFT OUT") { wa++; printf "%d\tWANTED\tleft out: %s\t%s\n", o, why[$0], $0 }
        else { un++; printf "%d\tUNKNOWN\tnot on the snapshot list\t%s\n", o, $0 } }
      END { printf "# COUNTS\t%d\t%d\t%d\t%d\n", ex, total, wa, un }' > "$out"
set -- $(grep '^# COUNTS' "$out" | cut -f2-)
echo "EXAMINED $1 files opened, of $2 in the copy"
echo "        $3 files the reader went looking for were LEFT OUT of the copy"
grep '	WANTED	' "$out" | head -n 50 | while IFS="$(printf '\t')" read -r o st why p; do echo "WANTED   $p ($why)"; done
echo "        $4 paths opened or named that are not on the snapshot list"
echo "        the examined list: $out"
exit 0
