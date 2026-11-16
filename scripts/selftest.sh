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
printf 'Notes are in `notes.md`. Name files like `[brand]-[slug].md`. The site is `example.com/page`.\n' >> "$B/CLAUDE.md"
printf 'Hello {{client name}}.\n' > "$B/docs/a.md"
printf 'Owner: {{your name}}\n' >> "$B/CLAUDE.md"
printf 'Hi {{name}}\n' > "$B/docs/page-template.html"
FAKE="sk-ant-$(printf 'A%.0s' $(seq 1 30))"
printf 'key = %s\n' "$FAKE" > "$B/docs/notes.md"
printf 'API_KEY=x\n' > "$B/.env"
printf 'x\n' > "$B/orphan/x.md"
printf '#!/usr/bin/env bash\nexit 0\n' > "$B/scripts/check-thing.sh"
(cd "$B/inner" && git init -q . && printf 'x\n' > draft.md)

out="$(bash "$HERE/routes.sh" "$B" 2>&1)"; rc=$?
expect_exit "routes fires on a dead route" "$rc" 1
expect_has  "routes counts 3 of 4 resolving" "$out" "3 of 4 named paths resolve"
expect_has  "routes names the dead route with its line" "$out" "dead    CLAUDE.md:3"
expect_has  "routes names the unnamed folder" "$out" "orphan  orphan/"
expect_has  "routes finds a short name where the short name lives" "$out" '`notes.md` is at docs/notes.md'
expect_not  "routes skips a naming example in brackets" "$out" "[brand]"
expect_not  "routes skips a web address" "$out" "example.com"

out="$(bash "$HERE/placeholders.sh" "$B" 2>&1)"; rc=$?
expect_exit "placeholders fires on a slot" "$rc" 1
expect_has  "placeholders names the entry file" "$out" "entry      1  CLAUDE.md"
expect_has  "placeholders counts a page draft as background" "$out" "docs/a.md"
expect_not  "placeholders leaves a file named template alone" "$out" "page-template.html"
mkdir -p "$W/doc"; printf '# Doc\n\nThe page fills `{{HEADLINE}}` for you.\n\n```\n{{EXAMPLE}}\n```\n' > "$W/doc/SKILL.md"
out="$(bash "$HERE/placeholders.sh" "$W/doc" 2>&1)"; rc=$?
expect_exit "placeholders leaves slots shown as code alone" "$rc" 0
mkdir -p "$W/sp"; printf '# Sp\n\nOwner: {{your name}}\n' > "$W/sp/README.md"; mkdir -p "$W/sp/my notes"; printf 'Hi {{x}}\n' > "$W/sp/my notes/draft page.md"
out="$(bash "$HERE/placeholders.sh" "$W/sp" 2>&1)"
expect_has  "placeholders reads a file with spaces in its name" "$out" "my notes/draft page.md"

out="$(bash "$HERE/secrets.sh" "$B" 2>&1)"; rc=$?
expect_exit "secrets fires on a key" "$rc" 1
expect_has  "secrets names the kind" "$out" "AI key (Anthropic)"
expect_has  "secrets lists the settings file" "$out" "ENVS    1 settings"
expect_not  "secrets never prints the full key" "$out" "$FAKE"
TW="$(printf '%s%s' 0123456789abcdef 0123456789abcdef)"   # built at run time so this file holds no token shape
mkdir -p "$W/tw/.claude"; printf '{"allow":["Bash(sed -i s/^TWILIO_AUTH_TOKEN=.*/TWILIO_AUTH_TOKEN=%s/ .env.local)"]}\n' "$TW" > "$W/tw/.claude/settings.local.json"
out="$(bash "$HERE/secrets.sh" "$W/tw" 2>&1)"; rc=$?
expect_exit "secrets fires on a token pasted into an allow rule" "$rc" 1
expect_has  "secrets names a Twilio token" "$out" "phone app token (Twilio)"
NS="$(printf '%s%s' Zq8kLmN3pR7tVx2y B5cD9fG4hJ6kM1nP)"
mkdir -p "$W/ns"; printf 'BUILD_GRANT_SECRET=%s\n' "$NS" > "$W/ns/notes.md"
out="$(bash "$HERE/secrets.sh" "$W/ns" 2>&1)"; rc=$?
expect_has  "secrets names a secret saved under its own name" "$out" "named secret in a file"
mkdir -p "$W/nc"; printf 'Set BUILD_GRANT_SECRET in Vercel. Never paste the value here.\n' > "$W/nc/notes.md"
out="$(bash "$HERE/secrets.sh" "$W/nc" 2>&1)"; rc=$?
expect_exit "secrets quiet on a secret named but not written" "$rc" 0
mkdir -p "$W/nf"; printf 'process.env.X_SECRET = "whsec_test_only_not_real_000000";\n' > "$W/nf/a.test.mjs"
out="$(bash "$HERE/secrets.sh" "$W/nf" 2>&1)"; rc=$?
expect_exit "secrets quiet on a value that names itself a test fake" "$rc" 0

