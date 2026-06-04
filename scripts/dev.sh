#!/usr/bin/env bash
# Run the whole stack with one command:
#   1) Backend  — ASP.NET Core API on http://localhost:5099 (creates + seeds SQLite on first run)
#   2) Frontend — Next.js web app on http://localhost:3000 (proxies /api/* to the backend)
# Press Ctrl+C to stop both.
#
# Usage: ./scripts/dev.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Resolve dotnet (the cask installs to /usr/local/share/dotnet, not always on PATH)
DOTNET="$(command -v dotnet || true)"
[ -z "$DOTNET" ] && [ -x "/usr/local/share/dotnet/dotnet" ] && DOTNET="/usr/local/share/dotnet/dotnet"
[ -z "$DOTNET" ] && { echo "error: dotnet not found — install the .NET 8 SDK (nb install --cask dotnet-sdk@8)"; exit 1; }
command -v bun >/dev/null 2>&1 || { echo "error: bun not found — install Bun for the web/ frontend"; exit 1; }

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
(cd "$ROOT/api" && exec "$DOTNET" run) &
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
