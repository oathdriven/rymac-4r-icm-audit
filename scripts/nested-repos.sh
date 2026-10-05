#!/usr/bin/env bash
# nested-repos.sh - 4R audit, layer 1, question 6. Read only.
#
# Usage:  bash nested-repos.sh <target folder>
#
# Finds every folder inside the target that keeps its own save history (a git repo),
# up to 4 levels down. For each 1 it prints:
#   parent   how the target's own backup sees the folder: a pointer (backs up nothing
#            inside), ignored (fine only if the folder has its own online copy),
#            untracked (never saved by the parent), or tracked
#   unsaved  changes not saved (committed) in the folder's own history
#   unpushed saves that never reached the folder's online copy, or "no online copy"
#   behind   saves the online copy has that this computer never got (asks the online copy, read only)
#
# Exit 0 = no nested repo, or every nested repo is saved, pushed and not a pointer.
# Exit 1 = at least 1 nested repo is at risk.

set -u
T="${1:?usage: bash nested-repos.sh <target folder>}"
[ -d "$T" ] || { echo "nested-repos: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"
parent_is_repo=0
git -C "$T" rev-parse --show-toplevel >/dev/null 2>&1 && parent_is_repo=1

n=0; risk=0
while IFS= read -r g; do
  R="$(dirname "$g")"; rel="${R#$T/}"
  n=$((n + 1))
  view="n/a (the target has no save history of its own)"
  if [ "$parent_is_repo" -eq 1 ]; then
    if git -C "$T" ls-files -s -- "$rel" 2>/dev/null | awk '$1=="160000"' | grep -q .; then
      view="POINTER, the parent backs up nothing inside this folder"; risk=1
    elif git -C "$T" check-ignore -q -- "$rel/" 2>/dev/null || git -C "$T" check-ignore -q -- "$rel" 2>/dev/null; then
      view="ignored by the parent, so this folder's own online copy is its only backup"
    elif git -C "$T" ls-files -- "$rel" 2>/dev/null | grep -q .; then
      view="tracked by the parent"
    else
      view="UNTRACKED, the parent never saved this folder"; risk=1
    fi
  fi
  unsaved=$(git -C "$R" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if git -C "$R" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    unpushed="$(git -C "$R" rev-list --count '@{u}..HEAD' 2>/dev/null) saves not pushed"
    [ "$(git -C "$R" rev-list --count '@{u}..HEAD' 2>/dev/null)" != "0" ] && risk=1
  else
    unpushed="NO ONLINE COPY set up"; risk=1
  fi
  # behind: the online copy holds saves this computer never got (2026-10-05: a laptop copy of an app sat 118 saves
  # behind its online copy and this check called the folder fine). Asks the online copy directly, read only, 20 s max.
  # NESTED_OFFLINE=1 skips the question.
  behind=""
  if [ -z "${NESTED_OFFLINE:-}" ] && up="$(git -C "$R" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"; then
    rem="${up%%/*}"; br="${up#*/}"
    head_online="$(timeout 20 git -C "$R" ls-remote "$rem" "refs/heads/$br" 2>/dev/null | awk '{print $1}')"
    if [ -n "$head_online" ] && [ "$head_online" != "$(git -C "$R" rev-parse HEAD 2>/dev/null)" ]; then
      if ! git -C "$R" cat-file -e "$head_online^{commit}" 2>/dev/null; then
        behind="BEHIND, the online copy has saves this computer never got"; risk=1
      elif [ "$(git -C "$R" rev-list --count "HEAD..$head_online" 2>/dev/null)" != "0" ]; then
        behind="BEHIND by $(git -C "$R" rev-list --count "HEAD..$head_online") saves"; risk=1
      fi
    fi
  fi
  [ "$unsaved" != "0" ] && risk=1
  printf '%s/\n  parent   %s\n  unsaved  %s changes\n  unpushed %s\n' "$rel" "$view" "$unsaved" "$unpushed"
  [ -n "$behind" ] && printf '  behind   %s\n' "$behind"
done < <(find "$T" -mindepth 2 -maxdepth 5 -name .git -not -path '*/node_modules/*' 2>/dev/null | sort)

echo "NESTED  $n folders inside the target keep their own save history"
exit "$risk"
