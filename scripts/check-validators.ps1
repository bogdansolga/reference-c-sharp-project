#!/usr/bin/env pwsh
# Validator Location Checker (PowerShell port of check-validators.sh)
# Enforces: endpoints/services inject IValidator<T>; they do not define validators inline.

[CmdletBinding()]
param([switch]$Staged)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'arch-checks.ps1')

$script:Violations = 0
$InlinePattern = 'AbstractValidator<|RuleFor\('

function Get-CsFiles([string]$dir) {
    if ($Staged) {
        (git diff --cached --name-only --diff-filter=ACM) | Where-Object { $_ -match "^$([regex]::Escape($dir))/.*\.cs$" }
    }
    else {
        Get-ChildItem -Path $dir -Recurse -File -Include '*.cs' -ErrorAction SilentlyContinue |
            ForEach-Object { (Resolve-Path -Relative $_.FullName) -replace '\\', '/' -replace '^\./', '' }
    }
}

function Test-Dir([string]$dir, [string]$label) {
    foreach ($file in Get-CsFiles $dir) {
        if (-not (Test-Path $file)) { continue }
        $hit = Select-String -Path $file -Pattern $InlinePattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit) {
            Write-Host "x " -ForegroundColor Red -NoNewline
            Write-Host "$file`:$($hit.LineNumber)"
            Write-Host "    $label defines a validator inline"
            Write-Host "    Validators should live in $SchemaLocation and be injected as IValidator<T>"
            Write-Host ""
            $script:Violations = 1
        }
    }
}

Write-Host "Checking for inline validators..."
Write-Host ""

Test-Dir $SchemaCheckRoutes 'Endpoint'
Test-Dir $SchemaCheckServices 'Service'

if ($script:Violations -eq 1) {
    Write-Host "----------------------------------------"
    Write-Host "x Inline validator violations found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Endpoints and services should not define FluentValidation validators inline."
    Write-Host "Instead, validators should be:"
    Write-Host "  1. Defined in $SchemaLocation"
    Write-Host "  2. Injected via IValidator<T>"
    Write-Host "----------------------------------------"
    exit 1
}
else {
    Write-Host "v Validator location check passed" -ForegroundColor Green
    exit 0
}
