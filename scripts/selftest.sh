#!/usr/bin/env bash
# selftest.sh - proves every 4R script on planted mistakes before anybody trusts it.
# The audit's own layer 3, turned on the audit.
#
# Usage:  bash selftest.sh          (from anywhere)
#
# Builds 2 throwaway workspaces in a temp folder:
#   BAD    a dead route, an unnamed folder, an unfilled slot, a key shaped string,
#          a settings file, a nested repo with unsaved work, a check script
#   CLEAN  the same shape with none of the mistakes
# Every script must fire on BAD and stay quiet on CLEAN. The fake key is built while
# the test runs, so no key shaped text is ever saved in this repo.
#
# Exit 0 = every assertion held. Exit 1 = a script is blind or jumpy.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
W="$(mktemp -d 2>/dev/null || mktemp -d -t 4r)"
trap 'rm -rf "$W"' EXIT
fails=0; n=0
ok()   { n=$((n + 1)); echo "ok    $1"; }
bad()  { n=$((n + 1)); fails=$((fails + 1)); echo "WRONG $1"; }
expect_exit() { [ "$2" = "$3" ] && ok "$1 (exit $3)" || bad "$1 (wanted exit $3, got $2)"; }
expect_has()  { printf '%s' "$2" | grep -qF -- "$3" && ok "$1" || bad "$1 (missing: $3)"; }
expect_not()  { printf '%s' "$2" | grep -qF -- "$3" && bad "$1 (should not print: $3)" || ok "$1"; }

# ---------- BAD ----------
B="$W/bad"; mkdir -p "$B/docs" "$B/orphan" "$B/scripts" "$B/inner"
printf '# Bad\n\nRead `docs/a.md` first, then `docs/missing.md`. Checks live in `scripts/`.\n' > "$B/CLAUDE.md"
printf 'Hello {{client name}}.\n' > "$B/docs/a.md"
FAKE="sk-ant-$(printf 'A%.0s' $(seq 1 30))"
printf 'key = %s\n' "$FAKE" > "$B/docs/notes.md"
printf 'API_KEY=x\n' > "$B/.env"
printf 'x\n' > "$B/orphan/x.md"
printf '#!/usr/bin/env bash\nexit 0\n' > "$B/scripts/check-thing.sh"
(cd "$B/inner" && git init -q . && printf 'x\n' > draft.md)

out="$(bash "$HERE/routes.sh" "$B" 2>&1)"; rc=$?
expect_exit "routes fires on a dead route" "$rc" 1
expect_has  "routes counts 2 of 3 resolving" "$out" "2 of 3 named paths resolve"
expect_has  "routes names the dead route with its line" "$out" "CLAUDE.md:3"
expect_has  "routes names the unnamed folder" "$out" "orphan  orphan/"

out="$(bash "$HERE/placeholders.sh" "$B" 2>&1)"; rc=$?
expect_exit "placeholders fires on a slot" "$rc" 1
expect_has  "placeholders names the file" "$out" "docs/a.md"

out="$(bash "$HERE/secrets.sh" "$B" 2>&1)"; rc=$?
expect_exit "secrets fires on a key" "$rc" 1
expect_has  "secrets names the kind" "$out" "AI key (Anthropic)"
expect_has  "secrets lists the settings file" "$out" "ENVS    1 settings"
expect_not  "secrets never prints the full key" "$out" "$FAKE"

out="$(bash "$HERE/nested-repos.sh" "$B" 2>&1)"; rc=$?
expect_exit "nested-repos fires on unsaved work" "$rc" 1
expect_has  "nested-repos names the folder" "$out" "inner/"
expect_has  "nested-repos sees no online copy" "$out" "NO ONLINE COPY"

out="$(bash "$HERE/guards.sh" "$B" 2>&1)"; rc=$?
expect_exit "guards always lists" "$rc" 0
expect_has  "guards finds the check script" "$out" "check-thing.sh"

D="$W/scratch"
out="$(bash "$HERE/copy-target.sh" "$B" "$D" 2>&1)"; rc=$?
expect_exit "copy-target copies" "$rc" 0
[ -f "$D/docs/a.md" ] && ok "copy-target copied a nested file" || bad "copy-target lost docs/a.md"
out="$(bash "$HERE/copy-target.sh" "$B" "$B/inside" 2>&1)"; rc=$?
expect_exit "copy-target refuses a scratch inside the target" "$rc" 2
[ -d "$B/inside" ] && bad "copy-target left a folder inside the target" || ok "copy-target left the target untouched"

# ---------- CLEAN ----------
C="$W/clean"; mkdir -p "$C/docs"
printf '# Clean\n\nRead `docs/a.md` first. Everything lives in `docs/`.\n' > "$C/CLAUDE.md"
printf 'Hello Dana.\n' > "$C/docs/a.md"

out="$(bash "$HERE/routes.sh" "$C" 2>&1)"; rc=$?
expect_exit "routes quiet on a clean map" "$rc" 0
expect_has  "routes counts 2 of 2" "$out" "2 of 2 named paths resolve"
out="$(bash "$HERE/placeholders.sh" "$C" 2>&1)"; rc=$?
expect_exit "placeholders quiet on filled files" "$rc" 0
out="$(bash "$HERE/secrets.sh" "$C" 2>&1)"; rc=$?
expect_exit "secrets quiet with no keys" "$rc" 0
out="$(bash "$HERE/nested-repos.sh" "$C" 2>&1)"; rc=$?
expect_exit "nested-repos quiet with no nested repo" "$rc" 0

echo
if [ "$fails" -eq 0 ]; then echo "selftest: $n of $n held. Every script fires on the mistake and stays quiet on the clean case."; exit 0; fi
echo "selftest: $fails of $n WRONG. Do not trust the audit until this passes."; exit 1
