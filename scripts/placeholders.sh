#!/usr/bin/env bash
# placeholders.sh - 4R audit, layer 1, question 5. Read only.
#
# Usage:  bash placeholders.sh <target folder>
#
# Finds lines holding an unfilled slot: {{slots}}, [YOUR ...], TODO, TBD, lorem ipsum,
# NOT FILLED IN, <PRODUCT NAME>. The finding is the slots in ENTRY files, the files an
# agent reads first on every run: CLAUDE.md, AGENTS.md, CONTEXT.md, README.md, SKILL.md.
# Slots anywhere else are counted as background, because a page draft or a customer's
# own file can hold slots on purpose.
#
# Never counted: archives (_archive, archive), build output (dist, build), .git,
# node_modules, and templates (a folder named template, templates, _templates or
# skeleton, or a file with "template" in its name), because a template is supposed
# to hold slots.
#
# Exit 0 = no slot in any entry file. Exit 1 = at least 1.

set -u
# 2026-10-07 (a member found it): a plain "git status" rewrites .git/index and can
# leave an index.lock behind in the folder it reads. This keeps every git call read only.
export GIT_OPTIONAL_LOCKS=0
T="${1:?usage: bash placeholders.sh <target folder>}"
[ -d "$T" ] || { echo "placeholders: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"

# 1 awk pass over every candidate file. A slot shown inside `backticks` or inside a ``` code
# block is documentation (a skill explaining the slots the skill fills), never a gap.
AWKRX='\{\{[^}]+\}\}|\[YOUR [^]]+\]|(^|[^A-Za-z])TODO([^A-Za-z]|$)|(^|[^A-Za-z])TBD([^A-Za-z]|$)|[Ll]orem ipsum|NOT FILLED IN|<PRODUCT NAME>'
counts="$(find "$T" \( -name .git -o -name node_modules -o -name _archive -o -name archive -o -name dist -o -name build \) -prune -o \
          -type f \( -name '*.md' -o -name '*.txt' -o -name '*.html' \) -print0 2>/dev/null \
          | xargs -0 awk -v rx="$AWKRX" '
              FNR == 1 { fence = 0 }
              /^[[:space:]]*```/ { fence = !fence; next }
              fence { next }
              { line = $0; gsub(/`[^`]*`/, "", line); if (line ~ rx) c[FILENAME]++ }
              END { for (f in c) print f ":" c[f] }' 2>/dev/null)"

entry=0; entryfiles=0; entrylines=""; other=0; otherfiles=0; otherlines=""; tpl=0; tplfiles=0
while IFS= read -r c; do
  [ -z "$c" ] && continue
  n="${c##*:}"; f="${c%:*}"; rel="${f#$T/}"; base="${rel##*/}"
  case "/$rel" in
    */template/*|*/templates/*|*/_templates/*|*/skeleton/*|*-skeleton/*|*template*) tpl=$((tpl + n)); tplfiles=$((tplfiles + 1)); continue ;;
  esac
  case "$base" in
    CLAUDE.md|AGENTS.md|CONTEXT.md|README.md|SKILL.md)
      entry=$((entry + n)); entryfiles=$((entryfiles + 1)); entrylines="$entrylines
$n	$rel" ;;
    *)
      other=$((other + n)); otherfiles=$((otherfiles + 1)); otherlines="$otherlines
$n	$rel" ;;
  esac
done <<< "$counts"

echo "SLOTS   $entry lines with an unfilled slot in $entryfiles ENTRY files (read first, every run)"
printf '%s\n' "$entrylines" | sed '/^$/d' | sort -rn | head -25 | awk -F'\t' '{printf "  entry   %4d  %s\n", $1, $2}'
echo "        background: $other more lines in $otherfiles other files, top 10:"
printf '%s\n' "$otherlines" | sed '/^$/d' | sort -rn | head -10 | awk -F'\t' '{printf "  other   %4d  %s\n", $1, $2}'
echo "        $tpl more lines in $tplfiles template files, where slots belong"

[ "$entry" -eq 0 ] && exit 0
exit 1
