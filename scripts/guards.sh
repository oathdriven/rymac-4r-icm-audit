#!/usr/bin/env bash
# guards.sh - 4R audit, layer 1, question 3. Read only.
#
# Usage:  bash guards.sh <target folder>
#
# Lists everything that actually RUNS, as opposed to what is only written down:
# 1. hooks: every command in the Claude settings files that apply to the target
#    (the user's ~/.claude/settings.json, and the target's own .claude/settings.json
#    and .claude/settings.local.json), with the event each 1 fires on
# 2. check scripts: every script in the target whose name says it checks something
#    (check, guard, lint, validate, gate, test, audit, verify, hook), then a count of
#    every other script
#
# Exit 0 always. This script lists evidence, layer 3 proves whether each guard works.

set -u
# 2026-10-07 (a member found it): a plain "git status" rewrites .git/index and can
# leave an index.lock behind in the folder it reads. This keeps every git call read only.
export GIT_OPTIONAL_LOCKS=0
T="${1:?usage: bash guards.sh <target folder>}"
[ -d "$T" ] || { echo "guards: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"
# a python that actually RUNS, not just a name on the path (on Windows, python3 is often a
# Microsoft Store placeholder that prints nothing and exits 49)
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && [ "$("$c" -c 'print(1)' 2>/dev/null)" = "1" ]; then PY="$c"; break; fi
done

hooks=0
for s in "$HOME/.claude/settings.json" "$T/.claude/settings.json" "$T/.claude/settings.local.json"; do
  [ -f "$s" ] || continue
  if [ -n "$PY" ]; then
    out="$("$PY" - "$s" <<'PYEOF'
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception as e:
    print("  unreadable  " + str(e)); sys.exit(0)
for event, groups in (d.get("hooks") or {}).items():
    for g in groups or []:
        m = g.get("matcher") or "every call"
        for h in g.get("hooks") or []:
            c = (h.get("command") or "").replace("\n", " ")
            print("  hook    %-18s %-22s %s" % (event, m[:22], c[:150]))
PYEOF
)"
  else
    out="$(grep -o '"command": *"[^"]*' "$s" | sed 's/"command": *"/  hook    /')"
  fi
  if [ -n "$out" ]; then
    echo "from $s"
    printf '%s\n' "$out"
    hooks=$((hooks + $(printf '%s\n' "$out" | grep -c '^  hook')))
  fi
done
echo "HOOKS   $hooks commands that run on their own"
# 2026-10-07 (a member found it): run from a cloud sandbox (Cowork, a web session),
# this computer's home folder is not the owner's, so their own hooks are invisible. A 0 there
# would tell them they have no guards when they might. Say it could not see, never 0.
if [ ! -f "$HOME/.claude/settings.json" ]; then
  echo "BLIND   couldn't see the owner's own hooks: this computer has no $HOME/.claude/settings.json"
  echo "        (a cloud sandbox has none). The count above is the target's own settings only."
  echo "        Report the owner's hooks as \"couldn't see\", never as 0."
fi

checks="$(find "$T" \( -name .git -o -name node_modules \) -prune -o -type f \
          \( -name '*.sh' -o -name '*.py' -o -name '*.mjs' -o -name '*.js' -o -name '*.ps1' \) -print 2>/dev/null \
          | grep -iE '(check|guard|lint|valid|gate|test|audit|verify|hook)[^/]*$' | sort)"
nchecks=0
[ -n "$checks" ] && nchecks=$(printf '%s\n' "$checks" | wc -l | tr -d ' ')
echo "CHECKS  $nchecks scripts named like a check"
[ -n "$checks" ] && printf '%s\n' "$checks" | sed "s#^$T/#  check   #" | head -60
[ "$nchecks" -gt 60 ] && echo "  (first 60 of $nchecks shown)"
other=$(find "$T" \( -name .git -o -name node_modules \) -prune -o -type f \
        \( -name '*.sh' -o -name '*.py' -o -name '*.mjs' -o -name '*.ps1' \) -print 2>/dev/null | wc -l | tr -d ' ')
echo "SCRIPTS $other scripts in the tree in all"
exit 0
