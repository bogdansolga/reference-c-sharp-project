#!/bin/bash

# Install git hooks (bash variant — macOS / Linux / Git Bash).
# Windows users without Git Bash: run scripts/git-hooks/install.ps1 instead.
# Usage: ./scripts/git-hooks/install.sh [project-path]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "${1:-.}" && pwd)"

if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Error: $TARGET_DIR is not a git repository"
    exit 1
fi

HOOKS_DIR="$TARGET_DIR/.git/hooks"

echo "Installing bash git hooks to: $TARGET_DIR"
for hook in pre-commit pre-push; do
    if [ -f "$SCRIPT_DIR/$hook" ]; then
        cp "$SCRIPT_DIR/$hook" "$HOOKS_DIR/$hook"
        chmod +x "$HOOKS_DIR/$hook"
        echo "  ✓ $hook"
    fi
done

echo ""
echo "Done! Hooks run on commit/push. Edit scripts/arch-checks.conf to customize."
echo "Bypass once with: git commit --no-verify  /  git push --no-verify"
