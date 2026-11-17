#!/usr/bin/env bash
# plant-limit.sh - the wall on how many NEW tests a 4R audit may plant. Born v1.6.0.
#
# Why: the rule "plant new tests only where something changed" lived in a sentence. A fix
# pass changes a guard, so the next audit called that "changed" and planted more, every run.
# 1 buyer's 3rd audit planted 955 mistakes. This script is the count, so the rule is no
# longer a sentence.
#
# The law this script holds:
#   FIRST audit of a folder   up to 4 new tests for each promise, 40 at the most.
#   EVERY later audit         0 new tests. The saved tests get replayed, unchanged.
#                             A guard that changed is tested by the replay. A changed guard
#                             NEVER earns new tests, no matter who changed it.
#   The only 2 ways a later audit plants anything:
#     a promise that has no saved test at all     up to 4 new tests for that promise
#     a hole the owner named, in the owner's words  up to 2 new tests for each, 5 holes at the most
#   A later audit never plants more than 20 new tests in total.
#   A saved test is never rewritten and never removed.
#
# Usage:
#   bash plant-limit.sh budget <results-home> <run> <promises> [--new-promise "name"]... [--owner-hole "the owner's words"]...
#   bash plant-limit.sh check  <results-home> <run>
#
#   <run> is the run's own name: the date, like 2026-11-17, or 2026-11-17-2 for a 2nd run that day.
#   budget runs BEFORE layer 3 plants anything. check runs BEFORE the report is written.
#
# The saved list is <results-home>/4r-tests/tests.tsv, 1 test on 1 line, 7 parts with a tab between:
#   id  run  promise  kind  expect  reason  input
#   kind = mistake, clean, skip or shape.  expect = block or pass.
#   reason = first, new-promise, owner-hole, or legacy (a test an older version saved).
#   A line that starts with # is a note.
#
# Exit 0 = inside the limit. Exit 1 = over the limit, or a saved test changed. Exit 2 = used wrong.
# Exit 3 = older saved tests have no list yet (write the list, then run budget again).

set -u
PER_PROMISE=4; FIRST_MAX=40; PER_HOLE=2; HOLES_MAX=5; LATER_MAX=20

die2() { echo "plant-limit: $1" >&2; exit 2; }
sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -d' ' -f1; else shasum -a 256 | cut -d' ' -f1; fi; }
data() { [ -f "$1" ] && grep -v '^#' "$1" | grep -v '^[[:space:]]*$' || true; }

mode="${1:-}"; home="${2:-}"; run="${3:-}"
[ -n "$mode" ] && [ -n "$home" ] && [ -n "$run" ] || die2 "usage: plant-limit.sh budget|check <results-home> <run> ..."
printf '%s' "$run" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}(-[0-9]+)?$' || die2 "the run name must be a date like 2026-11-17 or 2026-11-17-2"
T="$home/4r-tests"; LIST="$T/tests.tsv"; BUD="$T/budget-$run.txt"

others() { data "$LIST" | awk -F'\t' -v r="$run" '$2 != r'; }
mine()   { data "$LIST" | awk -F'\t' -v r="$run" '$2 == r'; }

