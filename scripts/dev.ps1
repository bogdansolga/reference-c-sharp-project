#!/usr/bin/env pwsh
# Run the whole stack with one command:
#   0) Guardrails — install the git hooks on first run (architecture checks on commit/push)
#   1) Backend  — ASP.NET Core API on http://localhost:5099 (creates + seeds SQLite on first run)
#   2) Frontend — Next.js web app on http://localhost:3000 (proxies /api/* to the backend)
# Press Ctrl+C to stop both.
#
# Usage: ./scripts/dev.ps1   (PowerShell 7+; web uses npm by default, $env:PM='bun' to use Bun)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error 'dotnet not found — install the .NET 8 SDK'
    exit 1
}

# Pick a Node package manager for web/: npm by default, Bun optional. Override with $env:PM='bun'.
$pm = $env:PM
if (-not $pm) {
    if (Get-Command npm -ErrorAction SilentlyContinue) { $pm = 'npm' }
    elseif (Get-Command bun -ErrorAction SilentlyContinue) { $pm = 'bun' }
    else { Write-Error 'no package manager found — install Node.js (npm) or Bun for the web/ frontend'; exit 1 }
}
if (-not (Get-Command $pm -ErrorAction SilentlyContinue)) {
    Write-Error "package manager '$pm' not found"
    exit 1
}

# First run: install the git-hook guardrails if they aren't in place yet.
$hooksDir = Join-Path $root '.git/hooks'
if ((Test-Path (Join-Path $root '.git')) -and
    (-not (Test-Path (Join-Path $hooksDir 'pre-commit')) -or -not (Test-Path (Join-Path $hooksDir 'pre-push')))) {
    Write-Host 'Installing git hooks (first run)...'
    & (Join-Path $root 'scripts/git-hooks/install.ps1') $root
}

Write-Host "Installing web dependencies ($pm install)..."
Push-Location (Join-Path $root 'web')
& $pm install
Pop-Location

$procs = @()

function Stop-All {
    Write-Host ''
    Write-Host 'Stopping...'
    foreach ($p in $script:procs) {
        if ($p -and -not $p.HasExited) {
            if ($IsWindows -or $null -eq $IsWindows) {
                # Windows: kill the whole process tree (dotnet/bun spawn children)
                taskkill /PID $p.Id /T /F 2>$null | Out-Null
            }
            else {
                # macOS / Linux fallback
                Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

try {
    Write-Host 'Starting backend  -> http://localhost:5099'
    $procs += Start-Process -FilePath 'dotnet' -ArgumentList 'run' `
        -WorkingDirectory (Join-Path $root 'api') -NoNewWindow -PassThru

    Write-Host 'Starting frontend -> http://localhost:3000'
    $procs += Start-Process -FilePath $pm -ArgumentList 'run', 'dev' `
        -WorkingDirectory (Join-Path $root 'web') -NoNewWindow -PassThru

    Write-Host ''
    Write-Host 'Both running. Log in at the web app with admin/admin or user/user. Press Ctrl+C to stop.'

    # Exit as soon as either process stops.
    while (-not ($procs | Where-Object { $_.HasExited })) {
        Start-Sleep -Seconds 1
    }
}
finally {
    Stop-All
}