out="$(bash "$HERE/nested-repos.sh" "$B" 2>&1)"; rc=$?
expect_exit "nested-repos fires on unsaved work" "$rc" 1
expect_has  "nested-repos names the folder" "$out" "inner/"
expect_has  "nested-repos sees no online copy" "$out" "NO ONLINE COPY"

out="$(bash "$HERE/guards.sh" "$B" 2>&1)"; rc=$?
expect_exit "guards always lists" "$rc" 0
expect_has  "guards finds the check script" "$out" "check-thing.sh"
mkdir -p "$B/.claude"
printf '{"hooks":{"PreToolUse":[{"matcher":"Write","hooks":[{"type":"command","command":"bash scripts/check-thing.sh"}]}]}}' > "$B/.claude/settings.json"
out="$(HOME="$W/nohome" bash "$HERE/guards.sh" "$B" 2>&1)"
expect_has  "guards reads a hook out of the target's settings" "$out" "HOOKS   1 commands"
expect_has  "guards says it could not see the owner's hooks on a computer with none" "$out" "BLIND"

# 2026-10-07: the audit never writes into the target, not even git's own cache
find "$B" -path '*/.git/*' -prune -o -type f -print | while read -r f; do touch "$f"; done
before="$(find "$B" -path '*/.git/index*' -type f -exec md5sum {} + | sort)"
NESTED_OFFLINE=1 bash "$HERE/nested-repos.sh" "$B" >/dev/null 2>&1
after="$(find "$B" -path '*/.git/index*' -type f -exec md5sum {} + | sort)"
[ "$before" = "$after" ] && ok "nested-repos leaves every .git/index untouched" || bad "nested-repos rewrote a .git/index in the target"

