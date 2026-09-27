#!/usr/bin/env bash
# placeholders.sh - 4R audit, layer 1, question 5. Read only.
#
# Usage:  bash placeholders.sh <target folder>
#
# Counts the lines holding an unfilled slot in every markdown, text and html file: {{slots}}, [YOUR ...],
# TODO, TBD, lorem ipsum, NOT FILLED IN, <PRODUCT NAME>. Files under a folder named
# like a template (template, templates, _templates, skeleton) are counted apart,
# because a template is supposed to hold slots.
#
# Exit 0 = no slots outside template folders. Exit 1 = at least 1.

set -u
T="${1:?usage: bash placeholders.sh <target folder>}"
[ -d "$T" ] || { echo "placeholders: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"
RX='\{\{[^}]{1,80}\}\}|\[YOUR [^]]{1,80}\]|(^|[^A-Za-z])TODO([^A-Za-z]|$)|(^|[^A-Za-z])TBD([^A-Za-z]|$)|[Ll]orem ipsum|NOT FILLED IN|<PRODUCT NAME>'

counts="$(grep -rEoc --include='*.md' --include='*.txt' --include='*.html' \
          --exclude-dir=.git --exclude-dir=node_modules "$RX" "$T" 2>/dev/null | awk -F: '$NF>0')"

live=0; livefiles=0; tpl=0; tplfiles=0; lines=""
while IFS= read -r c; do
  [ -z "$c" ] && continue
  n="${c##*:}"; f="${c%:*}"; rel="${f#$T/}"
  case "/$rel" in
    */template/*|*/templates/*|*/_templates/*|*/skeleton/*|*-skeleton/*) tpl=$((tpl + n)); tplfiles=$((tplfiles + 1)) ;;
    *) live=$((live + n)); livefiles=$((livefiles + 1)); lines="$lines
$n	$rel" ;;
  esac
done <<< "$counts"

echo "SLOTS   $live lines with an unfilled slot, in $livefiles files outside template folders"
printf '%s\n' "$lines" | sed '/^$/d' | sort -rn | head -25 | awk -F'\t' '{printf "  slots   %4d  %s\n", $1, $2}'
[ "$livefiles" -gt 25 ] && echo "  (top 25 of $livefiles files shown)"
echo "        $tpl more lines in $tplfiles template files, where slots belong"

[ "$live" -eq 0 ] && exit 0
exit 1
