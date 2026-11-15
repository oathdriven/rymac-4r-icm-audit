#!/usr/bin/env bash
# copy-target.sh - 4R audit setup. Makes the throwaway copy that layers 2 and 3 work in.
#
# Usage:  bash copy-target.sh <target folder> <scratch folder> [max KB per file, default 1024] [max KB for a file the map names, default 5120]
#
# In a git repo, copies the files saved in the history (what the owner means by "the
# workspace"). Anywhere else, copies every file except .git and node_modules. Files over
# the size limit are skipped and counted, so a folder of videos does not fill the disk.
# The target's own .claude settings come along so its hooks can be tested.
#
# Refuses a scratch folder inside the target: the audit never writes into what it measures.
# Exit 0 = copied. Exit 2 = bad arguments.

set -u
# 2026-10-07 (a member found it): a plain "git status" rewrites .git/index and can
# leave an index.lock behind in the folder it reads. This keeps every git call read only.
export GIT_OPTIONAL_LOCKS=0
T="${1:?usage: bash copy-target.sh <target> <scratch> [max KB]}"
D="${2:?usage: bash copy-target.sh <target> <scratch> [max KB]}"
MAXKB="${3:-1024}"
NEEDKB="${4:-5120}"
[ -d "$T" ] || { echo "copy-target: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"
mkdir -p "$D" || exit 2
D="$(cd "$D" && pwd)"
case "$D/" in "$T/"*) echo "copy-target: refusing, $D is inside the target $T"; rmdir "$D" 2>/dev/null; exit 2 ;; esac

list="$(mktemp)"
if git -C "$T" rev-parse --show-toplevel >/dev/null 2>&1; then
  # 2026-11-02, 4R fix 22: new files not in the history yet came along too late on a re-audit, so the stranger walked twice.
  (cd "$T" && git ls-files && git ls-files --others --exclude-standard) > "$list.all"
  src="saved files (git), plus new files git does not ignore"
else
  (cd "$T" && find . \( -name .git -o -name node_modules \) -prune -o -type f -print | sed 's#^\./##') > "$list.all"
  src="all files"
fi
for extra in .claude/settings.json .claude/settings.local.json; do [ -f "$T/$extra" ] && echo "$extra" >> "$list.all"; done

# 1 pass of du over every listed file (portable on Linux, macOS and Git Bash), then keep the small ones
(cd "$T" && tr '\n' '\0' < "$list.all" | xargs -0 du -k 2>/dev/null) > "$list.du"
awk -F'\t' -v max="$MAXKB" '$1 <= max { sub(/^[^\t]*\t/, ""); print }' "$list.du" > "$list"

# 2026-11-14, v1.5.6 (a member asked: flag a left out file louder when another step depends on the file).
# A file over the size limit that the MAP names (CLAUDE.md, AGENTS.md or CONTEXT.md at the top) is NEEDED:
# the map sends the agent there, so the stranger would be told the file does not exist. A NEEDED file up to
# the second limit comes along in the copy anyway. A NEEDED file over the second limit stays out and gets
# flagged at the top, before the stranger starts.
: > "$list.need"
awk -F'\t' -v max="$MAXKB" '$1 > max' "$list.du" | while IFS="$(printf '\t')" read -r kb f; do
  for ent in CLAUDE.md AGENTS.md CONTEXT.md; do
    [ -f "$T/$ent" ] || continue
    ln="$(grep -nF -- "$f" "$T/$ent" 2>/dev/null | head -n 1 | cut -d: -f1)"
    if [ -n "$ln" ]; then
      if [ "$kb" -le "$NEEDKB" ]; then printf 'BROUGHT\t%s\t%s\t%s line %s\n' "$kb" "$f" "$ent" "$ln"; else printf 'TOO BIG\t%s\t%s\t%s line %s\n' "$kb" "$f" "$ent" "$ln"; fi
      break
    fi
  done
done > "$list.need"
awk -F'\t' '$1 == "BROUGHT" { print $3 }' "$list.need" >> "$list"
(cd "$T" && tar -cf - -T "$list" 2>/dev/null) | (cd "$D" && tar -xf - 2>/dev/null)
copied=$(find "$D" -type f | wc -l | tr -d ' ')

# 2026-11-14, v1.5.4 (a member asked which files the audit checked): the files left out for size
# get NAMED, not only counted. The full list goes beside the scratch copy, never inside the copy
# (the stranger would read the list) and never inside the target (the audit writes nothing there).
left="$D-left-out.txt"
sort -u "$list.all" > "$list.u"; sort -u "$list" > "$list.s"
comm -23 "$list.u" "$list.s" | while IFS= read -r f; do
  [ -f "$T/$f" ] && printf '%s KB\t%s\n' "$(du -k "$T/$f" 2>/dev/null | cut -f1)" "$f"
done > "$left"
big=$(wc -l < "$left" | tr -d ' ')

