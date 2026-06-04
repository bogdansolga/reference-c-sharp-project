#!/usr/bin/env pwsh
# Architecture Hierarchy Checker (PowerShell port of check-architecture.sh)
# Enforces: pages -> API endpoints -> services -> repositories
#   -Staged   Only check staged files (for pre-commit)
#   (default) Check all files (for pre-push)

[CmdletBinding()]
param([switch]$Staged)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'arch-checks.ps1')

$script:Violations = 0

function Get-Files([string]$pattern) {
    if ($Staged) {
        $files = git diff --cached --name-only --diff-filter=ACM
    }
    else {
        $files = Get-ChildItem -Path 'api', 'web' -Recurse -File -Include '*.cs', '*.tsx', '*.ts' -ErrorAction SilentlyContinue |
            ForEach-Object { (Resolve-Path -Relative $_.FullName) -replace '\\', '/' -replace '^\./', '' }
    }
    $files | Where-Object { $_ -and ($_ -match $pattern) }
}

function Test-File([string]$file, [string]$layer, [string[]]$forbidden) {
    if (-not (Test-Path $file)) { return }
    foreach ($pattern in $forbidden) {
        $found = Select-String -Path $file -Pattern $pattern -ErrorAction SilentlyContinue
        foreach ($m in $found) {
            Write-Host "x " -ForegroundColor Red -NoNewline
            Write-Host "$file`:$($m.LineNumber)"
            Write-Host "    $layer cannot import: $pattern"
            Write-Host "    $($m.Line.Trim())"
            Write-Host ""
            $script:Violations = 1
        }
    }
}

Write-Host "Checking architecture hierarchy..."
Write-Host ""

foreach ($f in Get-Files $PagePattern)    { Test-File $f 'Page' $PageForbidden }
foreach ($f in Get-Files $RoutePattern)   { Test-File $f 'Endpoint' $RouteForbidden }
foreach ($f in Get-Files $ServicePattern) { Test-File $f 'Service' $ServiceForbidden }

if ($script:Violations -eq 1) {
    Write-Host "----------------------------------------"
    Write-Host "x Architecture hierarchy violations found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Required hierarchy: pages -> API endpoints -> services -> repositories"
    Write-Host "  - Pages call API endpoints over HTTP"
    Write-Host "  - Endpoints call services (not repositories / Data)"
    Write-Host "  - Services call repositories (not the DbContext / Data)"
    Write-Host "----------------------------------------"
    exit 1
}
else {
    Write-Host "v Architecture hierarchy check passed" -ForegroundColor Green
    exit 0
}
