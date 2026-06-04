#!/bin/bash

# Validator Location Checker (C# port of check-schemas.sh)
# Enforces: endpoints and services inject IValidator<T>, they do not define validators inline.
# (TS analog: routes/services must not `import { z } from "zod"`.)
#
# Usage:
#   ./scripts/check-validators.sh [--staged]

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

# An inline validator = declaring an AbstractValidator or calling RuleFor outside api/Validation.
INLINE_PATTERN='AbstractValidator<|RuleFor\('

get_files() {
    local dir="$1"
    if $STAGED_ONLY; then
        git diff --cached --name-only --diff-filter=ACM | grep -E "^${dir}/.*\.cs$" || true
    else
        find "$dir" -type f -name "*.cs" 2>/dev/null || true
    fi
}

check_dir() {
    local dir="$1"
    local label="$2"
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ -f "$file" ]] || continue
        if grep -qE "$INLINE_PATTERN" "$file" 2>/dev/null; then
            local line_num
            line_num=$(grep -nE "$INLINE_PATTERN" "$file" | head -1 | cut -d: -f1)
            echo -e "${RED}x${NC} $file:$line_num"
            echo "    $label defines a validator inline"
            echo "    Validators should live in $SCHEMA_LOCATION and be injected as IValidator<T>"
            echo ""
            VIOLATIONS_FOUND=1
        fi
    done <<< "$(get_files "$dir")"
}

echo "Checking for inline validators..."
echo ""

check_dir "$SCHEMA_CHECK_ROUTES" "Endpoint"
check_dir "$SCHEMA_CHECK_SERVICES" "Service"

if [[ $VIOLATIONS_FOUND -eq 1 ]]; then
    echo "----------------------------------------"
    echo -e "${RED}x Inline validator violations found!${NC}"
    echo ""
    echo "Endpoints and services should not define FluentValidation validators inline."
    echo "Instead, validators should be:"
    echo "  1. Defined in $SCHEMA_LOCATION"
    echo "  2. Injected via IValidator<T>"
    echo "----------------------------------------"
    exit 1
else
    echo -e "${GREEN}v${NC} Validator location check passed"
    exit 0
fi
