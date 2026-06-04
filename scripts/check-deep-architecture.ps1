#!/usr/bin/env pwsh
# Deep Architecture Validation (PowerShell port of check-deep-architecture.sh)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'arch-checks.ps1')

$script:Errors = 0
$script:Warnings = 0

function Get-CsUnder([string]$dir) {
    Get-ChildItem -Path $dir -Recurse -File -Include '*.cs' -ErrorAction SilentlyContinue
}

Write-Host "Running deep architecture checks..."
Write-Host ""

# 1. Repository layer purity
Write-Host "1/6 Checking repository layer purity..."
if (Test-Path $RepoLayerPath) {
    $pattern = "using ($($HttpModulePaths -join '|'))"
    $impure = Get-CsUnder $RepoLayerPath | Select-String -Pattern $pattern -ErrorAction SilentlyContinue
    if ($impure) {
        Write-Host "x Repository layer imports HTTP/ASP.NET concepts:" -ForegroundColor Red
        $impure | ForEach-Object { Write-Host "  - $($_.Path):$($_.LineNumber)" }
        $script:Errors++
    }
    else { Write-Host "v Repository layer is pure (no HTTP imports)" -ForegroundColor Green }
}
else { Write-Host "! Repository path not found: $RepoLayerPath" -ForegroundColor Yellow }

# 2. Endpoints rely on centralized middleware (no raw try/catch)
Write-Host ""
Write-Host "2/6 Checking endpoints rely on centralized error handling..."
if (Test-Path $RoutesPath) {
    $withTry = Get-CsUnder $RoutesPath | Select-String -Pattern '^\s*try\b' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -Unique
    if ($withTry) {
        Write-Host "! Endpoints using raw try/catch (prefer the middleware):" -ForegroundColor Yellow
        $withTry | ForEach-Object { Write-Host "  - $_" }
        $script:Warnings++
    }
    else { Write-Host "v Endpoints rely on centralized error-handling middleware" -ForegroundColor Green }
}

# 3. Write endpoints inject a validator
Write-Host ""
Write-Host "3/6 Checking write endpoints validate input..."
if (Test-Path $RoutesPath) {
    $missing = Get-CsUnder $RoutesPath | Where-Object {
        $c = Get-Content $_.FullName -Raw
        ($c -match 'MapPost|MapPut') -and ($c -notmatch 'IValidator')
    } | ForEach-Object { (Resolve-Path -Relative $_.FullName) -replace '\\', '/' -replace '^\./', '' }
    if ($missing) {
        Write-Host "! Write endpoints without IValidator (review required):" -ForegroundColor Yellow
        $missing | ForEach-Object { Write-Host "  - $_" }
        $script:Warnings++
    }
    else { Write-Host "v Write endpoints inject validators" -ForegroundColor Green }
}

# 4. Status-code consistency (no magic numbers)
Write-Host ""
Write-Host "4/6 Checking status-code consistency..."
if (Test-Path $RoutesPath) {
    $magic = Get-CsUnder $RoutesPath | Select-String -Pattern 'statusCode:\s*[0-9]{3}' -ErrorAction SilentlyContinue
    if ($magic) {
        Write-Host "! Magic status numbers (use StatusCodes.*):" -ForegroundColor Yellow
        $magic | ForEach-Object { Write-Host "  - $($_.Path):$($_.LineNumber)" }
        $script:Warnings++
    }
    else { Write-Host "v Status codes use the StatusCodes helper" -ForegroundColor Green }
}

# 5. Services throw domain errors, not generic Exception
Write-Host ""
Write-Host "5/6 Checking services throw domain errors..."
if (Test-Path $ServicesPath) {
    $generic = Get-CsUnder $ServicesPath | Select-String -Pattern ([regex]::Escape($GenericThrow)) -ErrorAction SilentlyContinue
    if ($generic) {
        Write-Host "x Services throwing generic Exception (use domain errors):" -ForegroundColor Red
        $generic | ForEach-Object { Write-Host "  - $($_.Path):$($_.LineNumber)" }
        $script:Errors++
    }
    else { Write-Host "v Services use domain-specific errors" -ForegroundColor Green }
}

# 6. Endpoints don't import repositories
Write-Host ""
Write-Host "6/6 Checking endpoints don't import repositories..."
if (Test-Path $RoutesPath) {
    $withRepos = Get-CsUnder $RoutesPath | Select-String -Pattern $RepoImportPattern -ErrorAction SilentlyContinue
    if ($withRepos) {
        Write-Host "x Endpoints importing repositories directly (use services):" -ForegroundColor Red
        $withRepos | ForEach-Object { Write-Host "  - $($_.Path):$($_.LineNumber)" }
        $script:Errors++
    }
    else { Write-Host "v Endpoints use the services layer" -ForegroundColor Green }
}

Write-Host ""
Write-Host "----------------------------------------"
if ($script:Errors -gt 0) {
    Write-Host "x Deep architecture check failed with $($script:Errors) error(s) and $($script:Warnings) warning(s)" -ForegroundColor Red
    exit 1
}
elseif ($script:Warnings -gt 0) {
    Write-Host "! Deep architecture check passed with $($script:Warnings) warning(s)" -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "v All deep architecture checks passed" -ForegroundColor Green
    exit 0
}
