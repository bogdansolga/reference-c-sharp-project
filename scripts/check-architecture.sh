#!/bin/bash

# Architecture Hierarchy Checker (C# port)
# Enforces: pages -> API endpoints -> services -> repositories
#
# Usage:
#   ./scripts/check-architecture.sh [--staged]
#     --staged    Only check staged files (for pre-commit)
#     (no args)   Check all files (for pre-push)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "./scripts/arch-checks.conf" ]]; then
    source "./scripts/arch-checks.conf"
elif [[ -f "$SCRIPT_DIR/arch-checks.conf" ]]; then
    source "$SCRIPT_DIR/arch-checks.conf"
else
    echo "Error: arch-checks.conf not found"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

VIOLATIONS_FOUND=0
STAGED_ONLY=false
[[ "$1" == "--staged" ]] && STAGED_ONLY=true

# Get files matching a path pattern (staged, or all source under api/ and web/)
get_files() {
    local pattern="$1"
    if $STAGED_ONLY; then
        git diff --cached --name-only --diff-filter=ACM | grep -E "$pattern" || true
    else
        find api web -type f \( -name "*.cs" -o -name "*.tsx" -o -name "*.ts" \) 2>/dev/null \
            | grep -E "$pattern" || true
    fi
}

# Grep a file for forbidden import patterns
check_file() {
    local file="$1"
    local layer="$2"
    shift 2
    local forbidden_patterns=("$@")

    [[ -f "$file" ]] || return 0

    for pattern in "${forbidden_patterns[@]}"; do
        local matches
        matches=$(grep -nE "$pattern" "$file" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            while IFS= read -r match; do
                local line_num line_content
                line_num=$(echo "$match" | cut -d: -f1)
                line_content=$(echo "$match" | cut -d: -f2-)
                echo -e "${RED}x${NC} $file:$line_num"
                echo "    $layer cannot import: $pattern"
                echo "    $line_content"
                echo ""
                VIOLATIONS_FOUND=1
            done <<< "$matches"
        fi
    done
}

echo "Checking architecture hierarchy..."
echo ""

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    check_file "$file" "Page" $PAGE_FORBIDDEN
done <<< "$(get_files "$PAGE_PATTERN")"

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    check_file "$file" "Endpoint" $ROUTE_FORBIDDEN
done <<< "$(get_files "$ROUTE_PATTERN")"

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    check_file "$file" "Service" $SERVICE_FORBIDDEN
done <<< "$(get_files "$SERVICE_PATTERN")"

if [[ $VIOLATIONS_FOUND -eq 1 ]]; then
    echo "----------------------------------------"
    echo -e "${RED}x Architecture hierarchy violations found!${NC}"
    echo ""
    echo "Required hierarchy: pages -> API endpoints -> services -> repositories"
    echo "  - Pages call API endpoints over HTTP"
    echo "  - Endpoints call services (not repositories / Data)"
    echo "  - Services call repositories (not the DbContext / Data)"
    echo "----------------------------------------"
    exit 1
else
    echo -e "${GREEN}v${NC} Architecture hierarchy check passed"
    exit 0
fi