D="$W/scratch"
out="$(bash "$HERE/copy-target.sh" "$B" "$D" 2>&1)"; rc=$?
expect_exit "copy-target copies" "$rc" 0
[ -f "$D/docs/a.md" ] && ok "copy-target copied a nested file" || bad "copy-target lost docs/a.md"
# 2026-11-14, v1.5.4: a file left out for size is named, not only counted
# 2026-11-16 (a Mac member found it): a Mac counts every file as at least 4 KB on the disk, so the limit here is 4 KB and the big file is 9000 bytes.
head -c 9000 /dev/zero > "$B/big-art.bin"
out="$(bash "$HERE/copy-target.sh" "$B" "$W/scratch-small" 4 2>&1)"; rc=$?
expect_has  "copy-target names a file it left out for size" "$out" "LEFT OUT"
expect_has  "copy-target names big-art.bin" "$out" "big-art.bin"
grep -q "big-art.bin" "$W/scratch-small-left-out.txt" 2>/dev/null && ok "copy-target writes the left out list beside the copy" || bad "copy-target wrote no left out list"
[ -f "$W/scratch-small/big-art.bin" ] && bad "copy-target copied a file over the size limit" || ok "copy-target kept the big file out of the copy"
[ -f "$W/scratch-small/scratch-small-left-out.txt" ] && bad "copy-target put the left out list inside the copy" || ok "copy-target kept the list out of the copy"
# 2026-11-14, v1.5.5: the snapshot list (a fingerprint per file, a reason per file left out)
SNAP="$W/scratch-small-snapshot.tsv"
[ -f "$SNAP" ] && ok "copy-target writes the snapshot list beside the copy" || bad "copy-target wrote no snapshot list"
[ -f "$W/scratch-small/scratch-small-snapshot.tsv" ] && bad "copy-target put the snapshot list inside the copy" || ok "copy-target kept the snapshot list out of the copy"
grep -q "^IN	copied	[0-9]*	[0-9a-f]\{64\}	CLAUDE.md$" "$SNAP" 2>/dev/null && ok "snapshot list gives an IN file a 64 character fingerprint" || bad "snapshot list has no fingerprint line for CLAUDE.md"
grep -q "^LEFT OUT	over 4 KB	[0-9]*	[0-9a-f]\{64\}	big-art.bin$" "$SNAP" 2>/dev/null && ok "snapshot list gives the left out file its reason and fingerprint" || bad "snapshot list has no reason line for big-art.bin"
out="$(bash "$HERE/verify-snapshot.sh" "$W/scratch-small" "$SNAP" in 2>&1)"; rc=$?
expect_exit "verify-snapshot passes the untouched copy" "$rc" 0
out="$(bash "$HERE/verify-snapshot.sh" "$B" "$SNAP" 2>&1)"; rc=$?
expect_exit "verify-snapshot passes the untouched target, left out files too" "$rc" 0
cp "$W/scratch-small/CLAUDE.md" "$W/claude.keep"; printf 'x\n' >> "$W/scratch-small/CLAUDE.md"
out="$(bash "$HERE/verify-snapshot.sh" "$W/scratch-small" "$SNAP" in 2>&1)"; rc=$?
expect_exit "verify-snapshot fires on 1 changed file" "$rc" 1
expect_has  "verify-snapshot names the changed file" "$out" "CHANGED  CLAUDE.md"
cp "$W/claude.keep" "$W/scratch-small/CLAUDE.md"
out="$(bash "$HERE/verify-snapshot.sh" "$W/scratch-small" "$SNAP" in 2>&1)"; rc=$?
expect_exit "verify-snapshot goes quiet once the file is put back" "$rc" 0
mv "$W/scratch-small/docs/a.md" "$W/a.keep"
out="$(bash "$HERE/verify-snapshot.sh" "$W/scratch-small" "$SNAP" in 2>&1)"; rc=$?
expect_exit "verify-snapshot fires on 1 missing file" "$rc" 1
expect_has  "verify-snapshot names the missing file" "$out" "MISSING  docs/a.md"
mv "$W/a.keep" "$W/scratch-small/docs/a.md"
printf '# empty\n' > "$W/empty-snapshot.tsv"
out="$(bash "$HERE/verify-snapshot.sh" "$W/scratch-small" "$W/empty-snapshot.tsv" 2>&1)"; rc=$?
expect_exit "verify-snapshot refuses a list with no fingerprints (0 of 0 is not a pass)" "$rc" 2
# a git folder: an ignore rule gets 1 line with the rule, never every file inside
G="$W/gitted"; mkdir -p "$G/keep" "$G/vendor/deep"
printf 'vendor/\n' > "$G/.gitignore"; printf 'k\n' > "$G/keep/k.md"; printf 'v\n' > "$G/vendor/deep/v1.js"; printf 'v\n' > "$G/vendor/deep/v2.js"
(cd "$G" && git init -q . 2>/dev/null && git add -A 2>/dev/null && git -c user.name=t -c user.email=t@t commit -q -m t 2>/dev/null)
out="$(bash "$HERE/copy-target.sh" "$G" "$W/gitted-copy" 2>&1)"
GS="$W/gitted-copy-snapshot.tsv"
grep -q "^LEFT OUT	git ignores this path (.gitignore:1:vendor/)	-	-	vendor/$" "$GS" 2>/dev/null && ok "snapshot list names the ignore rule that left a folder out" || bad "snapshot list has no ignore rule line for vendor/"
[ "$(grep -c 'vendor' "$GS" 2>/dev/null)" = "1" ] && ok "snapshot list gives an ignored folder 1 line, not 1 per file" || bad "snapshot list listed the files inside an ignored folder"
printf '*.log\n' >> "$G/.gitignore"; printf 'l\n' > "$G/keep/one.log"; printf 'l\n' > "$G/keep/two.log"; printf 'l\n' > "$G/three.log"
out="$(bash "$HERE/copy-target.sh" "$G" "$W/gitted-copy2" 2>&1)"
[ "$(grep -c '[.]log' "$W/gitted-copy2-snapshot.tsv" 2>/dev/null)" = "1" ] && ok "snapshot list gives 3 files under 1 ignore rule 1 line" || bad "snapshot list gave 1 ignore rule more than 1 line"
grep -q "(and 2 more paths under this rule)$" "$W/gitted-copy2-snapshot.tsv" 2>/dev/null && ok "snapshot list counts the paths under an ignore rule" || bad "snapshot list lost the count under an ignore rule"
[ -f "$W/gitted-copy/vendor/deep/v1.js" ] && bad "copy-target copied an ignored file" || ok "copy-target kept the ignored folder out of the copy"
# 2026-11-14, v1.5.6: a left out file the map names is NEEDED. Up to the second limit the file comes along.
M="$W/needed"; mkdir -p "$M/logs" "$M/media"
printf '# Needed\n\nWrite the log in `logs/daily.md`. The intro film is `media/film.bin`.\n' > "$M/CLAUDE.md"
head -c 5000 /dev/zero > "$M/logs/daily.md"; head -c 30000 /dev/zero > "$M/media/film.bin"; head -c 5000 /dev/zero > "$M/media/unnamed.bin"
out="$(bash "$HERE/copy-target.sh" "$M" "$W/needed-copy" 1 16 2>&1)"
NS="$W/needed-copy-snapshot.tsv"
[ -f "$W/needed-copy/logs/daily.md" ] && ok "copy-target brings along a big file the map names" || bad "copy-target left out a file the map names, under the second limit"
expect_has  "copy-target says the named file came along" "$out" "NEEDED  brought along"
grep -q "^IN	copied, over the limit, named in CLAUDE.md line 3	[0-9]*	[0-9a-f]\{64\}	logs/daily.md$" "$NS" 2>/dev/null && ok "snapshot list marks a file that came along because the map names the file" || bad "snapshot list does not mark the brought along file"
[ -f "$W/needed-copy/media/film.bin" ] && bad "copy-target copied a named file over the second limit" || ok "copy-target keeps a named file over the second limit out"
expect_has  "copy-target flags a named file that is not in the copy" "$out" "NEEDED  NOT IN THE COPY"
expect_has  "copy-target names the file and the map line" "$out" "media/film.bin  (named in CLAUDE.md line 3)"
grep -q "^LEFT OUT	over 16 KB, NEEDED: named in CLAUDE.md line 3	[0-9]*	[0-9a-f]\{64\}	media/film.bin$" "$NS" 2>/dev/null && ok "snapshot list says the left out file is NEEDED" || bad "snapshot list does not say film.bin is NEEDED"
[ -f "$W/needed-copy/media/unnamed.bin" ] && bad "copy-target brought along a big file the map does not name" || ok "copy-target leaves out a big file the map does not name"
printf '%s' "$out" | grep "NEEDED" | grep -q "unnamed.bin" && bad "copy-target called an unnamed file NEEDED" || ok "copy-target stays quiet about a big file the map does not name"
out="$(bash "$HERE/verify-snapshot.sh" "$W/needed-copy" "$NS" in 2>&1)"; rc=$?
expect_exit "verify-snapshot passes a copy that holds a brought along file" "$rc" 0
# the examined list: in the copy and opened by the auditor are 2 different claims
printf 'CLAUDE.md\n./docs/a.md\nbig-art.bin\nno-such-file.md\nCLAUDE.md\n' > "$W/opened.txt"
out="$(bash "$HERE/examined.sh" "$SNAP" "$W/opened.txt" 2>&1)"; rc=$?
expect_exit "examined writes the examined list" "$rc" 0
expect_has  "examined counts the 2 opened files once each" "$out" "EXAMINED 2 files opened"
expect_has  "examined names a file the reader wanted that the copy left out" "$out" "WANTED   big-art.bin (left out: over 4 KB)"
grep -q "	UNKNOWN	not on the snapshot list	no-such-file.md$" "$W/scratch-small-examined.tsv" 2>/dev/null && ok "examined marks a path that is not on the snapshot list" || bad "examined lost the unknown path"
grep -q "^1	EXAMINED	[0-9a-f]\{64\}	CLAUDE.md$" "$W/scratch-small-examined.tsv" 2>/dev/null && ok "examined carries the snapshot fingerprint for an opened file" || bad "examined has no fingerprint for CLAUDE.md"
out="$(bash "$HERE/examined.sh" "$SNAP" 2>&1)"; rc=$?
expect_exit "examined refuses to run with no opened list" "$rc" 2
# the helpers: every helper file names its model, so a run never falls onto the owner's biggest model
A="$HERE/../agents"
for h in 4r-scripts 4r-stranger 4r-replay; do
  grep -q "^model: \(haiku\|sonnet\)$" "$A/$h.md" 2>/dev/null && ok "helper $h names its model" || bad "helper $h has no model line"
  grep -q "agents/$h.md" "$HERE/../SKILL.md" 2>/dev/null && ok "SKILL.md names helper $h" || bad "SKILL.md does not name helper $h"