# 2026-11-14, v1.5.5 (a member asked for a list anybody can check on their own machine): the
# SNAPSHOT LIST. 1 line per file with its fingerprint (SHA-256, a code built from the file's exact
# bytes, so 1 changed letter changes the code). IN = in the copy. LEFT OUT = never in the copy, with
# the reason. A git ignore rule gets 1 line per rule, with a count, never every file inside.
# The list sits beside the copy, like the left out list. verify-snapshot.sh re-checks every fingerprint.
if command -v sha256sum >/dev/null 2>&1; then HASH="sha256sum"; else HASH="shasum -a 256"; fi
snap="$D-snapshot.tsv"
{
  printf '# 4R snapshot list. target: %s  copy: %s  made: %s\n' "$T" "$D" "$(date '+%Y-%m-%d %H:%M %Z')"
  printf '# status\treason\tKB\tsha256\tpath\n'
  # IN: fingerprint the copy's bytes, which are the target's bytes at copy time
  (cd "$D" && tr '\n' '\0' < "$list.s" | xargs -0 $HASH 2>/dev/null) \
    | awk -v dufile="$list.du" -v needfile="$list.need" 'BEGIN { while ((getline l < dufile) > 0) { i = index(l, "\t"); kb[substr(l, i + 1)] = substr(l, 1, i - 1) }
          while ((getline l < needfile) > 0) { split(l, c, "\t"); if (c[1] == "BROUGHT") need[c[3]] = c[4] } }
        { if (substr($0, 1, 1) == sprintf("%c", 92)) $0 = substr($0, 2); h = substr($0, 1, 64); f = substr($0, 67); r = (f in need) ? "copied, over the limit, named in " need[f] : "copied"; printf "IN\t%s\t%s\t%s\t%s\n", r, kb[f], h, f }'
  # LEFT OUT for size: fingerprint the target's bytes, read only
  while IFS="$(printf '\t')" read -r kb f; do
    h="$($HASH "$T/$f" 2>/dev/null | tr -d '\134' | cut -c1-64)"
    why="over $MAXKB KB"
    nm="$(awk -F'\t' -v f="$f" '$1 == "TOO BIG" && $3 == f { print $4 }' "$list.need")"
    [ -n "$nm" ] && why="over $NEEDKB KB, NEEDED: named in $nm"
    printf 'LEFT OUT\t%s\t%s\t%s\t%s\n' "$why" "${kb% KB}" "$h" "$f"
  done < "$left"
  if git -C "$T" rev-parse --show-toplevel >/dev/null 2>&1; then
    # LEFT OUT by a git ignore rule: 1 line per RULE, with how many paths the rule left out and the
    # first path as the example. Never 1 line per file (1 folder of downloads can hold 50,000 files).
    (cd "$T" && git ls-files --others --ignored --exclude-standard --directory 2>/dev/null) > "$list.ig"
    (cd "$T" && git check-ignore -v --no-index --stdin < "$list.ig" 2>/dev/null) \
      | awk -F'\t' '{ if (!($1 in n)) { order[++k] = $1; first[$1] = $2 } n[$1]++ }
          END { for (i = 1; i <= k; i++) { r = order[i]
                  printf "LEFT OUT\tgit ignores this path (%s)\t-\t-\t%s", r, first[r]
                  if (n[r] > 1) printf " (and %d more paths under this rule)", n[r] - 1
                  printf "\n" } }'
  else
    (cd "$T" && find . \( -name .git -o -name node_modules \) -prune -print 2>/dev/null | sed 's#^\./##') \
      | while IFS= read -r f; do printf 'LEFT OUT\t.git or node_modules, never copied\t-\t-\t%s/\n' "$f"; done
  fi
} > "$snap"
nin=$(grep -c '^IN' "$snap"); nig=$(grep -c 'git ignores this path\|never copied' "$snap")
echo "COPY    $copied files copied from the target's $src into $D"
nb=$(grep -c '^BROUGHT' "$list.need"); nt=$(grep -c '^TOO BIG' "$list.need")
if [ "$nt" -gt 0 ]; then
  echo "NEEDED  $nt files your map names are NOT in the copy. The stranger will be sent to them and will not find them:"
  awk -F'\t' '$1 == "TOO BIG" { printf "NEEDED  NOT IN THE COPY  %s KB  %s  (named in %s)\n", $2, $3, $4 }' "$list.need"
fi
if [ "$nb" -gt 0 ]; then
  echo "NEEDED  $nb files over ${MAXKB} KB came along anyway, because your map names them (up to ${NEEDKB} KB):"
  awk -F'\t' '$1 == "BROUGHT" { printf "NEEDED  brought along  %s KB  %s  (named in %s)\n", $2, $3, $4 }' "$list.need"
fi
rm -f "$list" "$list.all" "$list.u" "$list.s" "$list.ig" "$list.du" "$list.need"
echo "        $big files over ${MAXKB} KB left out"
if [ "$big" -gt 0 ]; then
  head -n 100 "$left" | while IFS= read -r l; do echo "LEFT OUT  $l"; done
  [ "$big" -gt 100 ] && echo "LEFT OUT  ... and $((big - 100)) more"
  echo "        every file left out, by name: $left"
fi
echo "SNAPSHOT $nin files IN with a fingerprint, $big LEFT OUT for size, $nig LEFT OUT by an ignore rule"
echo "        the snapshot list: $snap"
echo "        check the list any time: bash verify-snapshot.sh <the folder> $snap"
exit 0