if [ "$mode" = "budget" ]; then
  promises="${4:-}"
  printf '%s' "$promises" | grep -Eq '^[0-9]+$' || die2 "give the number of promises found in layer 1, as digits"
  shift 4
  newp=""; holes=""; nh=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --new-promise) [ $# -ge 2 ] || die2 "--new-promise needs a name"; newp="${newp}$2
"; shift 2 ;;
      --owner-hole)  [ $# -ge 2 ] || die2 "--owner-hole needs the owner's words"; holes="${holes}$2
"; nh=$((nh + 1)); shift 2 ;;
      *) die2 "do not know: $1" ;;
    esac
  done

  if [ -f "$BUD" ]; then
    echo "PLANT BUDGET already set for run $run. A budget is set 1 time and never raised:"
    grep -E '^(kind|allowed)=' "$BUD" | tr '\n' ' '; echo
    exit 0
  fi

  mkdir -p "$T"
  have="$(data "$LIST" | wc -l | tr -d ' ')"
  records="$(find "$home" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  stuff="$(find "$T" -mindepth 1 ! -name 'tests.tsv' ! -name 'budget-*.txt' ! -name 'sealed-*.txt' 2>/dev/null | wc -l | tr -d ' ')"
  seal="$(ls "$T"/sealed-*.txt 2>/dev/null | sort | tail -1)"

  if [ "$have" -eq 0 ] && { [ "$records" -gt 0 ] || [ "$stuff" -gt 0 ]; }; then
    echo "LIST THE SAVED TESTS FIRST. This folder was audited before, and its saved tests have no list."
    echo "Write every saved test into $LIST, 1 line each, with its OLD run date and the reason legacy."
    echo "Add no test that was not already saved. Then run budget again. No new test is allowed until then."
    exit 3
  fi

  if [ -n "$seal" ]; then
    want="$(grep '^sha=' "$seal" | cut -d= -f2)"; got="$(data "$LIST" | sha)"
    if [ "$want" != "$got" ]; then
      echo "SAVED TESTS CHANGED since the last run sealed them ($(basename "$seal")). A saved test is never rewritten, removed or added between runs."
      echo "Put the list back the way the last run left it. No budget was set."
      exit 1
    fi
  fi

  if [ "$have" -eq 0 ]; then
    kind="FIRST"; allowed=$((promises * PER_PROMISE)); [ "$allowed" -gt "$FIRST_MAX" ] && allowed=$FIRST_MAX
    newp=""; holes=""; nh=0
  else
    kind="LATER"
    np=0; kept=""
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      if data "$LIST" | awk -F'\t' -v p="$p" '$3 == p { f = 1 } END { exit f ? 0 : 1 }'; then
        echo "not new: the promise \"$p\" already has saved tests, so it earns 0 new tests"
      else np=$((np + 1)); kept="${kept}${p}
"; fi
    done <<EOF
$newp
EOF
    newp="$kept"
    [ "$nh" -gt "$HOLES_MAX" ] && { echo "only $HOLES_MAX owner holes count in 1 run. The rest wait for the next run."; nh=$HOLES_MAX; }
    allowed=$((np * PER_PROMISE + nh * PER_HOLE)); [ "$allowed" -gt "$LATER_MAX" ] && allowed=$LATER_MAX
    [ -z "$seal" ] && echo "ADOPTED $have saved tests from an older version. They get replayed. None of them counts as new."
  fi

  {
    echo "run=$run"; echo "kind=$kind"; echo "allowed=$allowed"; echo "per_promise=$PER_PROMISE"; echo "holes=$nh"
    echo "old_count=$(others | wc -l | tr -d ' ')"; echo "old_sha=$(others | sha)"
    printf '%s' "$newp" | sed 's/^/new_promise=/'
    printf '%s' "$holes" | head -n "$HOLES_MAX" | sed 's/^/owner_hole=/'
  } > "$BUD"

  echo "PLANT BUDGET run=$run kind=$kind new tests allowed=$allowed"
  if [ "$kind" = "LATER" ]; then
    echo "Replay the $have saved tests, unchanged. A guard that changed is tested by the replay and earns 0 new tests."
    [ "$allowed" -eq 0 ] && echo "Plant NOTHING new this run."
  else
    echo "First audit of this folder: up to $PER_PROMISE new tests for each promise, $allowed in total. Save every 1 in the list."
  fi
  exit 0
fi

