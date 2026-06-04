#!/usr/bin/env pwsh
# Pre-push hook (PowerShell port, stack-aware). Bypass with: git push --no-verify

$ErrorActionPreference = 'Continue'

# Skip in CI (the pipeline runs these separately)
if ($env:CI -or $env:GITHUB_ACTIONS -or $env:GITLAB_CI -or $env:JENKINS_URL) {
    Write-Host "! CI environment detected - skipping pre-push hook" -ForegroundColor Yellow
    exit 0
}

$repoRoot = (git rev-parse --show-toplevel)
Set-Location $repoRoot
$scriptsDir = Join-Path $repoRoot 'scripts'
$sln = 'reference-c-sharp-project.sln'
$failed = 0

Write-Host "Running pre-push checks..."
Write-Host "----------------------------------------"
Write-Host ""

function Invoke-Step([string]$name, [scriptblock]$action) {
    Write-Host "[$name] Starting..."
    & $action
    if ($LASTEXITCODE -ne 0) {
        Write-Host "x $name: Failed" -ForegroundColor Red
        $script:failed = 1
    }
    else {
        Write-Host "✓ $name: Passed" -ForegroundColor Green
    }
    Write-Host ""
}

Invoke-Step 'Build' { dotnet build $sln --nologo -v q }
Invoke-Step 'Format' { dotnet format $sln --verify-no-changes --no-restore }
Invoke-Step 'Tests' { dotnet test $sln --nologo -v q }
Invoke-Step 'check-architecture' { & "$scriptsDir/check-architecture.ps1" }
Invoke-Step 'check-validators' { & "$scriptsDir/check-validators.ps1" }
Invoke-Step 'check-deep-architecture' { & "$scriptsDir/check-deep-architecture.ps1" }

if (Test-Path 'web') {
    Invoke-Step 'Web Lint' { Push-Location web; bunx biome check .; $code = $LASTEXITCODE; Pop-Location; $global:LASTEXITCODE = $code }
}

# File-size warnings (non-blocking)
Write-Host "[File Size] Checking..."
$violations = 0
$tracked = git ls-files 'api/*.cs' 'web/*.ts' 'web/*.tsx'
foreach ($file in $tracked) {
    if (-not (Test-Path $file)) { continue }
    $lines = (Get-Content $file | Measure-Object -Line).Lines
    switch -Regex ($file) {
        'Service\.cs$' { $threshold = 500; $kind = 'service' }
        '\.tsx$'       { $threshold = 400; $kind = 'component' }
        default        { $threshold = 300; $kind = 'utility' }
    }
    if ($lines -gt $threshold) {
        Write-Host "  $file`: $lines lines ($kind, limit $threshold)"
        $violations++
    }
}
if ($violations -gt 0) { Write-Host "! File Size: $violations file(s) exceed limits" -ForegroundColor Yellow }
else { Write-Host "✓ File Size: Passed" -ForegroundColor Green }
Write-Host ""

Write-Host "----------------------------------------"
if ($failed -eq 1) {
    Write-Host "x Pre-push checks failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Bypass with: git push --no-verify"
    exit 1
}
else {
    Write-Host "✓ All pre-push checks passed!" -ForegroundColor Green
    exit 0
}
