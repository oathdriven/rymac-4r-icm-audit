#!/usr/bin/env bash
# routes.sh - 4R audit, layer 1, questions 1 and 2. Read only.
#
# Usage:  bash routes.sh <target folder>
#
# 1. Every path the entry files (CLAUDE.md, AGENTS.md, CONTEXT.md at the top of the
#    target) name in backticks is checked on disk. A path is a backticked token with a
#    slash in it or a file ending (.md .sh .py and so on). Placeholders (<slug>, {{x}},
#    [brand]), globs, web addresses and commands with spaces are skipped, because
#    nothing can resolve them. A name that is not at the top but exists elsewhere in
#    the target is a SHORT name, counted apart: the name resolves, just not from the top.
# 2. Every top level folder is checked for a mention anywhere in those entry files.
#
# Exit 0 = every route resolves and every top folder is named. Exit 1 = at least 1
# dead route or unnamed folder. Exit 2 = no target, or no entry file at its top.

set -u
# 2026-10-07 (a member found it): a plain "git status" rewrites .git/index and can
# leave an index.lock behind in the folder it reads. This keeps every git call read only.
export GIT_OPTIONAL_LOCKS=0
T="${1:?usage: bash routes.sh <target folder>}"
[ -d "$T" ] || { echo "routes: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"

entries=()
for f in CLAUDE.md AGENTS.md CONTEXT.md; do [ -f "$T/$f" ] && entries+=("$f"); done
[ "${#entries[@]}" -eq 0 ] && { echo "routes: no CLAUDE.md, AGENTS.md or CONTEXT.md at the top of $T"; exit 2; }

EXT='\.(md|sh|py|mjs|js|cjs|ts|tsx|json|jsonl|html|txt|yml|yaml|csv|ps1|toml|xml|svg|png|jpg|zip)$'
# a web address written without http (allodra.ai/affiliate, site.vercel.app/page) is not a route
DOMAIN='^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.(com|ai|app|io|net|org|co|dev|so|xyz|us|me)(/|$)'
# every file and folder in the target, once, so a short name can be looked up (saved files in a git repo)
ALL="$(mktemp)"
if git -C "$T" rev-parse --show-toplevel >/dev/null 2>&1; then
  (cd "$T" && git ls-files) > "$ALL"
else
  (cd "$T" && find . \( -name .git -o -name node_modules \) -prune -o -print | sed 's#^\./##') > "$ALL"
fi
awk -F/ '{p=""; for(i=1;i<NF;i++){p=p $i "/"; print p}}' "$ALL" | sort -u >> "$ALL"
trap 'rm -f "$ALL"' EXIT
total=0; dead=0; deadlines=""; short=0; shortlines=""
seen=""
for f in "${entries[@]}"; do
  while IFS= read -r hit; do
    ln="${hit%%:*}"; tok="${hit#*:}"; tok="${tok#\`}"; tok="${tok%\`}"
    case "$tok" in *'<'*|*'{{'*|*'*'*|*'$'*|*'['*|http*|www.*|~*|/*|*' '*|*'|'*|*'='*) continue ;; esac
    printf '%s' "$tok" | grep -qiE "$DOMAIN" && continue
    tok="${tok%%#*}"                              # drop an #anchor
    tok="$(printf '%s' "$tok" | sed -E 's/:[0-9]+(-[0-9]+)?$//')"   # drop a :line suffix
    case "$tok" in */*) ;; *) printf '%s' "$tok" | grep -qiE "$EXT" || continue ;; esac
    [ -z "$tok" ] && continue
    key="$f|$tok"
    case "$seen" in *"<$key>"*) continue ;; esac
    seen="$seen<$key>"
    total=$((total + 1))
    if [ ! -e "$T/$tok" ]; then
      # not at the top: a short name written without the folder, found elsewhere?
      where="$(awk -v t="${tok%/}" '{ s=$0; sub(/\/$/, "", s); if (s == t || (length(s) > length(t) && substr(s, length(s) - length(t)) == "/" t)) { n++; if (!f) f=$0 } } END { if (n) print f (n > 1 ? "  (and " n-1 " more places, so an agent has to guess)" : "") }' "$ALL")"
      if [ -n "$where" ]; then
        short=$((short + 1))
        shortlines="$shortlines
  short   $f:$ln  \`$tok\` is at $where"
      else
        dead=$((dead + 1))
        deadlines="$deadlines
  dead    $f:$ln  \`$tok\`"
      fi
    fi
  done < <(grep -no '`[^`]*`' "$T/$f" 2>/dev/null)
done

echo "ROUTES  $((total - dead)) of $total named paths resolve (entry files: ${entries[*]})"
[ -n "$deadlines" ] && printf '%s\n' "$deadlines" | sed '/^$/d'
echo "        $short of those are short names, written without the folder and found elsewhere"
[ -n "$shortlines" ] && printf '%s\n' "$shortlines" | sed '/^$/d'

# 2. rooms: every top level folder, named or not
alltext="$(cat "${entries[@]/#/$T/}" 2>/dev/null)"
rooms=0; orphans=0; orphanlines=""
for d in "$T"/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  case "$name" in .*|node_modules) continue ;; esac
  rooms=$((rooms + 1))
  if ! printf '%s' "$alltext" | grep -qF "$name"; then
    orphans=$((orphans + 1))
    orphanlines="$orphanlines
  orphan  $name/"
  fi
done
echo "ROOMS   $((rooms - orphans)) of $rooms top folders are named in the entry files"
[ -n "$orphanlines" ] && printf '%s\n' "$orphanlines" | sed '/^$/d'

[ "$dead" -eq 0 ] && [ "$orphans" -eq 0 ] && exit 0
exit 1
