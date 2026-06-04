#!/usr/bin/env bash
# Run the whole stack with one command:
#   0) Guardrails — install the git hooks on first run (architecture checks on commit/push)
#   1) Backend  — ASP.NET Core API on http://localhost:5099 (creates + seeds SQLite on first run)
#   2) Frontend — Next.js web app on http://localhost:3000 (proxies /api/* to the backend)
# Press Ctrl+C to stop both.
#
# Usage: ./scripts/dev.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Require dotnet (the .NET 8 SDK) and bun on PATH
command -v dotnet >/dev/null 2>&1 || { echo "error: dotnet not found — install the .NET 8 SDK"; exit 1; }
command -v bun >/dev/null 2>&1 || { echo "error: bun not found — install Bun for the web/ frontend"; exit 1; }

# First run: install the git-hook guardrails if they aren't in place yet.
if [ -d "$ROOT/.git" ] && { [ ! -f "$ROOT/.git/hooks/pre-commit" ] || [ ! -f "$ROOT/.git/hooks/pre-push" ]; }; then
  echo "Installing git hooks (first run)..."
  "$ROOT/scripts/git-hooks/install.sh" "$ROOT" || { echo "error: git hook installation failed"; exit 1; }
fi

API_PID=""
WEB_PID=""
cleanup() {
  echo ""
  echo "Stopping..."
  [ -n "$WEB_PID" ] && kill "$WEB_PID" 2>/dev/null
  [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null
  # best-effort: also stop any child processes the runners spawned
  [ -n "$WEB_PID" ] && pkill -P "$WEB_PID" 2>/dev/null
  [ -n "$API_PID" ] && pkill -P "$API_PID" 2>/dev/null
  wait 2>/dev/null
}
trap cleanup INT TERM EXIT

echo "Installing web dependencies (bun install)..."
(cd "$ROOT/web" && bun install) || { echo "error: bun install failed"; exit 1; }

echo "Starting backend  → http://localhost:5099"
(cd "$ROOT/api" && exec dotnet run) &
API_PID=$!

echo "Starting frontend → http://localhost:3000"
(cd "$ROOT/web" && exec bun dev) &
WEB_PID=$!

echo ""
echo "Both running. Log in at the web app with admin/admin or user/user. Press Ctrl+C to stop."
# Exit (and trigger cleanup) as soon as either process stops.
while kill -0 "$API_PID" 2>/dev/null && kill -0 "$WEB_PID" 2>/dev/null; do
  sleep 1
done
