#!/usr/bin/env pwsh
# Pre-commit hook (PowerShell port, stack-aware: api/ C# + web/ TS).
# Bypass with: git commit --no-verify

$ErrorActionPreference = 'Continue'
$repoRoot = (git rev-parse --show-toplevel)
Set-Location $repoRoot
$scriptsDir = Join-Path $repoRoot 'scripts'

$staged = git diff --cached --name-only --diff-filter=ACM
$stagedCs = $staged | Where-Object { $_ -match '^api/.*\.cs$' }
$stagedWeb = $staged | Where-Object { $_ -match '^web/.*\.(ts|tsx)$' }

if (-not $stagedCs -and -not $stagedWeb) {
    Write-Host "i No C#/TS source staged, skipping checks"
    exit 0
}

$failed = 0
Write-Host "Running pre-commit checks..."
Write-Host ""

function Invoke-Step([string]$name, [scriptblock]$action) {
    Write-Host "-> $name..."
    & $action
    if ($LASTEXITCODE -ne 0) {
        Write-Host "x $name failed" -ForegroundColor Red
        $script:failed = 1
    }
    else {
        Write-Host "✓ $name passed" -ForegroundColor Green
    }
}

if ($stagedCs) {
    Invoke-Step 'Build (dotnet build)' { dotnet build api/Api.csproj --nologo -v q }
    Invoke-Step 'Format (dotnet format --verify-no-changes)' { dotnet format api/Api.csproj --verify-no-changes --no-restore }
    Invoke-Step 'check-architecture' { & "$scriptsDir/check-architecture.ps1" -Staged }
    Invoke-Step 'check-validators' { & "$scriptsDir/check-validators.ps1" -Staged }
    # Deep arch: warnings are non-blocking (script exits 0 on warnings, 1 on errors)
    Invoke-Step 'check-deep-architecture' { & "$scriptsDir/check-deep-architecture.ps1" }
}

if ($stagedWeb -and (Test-Path 'web')) {
    Invoke-Step 'Web lint (biome)' { Push-Location web; bunx biome check .; $code = $LASTEXITCODE; Pop-Location; $global:LASTEXITCODE = $code }
}

Write-Host ""
Write-Host "----------------------------------------"
if ($failed -eq 1) {
    Write-Host "x Pre-commit checks failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Bypass with: git commit --no-verify"
    exit 1
}
else {
    Write-Host "✓ All pre-commit checks passed!" -ForegroundColor Green
    exit 0
}
