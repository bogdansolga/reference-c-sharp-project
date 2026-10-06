#!/usr/bin/env bash
# postToolUse hook: after Copilot edits a C# file under api/ or tests/, run `dotnet format` on it
# (the Copilot port of .claude/hooks/format-cs.sh). Config: .github/hooks/format-cs.json.
# Copilot CLI / cloud agent send {"toolName","toolArgs"}; VS Code maps the file and sends
# {"tool_name","tool_input"}. We scan the raw payload for .cs paths, so both work without jq.
# Never blocks: always exits 0; tells the agent what happened via additionalContext.
# Sources: https://docs.github.com/en/copilot/reference/hooks-reference
#          https://code.visualstudio.com/docs/copilot/customization/hooks
#          https://code.visualstudio.com/docs/agents/reference/hooks-reference
set -u
payload=$(cat)
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
DOTNET="$(command -v dotnet || true)"
[ -z "$DOTNET" ] && [ -x /usr/local/share/dotnet/dotnet ] && DOTNET=/usr/local/share/dotnet/dotnet
[ -z "$DOTNET" ] && exit 0
msg=""
for f in $(printf '%s' "$payload" | grep -oE '[A-Za-z0-9_./\\-]+\.cs\b' | sed 's#\\\\#/#g' | sort -u); do
  rel=${f#"$root/"}
  case "$rel" in api/*.cs|tests/*.cs) ;; *) continue ;; esac
  [ -f "$root/$rel" ] || continue
  if "$DOTNET" format "$root/reference-c-sharp-project.sln" --include "$rel" --no-restore >/dev/null 2>&1; then
    msg="$msg dotnet format applied to $rel."
  else
    msg="$msg dotnet format failed on $rel; run dotnet build and fix the errors."
  fi
done
[ -z "$msg" ] && exit 0
printf '{"additionalContext":"%s","hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg" "$msg"
exit 0
