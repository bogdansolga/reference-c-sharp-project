#!/usr/bin/env pwsh
# Install git hooks (PowerShell variant — Windows without WSL, or any pwsh host).
# Writes a tiny POSIX shim into .git/hooks that Git invokes (via Git-for-Windows' bundled
# sh) which then runs the PowerShell hook. Requires PowerShell 7+ (pwsh) on PATH.
#
# Usage: ./scripts/git-hooks/install.ps1 [project-path]

param([string]$ProjectPath = '.')

$ErrorActionPreference = 'Stop'

$target = (Resolve-Path $ProjectPath).Path
$gitDir = Join-Path $target '.git'
if (-not (Test-Path $gitDir)) {
    Write-Error "Error: $target is not a git repository"
    exit 1
}

$hooksDir = Join-Path $gitDir 'hooks'
New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null

Write-Host "Installing PowerShell git hooks to: $target"
foreach ($hook in @('pre-commit', 'pre-push')) {
    $shim = @"
#!/bin/sh
# Auto-generated shim — runs the PowerShell hook via pwsh.
exec pwsh -NoProfile -ExecutionPolicy Bypass -File "`$(git rev-parse --show-toplevel)/scripts/git-hooks/$hook.ps1"
"@
    $path = Join-Path $hooksDir $hook
    # Write with LF endings so Git's sh can execute the shim.
    [System.IO.File]::WriteAllText($path, ($shim -replace "`r`n", "`n"))
    Write-Host "  + $hook"
}

Write-Host ""
Write-Host "Done! Hooks run on commit/push (require pwsh 7+ on PATH)."
Write-Host "Edit scripts/arch-checks.ps1 to customize. Bypass once with --no-verify."
