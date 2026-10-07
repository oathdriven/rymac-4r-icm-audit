#!/usr/bin/env bash
# size.sh - 4R audit, layer 1, question 9: is the workspace growing? Read only.
#
# Usage:  bash size.sh <target folder> [last record .md]
#
# Counts the lines in the 3 parts of a workspace that grow every time a fix gets ADDED:
#   rules   the files an agent reads first: every CLAUDE.md, AGENTS.md and CONTEXT.md
#   skills  the written instructions: every .md under a folder named skills/, and every SKILL.md
#   checks  every script: .sh .py .mjs .js .cjs .ts .ps1 (hooks, guards, check scripts)
# Set aside (counted apart, never in the totals): build/ dist/ vendor/ .next/ coverage/ gsd-core/ synced/, *.min.js, *.bundle.js
# Saved files only when the target is a git repo (what an agent and a backup both see),
# else every file. node_modules and .git are never counted.
# Prints each part, the 10 biggest files, and 1 machine line the record keeps:
#   SIZE rules=<lines> skills=<lines> checks=<lines> files=<count>
# Given the last record, the change since then prints beside each part.
#
# Why this exists (2026-10-05): a builder's own routine audits grew his harness from about
# 15,000 lines to 95,000 in a few weeks, because every fix was ADDED and almost nothing was
# deleted. An audit that never counts size cannot see that coming.
#
# Exit 0 = counted. Exit 2 = no target. Growth is a finding for the report, never a crash.

set -u
# 2026-10-07 (a member found it): a plain "git status" rewrites .git/index and can
# leave an index.lock behind in the folder it reads. This keeps every git call read only.
export GIT_OPTIONAL_LOCKS=0
T="${1:?usage: bash size.sh <target folder> [last record .md]}"
LAST="${2:-}"
[ -d "$T" ] || { echo "size: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"
W="$(mktemp -d 2>/dev/null || mktemp -d -t size)"
trap 'rm -rf "$W"' EXIT
if git -C "$T" rev-parse --show-toplevel >/dev/null 2>&1; then
  (cd "$T" && git ls-files) > "$W/all"
else
  (cd "$T" && find . \( -name .git -o -name node_modules \) -prune -o -type f -print | sed 's#^\./##') > "$W/all"
fi

# sort every path into its part in 1 pass, then count lines in batches, never 1 program per file
# (1 program per file took minutes on a 28,000 file workspace on Windows)
# machine built or borrowed code is set aside and counted apart: nobody wrote those lines by hand, and they would
# drown the signal (a video app's build folder alone held 250,000 lines on the first run)
awk -v R="$W/rules" -v S="$W/skills" -v C="$W/checks" -v X="$W/aside" '
  /(^|\/)node_modules\// { next }
  /(^|\/)(build|dist|vendor|\.next|coverage|gsd-core|synced)\// || /\.(min|bundle)\.js$/ { print > X; next }
  {
    n = split($0, a, "/"); b = a[n]
    if (b == "CLAUDE.md" || b == "AGENTS.md" || b == "CONTEXT.md") print > R
    else if (($0 ~ /(^|\/)skills\// && b ~ /\.md$/) || b == "SKILL.md") print > S
    else if (b ~ /\.(sh|py|mjs|js|cjs|ts|ps1)$/) print > C
  }' "$W/all"
: > "$W/rows"
for p in rules skills checks; do
  [ -s "$W/$p" ] || continue
  (cd "$T" && tr '\n' '\000' < "$W/$p" | xargs -0 wc -l 2>/dev/null) \
    | awk -v p="$p" '{ n = $1; sub(/^ *[0-9]+ /, ""); if ($0 != "total") printf "%s\t%s\t%s\n", p, n, $0 }' >> "$W/rows"
done

sum() { awk -F'\t' -v p="$1" '$1 == p { s += $2 } END { print s + 0 }' "$W/rows"; }
cnt() { awk -F'\t' -v p="$1" '$1 == p { n++ } END { print n + 0 }' "$W/rows"; }
rules=$(sum rules); skills=$(sum skills); checks=$(sum checks)
files=$(awk 'END { print NR + 0 }' "$W/rows")

was() {  # the number this part had in the last record's SIZE line
  [ -n "$LAST" ] && [ -f "$LAST" ] || return 0
  grep -o "SIZE rules=[0-9]* skills=[0-9]* checks=[0-9]* files=[0-9]*" "$LAST" | tail -1 | tr ' ' '\n' | awk -F= -v k="$1" '$1 == k { print $2 }'
}
line() {  # part, lines, files
  w="$(was "$1")"
  if [ -n "$w" ]; then
    d=$(( $2 - w ))
    pct=$(awk -v a="$2" -v b="$w" 'BEGIN { if (b > 0) printf "%+.0f%%", (a - b) * 100 / b; else print "new" }')
    printf '  %-7s %7s lines in %5s files   (last audit %s, %+d, %s)\n' "$1" "$2" "$3" "$w" "$d" "$pct"
  else
    printf '  %-7s %7s lines in %5s files\n' "$1" "$2" "$3"
  fi
}
echo "size: the parts that grow when a fix gets added"
line rules "$rules" "$(cnt rules)"
line skills "$skills" "$(cnt skills)"
line checks "$checks" "$(cnt checks)"
[ -n "$LAST" ] && [ -z "$(was rules)" ] && echo "  (the last record has no SIZE line, so this run is the size baseline)"
echo "the 10 biggest of them:"
sort -t "$(printf '\t')" -k2,2nr "$W/rows" | head -10 | awk -F'\t' '{ printf "  %7s  %-7s %s\n", $2, $1, $3 }'
aside=$( [ -s "$W/aside" ] && awk 'END { print NR + 0 }' "$W/aside" || echo 0 )
[ "$aside" -gt 0 ] && echo "set aside: $aside machine built or borrowed files (build, dist, vendor, bundles, toolkits), not counted"
echo "SIZE rules=$rules skills=$skills checks=$checks files=$files"
exit 0
