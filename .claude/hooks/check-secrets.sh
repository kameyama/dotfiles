#!/usr/bin/env bash
# Find secrets and company information before they are committed or pushed.
#
#   check-secrets.sh changes    tracked changes not yet committed (git diff HEAD) and user.email
#   check-secrets.sh outgoing   commits not on any remote: content, messages, author/committer
#   check-secrets.sh all        the whole history of every ref
#   check-secrets.sh            Claude Code PreToolUse hook: reads the tool call JSON on stdin,
#                               runs changes / outgoing for git commit / git push, exit 2 blocks
#
# Company patterns live outside the repo in $DENY_FILE (one ERE per line, case-insensitive),
# because the patterns themselves are company information. Matches are printed masked.
set -uo pipefail

DENY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/deny-patterns"

# Generic secret patterns (case-sensitive)
SECRET_PATTERNS='AKIA[0-9A-Z]{16}
-----BEGIN [A-Z ]*PRIVATE KEY-----
gh[pousr]_[A-Za-z0-9]{36}
github_pat_[A-Za-z0-9_]{22,}
xox[abprs]-[A-Za-z0-9-]{10,}
AIza[0-9A-Za-z_-]{35}
\bsk-[A-Za-z0-9_-]{20,}
(password|passwd|secret|token|api_?key)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9+/_=-]{12,}'

# Lines to scan, with removed lines ("-...") dropped
text_changes() {
  git diff HEAD | grep -v '^-'
  git config user.email
}
text_log() {
  git log "$@" -p --format='commit %h%nauthor %an <%ae>%ncommitter %cn <%ce>%n%B' | grep -v '^-'
}

# Print masked matches; return 1 if anything matched
scan() {
  local text hits
  text="$(cat)"
  if [ ! -f "$DENY_FILE" ]; then
    echo "$DENY_FILE がない。会社の情報を検査できない（個人PCでは空ファイルでよい）"
    return 1
  fi
  hits="$(
    printf '%s\n' "$text" | grep -oE -f <(printf '%s\n' "$SECRET_PATTERNS")
    printf '%s\n' "$text" | grep -oiE -f <(grep -vE '^[[:space:]]*(#|$)' "$DENY_FILE")
  )"
  [ -z "$hits" ] && return 0
  echo "シークレットか会社の情報らしきものが見つかった（伏せ字で表示）:"
  printf '%s\n' "$hits" | sort -u | sed -E 's/^(.{4}).*/  \1…/'
  return 1
}

run() {
  case "$1" in
    changes)  text_changes | scan ;;
    outgoing) text_log --branches --not --remotes | scan ;;
    all)      text_log --all | scan ;;
    *) echo "usage: $0 changes|outgoing|all" >&2; return 2 ;;
  esac
}

if [ $# -gt 0 ]; then
  run "$1"
  exit $?
fi

# Hook mode
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || printf '%s' "$input")"
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
status=0
if printf '%s' "$cmd" | grep -qE '\bgit\b.*\bcommit\b'; then
  out="$( { printf '%s\n' "$cmd"; text_changes; } | scan )" || { echo "commit を止めた: $out" >&2; status=2; }
fi
if printf '%s' "$cmd" | grep -qE '\bgit\b.*\bpush\b'; then
  out="$(text_log --branches --not --remotes | scan)" || { echo "push を止めた: $out" >&2; status=2; }
fi
[ $status -eq 0 ] || echo "check-secrets スキルで中身を確かめ、ユーザーに報告すること。" >&2
exit $status