if [ "$mode" = "check" ]; then
  [ -f "$BUD" ] || { echo "NO BUDGET. plant-limit.sh budget never ran for run $run, so no new test was allowed. The report cannot be written."; exit 1; }
  kind="$(grep '^kind=' "$BUD" | cut -d= -f2)"; allowed="$(grep '^allowed=' "$BUD" | cut -d= -f2)"
  nh="$(grep '^holes=' "$BUD" | cut -d= -f2)"
  fails=0
  if [ "$(others | sha)" != "$(grep '^old_sha=' "$BUD" | cut -d= -f2)" ]; then
    echo "SAVED TESTS CHANGED during this run. Had $(grep '^old_count=' "$BUD" | cut -d= -f2) saved lines, now $(others | wc -l | tr -d ' '). A saved test is never rewritten or removed."
    fails=1
  fi
  new="$(mine | wc -l | tr -d ' ')"
  if [ "$new" -gt "$allowed" ]; then
    echo "OVER THE LIMIT. This run saved $new new tests and $allowed were allowed. Take the extra tests out before the report."
    fails=1
  fi
  badreason="$(mine | awk -F'\t' -v k="$kind" '{ ok = (k == "FIRST") ? ($6 == "first") : ($6 == "new-promise" || $6 == "owner-hole"); if (!ok) print $1 " (" $6 ")" }')"
  if [ -n "$badreason" ]; then
    echo "WRONG REASON on new tests in a $kind run: $(printf '%s' "$badreason" | tr '\n' ' ')"
    fails=1
  fi
  over="$(mine | awk -F'\t' -v m="$PER_PROMISE" '$6 != "owner-hole" { c[$3]++ } END { for (p in c) if (c[p] > m) print p " (" c[p] ")" }')"
  if [ -n "$over" ]; then
    echo "TOO MANY FOR 1 PROMISE (the limit is $PER_PROMISE): $(printf '%s' "$over" | tr '\n' ' ')"
    fails=1
  fi
  if [ "$kind" = "LATER" ]; then
    stray="$(mine | awk -F'\t' '$6 == "new-promise" { print $3 }' | sort -u | while IFS= read -r p; do grep -qxF "new_promise=$p" "$BUD" || echo "$p"; done)"
    [ -n "$stray" ] && { echo "NOT IN THE BUDGET: new tests for a promise the budget never named: $(printf '%s' "$stray" | tr '\n' ' ')"; fails=1; }
    hc="$(mine | awk -F'\t' '$6 == "owner-hole"' | wc -l | tr -d ' ')"
    [ "$hc" -gt $((nh * PER_HOLE)) ] && { echo "TOO MANY OWNER HOLE TESTS: $hc saved, $((nh * PER_HOLE)) allowed for $nh named holes."; fails=1; }
  fi
  loose=0
  for d in "$T"/*"$run"*; do [ -d "$d" ] && loose=$((loose + $(find "$d" -type f 2>/dev/null | wc -l | tr -d ' '))); done
  total="$(data "$LIST" | wc -l | tr -d ' ')"
  if [ "$loose" -gt $((total * 3 + 30)) ]; then
    echo "MORE FILES THAN THE LIST EXPLAINS. This run's test folder holds $loose files and the list holds $total tests. A test that is not on the list was planted off the books."
    fails=1
  fi
  if [ "$fails" -ne 0 ]; then echo "PLANT CHECK run=$run FAILED. The report cannot be written until this passes."; exit 1; fi
  { echo "run=$run"; echo "count=$total"; echo "sha=$(data "$LIST" | sha)"; } > "$T/sealed-$run.txt"
  echo "PLANT CHECK run=$run kind=$kind new=$new of $allowed allowed, saved list=$total tests, OK"
  if [ "$kind" = "LATER" ] && [ "$new" -eq 0 ]; then
    echo "NOTHING NEW WAS PLANTED. Running the audit again replays the same $total tests and finds no new guard holes."
  fi
  grep '^owner_hole=' "$BUD" | sed 's/^owner_hole=/The owner asked for new tests on, in the owner'"'"'s words: /'
  exit 0
fi

die2 "the first word must be budget or check"