done
rm -f "$B/big-art.bin"
out="$(bash "$HERE/copy-target.sh" "$B" "$B/inside" 2>&1)"; rc=$?
expect_exit "copy-target refuses a scratch inside the target" "$rc" 2
[ -d "$B/inside" ] && bad "copy-target left a folder inside the target" || ok "copy-target left the target untouched"

# ---------- A KEY SAVED IN THE HISTORY ----------
K="$W/saved"; mkdir -p "$K"
printf 'key = %s\n' "$FAKE" > "$K/config.md"
(cd "$K" && git init -q . && git add config.md && git -c user.name=t -c user.email=t@t commit -q -m t)
out="$(bash "$HERE/secrets.sh" "$K" 2>&1)"; rc=$?
expect_exit "secrets fires on a saved key" "$rc" 1
expect_has  "secrets says the key is saved in the history" "$out" "1 of them SAVED IN THE HISTORY"

# ---------- SIZE ----------
Z="$W/size"; mkdir -p "$Z/skills/s" "$Z/scripts" "$Z/build" "$Z/docs"
printf 'a\nb\nc\n' > "$Z/CLAUDE.md"
printf 'a\nb\n' > "$Z/skills/s/SKILL.md"
printf 'a\nb\nc\nd\n' > "$Z/scripts/check.sh"
printf 'a\nb\nc\nd\ne\nf\ng\nh\n' > "$Z/build/app.js"
printf 'not counted\n' > "$Z/docs/notes.md"
printf '# old\nSIZE rules=2 skills=2 checks=2 files=3\n' > "$W/old-record.md"
out="$(bash "$HERE/size.sh" "$Z" 2>&1)"; rc=$?
expect_exit "size counts a workspace" "$rc" 0
expect_has  "size counts the exact lines in each part" "$out" "SIZE rules=3 skills=2 checks=4 files=3"
expect_has  "size sets the build folder aside" "$out" "set aside: 1 machine built"
out="$(bash "$HERE/size.sh" "$Z" "$W/old-record.md" 2>&1)"
expect_has  "size shows growth against the last record" "$out" "(last audit 2, +2, +100%)"
expect_has  "size shows no change where nothing grew" "$out" "(last audit 2, +0, +0%)"

