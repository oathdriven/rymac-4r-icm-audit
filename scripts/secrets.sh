#!/usr/bin/env bash
# secrets.sh - 4R audit, layer 1, question 7. Read only. Never prints a full key.
#
# Usage:  bash secrets.sh <target folder>
#
# 1. Scans every text file (binaries, .git and node_modules skipped) for the shapes of
#    real keys: AI keys, cloud keys, payment keys, chat app tokens, private key blocks.
#    Each hit prints as file:line, the kind of key, and the first 6 characters only.
#    In a git repo, each hit also says whether the file is saved in the history (the
#    worst case: the key ships with every copy and every push).
# 2. Lists every settings file that usually holds keys (.env, .env.local and so on,
#    never .env.example). Fine on 1 machine. Never inside a zip somebody else gets.
#
# Exit 0 = nothing found. Exit 1 = at least 1 key shape or saved settings file.

set -u
T="${1:?usage: bash secrets.sh <target folder>}"
[ -d "$T" ] || { echo "secrets: no folder at $T"; exit 2; }
T="$(cd "$T" && pwd)"
is_repo=0; git -C "$T" rev-parse --show-toplevel >/dev/null 2>&1 && is_repo=1

KINDS='AI key (Anthropic)|sk-ant-[A-Za-z0-9_-]{20,}
AI key (OpenRouter)|sk-or-v1-[A-Za-z0-9]{32,}
AI key (OpenAI)|(sk-proj-[A-Za-z0-9_-]{32,}|sk-[A-Za-z0-9]{32,})
cloud key (AWS)|AKIA[0-9A-Z]{16}
cloud key (Google)|AIza[0-9A-Za-z_-]{35}
code host token (GitHub)|(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,})
chat app token (Slack)|xox[abprs]-[A-Za-z0-9-]{10,}
payment key (Stripe live)|(sk|rk)_live_[A-Za-z0-9]{20,}
email key (Resend)|re_[A-Za-z0-9]{8,}_[A-Za-z0-9]{16,}
private key block|-----BEGIN [A-Z ]*PRIVATE KEY-----'

hits=0
while IFS='|' read -r kind rx; do
  [ -z "$kind" ] && continue
  while IFS= read -r h; do
    file="${h%%:*}"; rest="${h#*:}"; ln="${rest%%:*}"; val="${rest#*:}"
    rel="${file#$T/}"
    saved=""
    if [ "$is_repo" -eq 1 ]; then
      if git -C "$T" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then saved="  SAVED IN THE HISTORY"; else saved="  on disk only"; fi
    fi
    printf '  key     %s:%s  %s  %s...%s\n' "$rel" "$ln" "$kind" "${val:0:6}" "$saved"
    hits=$((hits + 1))
  done < <(grep -rInoE --exclude-dir=.git --exclude-dir=node_modules "$rx" "$T" 2>/dev/null)
done <<< "$KINDS"
echo "KEYS    $hits key shaped strings found"

envs=0
while IFS= read -r e; do
  rel="${e#$T/}"
  saved=""
  if [ "$is_repo" -eq 1 ]; then
    if git -C "$T" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then saved="  SAVED IN THE HISTORY"; else saved="  on disk only, keep out of every zip"; fi
  fi
  printf '  file    %s%s\n' "$rel" "$saved"
  envs=$((envs + 1))
done < <(find "$T" \( -name .git -o -name node_modules \) -prune -o -type f \( -name '.env' -o -name '.env.*' \) \
         ! -name '*.example' ! -name '*.sample' ! -name '*.template' -print 2>/dev/null | sort)
echo "ENVS    $envs settings files that usually hold keys"

[ "$hits" -eq 0 ] && [ "$envs" -eq 0 ] && exit 0
exit 1
