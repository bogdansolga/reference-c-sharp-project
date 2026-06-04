#!/bin/bash
# PostToolUse hook — auto-format edited C# files with `dotnet format`.
# Demonstrates write-time quality enforcement (the C# analog of a Biome format hook).
# Receives the tool-use payload as JSON on stdin.

input=$(cat)
file=$(printf '%s' "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$file" in
  *.cs)
    root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
    DOTNET="$(command -v dotnet || true)"
    [ -z "$DOTNET" ] && [ -x "/usr/local/share/dotnet/dotnet" ] && DOTNET="/usr/local/share/dotnet/dotnet"
    [ -n "$DOTNET" ] && "$DOTNET" format "$root/reference-c-sharp-project.sln" --include "$file" --no-restore >/dev/null 2>&1
    ;;
esac
exit 0
