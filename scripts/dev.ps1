#!/usr/bin/env pwsh
# Run the whole stack with one command:
#   1) Backend  — ASP.NET Core API on http://localhost:5099 (creates + seeds SQLite on first run)
#   2) Frontend — Next.js web app on http://localhost:3000 (proxies /api/* to the backend)
# Press Ctrl+C to stop both.
#
# Usage: ./scripts/dev.ps1   (PowerShell 7+)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error 'dotnet not found — install the .NET 8 SDK'
    exit 1
}
if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
    Write-Error 'bun not found — install Bun for the web/ frontend'
    exit 1
}

Write-Host 'Installing web dependencies (bun install)...'
Push-Location (Join-Path $root 'web')
bun install
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
    $procs += Start-Process -FilePath 'bun' -ArgumentList 'dev' `
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
