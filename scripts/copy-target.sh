#!/usr/bin/env bash
# copy-target.sh - 4R audit setup. Makes the throwaway copy that layers 2 and 3 work in.
#
# Usage:  bash copy-target.sh <target folder> <scratch folder> [max KB per file, default 1024]
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
(cd "$T" && tr '\n' '\0' < "$list.all" | xargs -0 du -k 2>/dev/null) \
  | awk -F'\t' -v max="$MAXKB" '$1 <= max { sub(/^[^\t]*\t/, ""); print }' > "$list"
(cd "$T" && tar -cf - -T "$list" 2>/dev/null) | (cd "$D" && tar -xf - 2>/dev/null)
copied=$(find "$D" -type f | wc -l | tr -d ' ')

# 2026-11-14, v1.5.4 (a member asked which files the audit checked): the files left out for size
# get NAMED, not only counted. The full list goes beside the scratch copy, never inside the copy
# (the stranger would read it) and never inside the target (the audit writes nothing there).
left="$D-left-out.txt"
sort -u "$list.all" > "$list.u"; sort -u "$list" > "$list.s"
comm -23 "$list.u" "$list.s" | while IFS= read -r f; do
  [ -f "$T/$f" ] && printf '%s KB\t%s\n' "$(du -k "$T/$f" 2>/dev/null | cut -f1)" "$f"
done > "$left"
big=$(wc -l < "$left" | tr -d ' ')
rm -f "$list" "$list.all" "$list.u" "$list.s"
echo "COPY    $copied files copied from the target's $src into $D"
echo "        $big files over ${MAXKB} KB left out"
if [ "$big" -gt 0 ]; then
  head -n 100 "$left" | while IFS= read -r l; do echo "LEFT OUT  $l"; done
  [ "$big" -gt 100 ] && echo "LEFT OUT  ... and $((big - 100)) more"
  echo "        every file left out, by name: $left"
fi
exit 0