# ---------- A LAPTOP COPY BEHIND ITS ONLINE COPY ----------
N="$W/behind"; mkdir -p "$N"
git init -q --bare "$W/online.git"
(cd "$N" && git init -q -b main inner && cd inner && printf 'a\n' > a.md && git add a.md && git -c user.name=t -c user.email=t@t commit -q -m a \
  && git remote add origin "$W/online.git" && git push -q -u origin main 2>/dev/null)
printf '# N\n\nThe app lives in `inner/`.\n' > "$N/CLAUDE.md"
(cd "$W" && git clone -q -b main "$W/online.git" other 2>/dev/null && cd other && printf 'b\n' > b.md && git add b.md \
  && git -c user.name=t -c user.email=t@t commit -q -m b && git push -q origin main 2>/dev/null)
out="$(bash "$HERE/nested-repos.sh" "$N" 2>&1)"; rc=$?
expect_exit "nested-repos fires on a copy behind its online copy" "$rc" 1
expect_has  "nested-repos says the copy is behind" "$out" "BEHIND, the online copy has saves this computer never got"
(cd "$N/inner" && git pull -q 2>/dev/null)
out="$(bash "$HERE/nested-repos.sh" "$N" 2>&1)"
expect_not  "nested-repos quiet once the copy catches up" "$out" "BEHIND"

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
