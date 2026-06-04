#!/bin/bash

# Deep Architecture Validation (C# port)
# Comprehensive checks beyond the basic layer hierarchy.

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
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo "Running deep architecture checks..."
echo ""

# 1. Repository layer purity (no HTTP / ASP.NET) ------------------------------
echo "1/6 Checking repository layer purity..."
if [[ -d "$REPO_LAYER_PATH" ]]; then
    IMPURE=$(grep -rnE "using ($HTTP_MODULE_PATH|$HTTP_MODULE_PATH_2)" "$REPO_LAYER_PATH" --include="*.cs" 2>/dev/null || true)
    if [ -n "$IMPURE" ]; then
        echo -e "${RED}x Repository layer imports HTTP/ASP.NET concepts:${NC}"
        echo "$IMPURE" | while read -r l; do echo "  - $l"; done
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}v Repository layer is pure (no HTTP imports)${NC}"
    fi
else
    echo -e "${YELLOW}! Repository path not found: $REPO_LAYER_PATH${NC}"
fi

# 2. Endpoints rely on centralized middleware (no raw try/catch) --------------
echo ""
echo "2/6 Checking endpoints rely on centralized error handling..."
if [[ -d "$ROUTES_PATH" ]]; then
    WITH_TRYCATCH=$(grep -rlnE "^\s*try\s*$|^\s*try\s*\{" "$ROUTES_PATH" --include="*.cs" 2>/dev/null || true)
    if [ -n "$WITH_TRYCATCH" ]; then
        echo -e "${YELLOW}! Endpoints using raw try/catch (prefer the middleware):${NC}"
        echo "$WITH_TRYCATCH" | while read -r f; do echo "  - $f"; done
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}v Endpoints rely on centralized error-handling middleware${NC}"
    fi
fi

# 3. Write endpoints inject a validator ---------------------------------------
echo ""
echo "3/6 Checking write endpoints validate input..."
if [[ -d "$ROUTES_PATH" ]]; then
    MISSING_VALIDATION=$(find "$ROUTES_PATH" -name "*.cs" -type f -exec sh -c '
        if grep -qE "MapPost|MapPut" "$1" && ! grep -q "IValidator" "$1"; then echo "$1"; fi
    ' _ {} \; 2>/dev/null || true)
    if [ -n "$MISSING_VALIDATION" ]; then
        echo -e "${YELLOW}! Write endpoints without IValidator (review required):${NC}"
        echo "$MISSING_VALIDATION" | while read -r f; do echo "  - $f"; done
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}v Write endpoints inject validators${NC}"
    fi
fi

# 4. Status-code consistency (no magic numbers) -------------------------------
echo ""
echo "4/6 Checking status-code consistency..."
MAGIC_STATUS=$(grep -rnE "statusCode:\s*[0-9]{3}" "$ROUTES_PATH" --include="*.cs" 2>/dev/null || true)
if [ -n "$MAGIC_STATUS" ]; then
    echo -e "${YELLOW}! Magic status numbers (use StatusCodes.*):${NC}"
    echo "$MAGIC_STATUS" | while read -r l; do echo "  - $l"; done
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}v Status codes use the StatusCodes helper${NC}"
fi

# 5. Services throw domain errors, not generic Exception ----------------------
echo ""
echo "5/6 Checking services throw domain errors..."
if [[ -d "$SERVICES_PATH" ]]; then
    GENERIC=$(grep -rnF "$GENERIC_THROW" "$SERVICES_PATH" --include="*.cs" 2>/dev/null || true)
    if [ -n "$GENERIC" ]; then
        echo -e "${RED}x Services throwing generic Exception (use domain errors):${NC}"
        echo "$GENERIC" | while read -r l; do echo "  - $l"; done
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}v Services use domain-specific errors${NC}"
    fi
fi

# 6. Endpoints don't import repositories --------------------------------------
echo ""
echo "6/6 Checking endpoints don't import repositories..."
ENDPOINTS_WITH_REPOS=$(grep -rnE "$REPO_IMPORT_PATTERN" "$ROUTES_PATH" --include="*.cs" 2>/dev/null || true)
if [ -n "$ENDPOINTS_WITH_REPOS" ]; then
    echo -e "${RED}x Endpoints importing repositories directly (use services):${NC}"
    echo "$ENDPOINTS_WITH_REPOS" | while read -r l; do echo "  - $l"; done
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}v Endpoints use the services layer${NC}"
fi

# Summary --------------------------------------------------------------------
echo ""
echo "----------------------------------------"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}x Deep architecture check failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}! Deep architecture check passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}v All deep architecture checks passed${NC}"
    exit 0
fi
