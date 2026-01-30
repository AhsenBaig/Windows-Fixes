<#
.SYNOPSIS
    Run all Windows fix scripts
    
.DESCRIPTION
    Wrapper script that orchestrates all Windows repair utilities in the repository.
    Can run all fixes sequentially or allow selection of specific fixes.
    
.PARAMETER All
    Run all fix scripts automatically without prompting (Force mode)
    
.PARAMETER Interactive
    Show menu to select which fixes to run (default)
    
.PARAMETER DryRun
    Run in dry-run mode (no actual changes made)
    
.PARAMETER ListOnly
    Only list available fixes without running them
    
.EXAMPLE
    .\Run-AllFixes.ps1 -Interactive
    Shows menu to select which fixes to run
    
.EXAMPLE
    .\Run-AllFixes.ps1 -All
    Runs all fixes in sequence with Force mode
    
.EXAMPLE
    .\Run-AllFixes.ps1 -DryRun
    Shows what would happen without making changes
    
.EXAMPLE
    .\Run-AllFixes.ps1 -ListOnly
    Lists all available fixes
    
.NOTES
    Author: Ahsen Baig
    Repository: Windows-Fixes
#>

[CmdletBinding(DefaultParameterSetName='Interactive')]
param(
    [Parameter(ParameterSetName='All')]
    [switch]$All,
    
    [Parameter(ParameterSetName='Interactive')]
    [switch]$Interactive,
    
    [Parameter(ParameterSetName='DryRun')]
    [switch]$DryRun,
    
    [Parameter(ParameterSetName='ListOnly')]
    [switch]$ListOnly
)

# Color-coded logging
function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-ErrorMsg($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Success($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }

# Banner
Write-Host "`n======================================" -ForegroundColor Magenta
Write-Host "  Windows-Fixes - Run All Fixes" -ForegroundColor Magenta
Write-Host "======================================`n" -ForegroundColor Magenta

# Admin check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-ErrorMsg "This script must be run as Administrator."
    exit 1
}

# Get all fix scripts
$srcPath = Join-Path $PSScriptRoot "src"
$fixScripts = Get-ChildItem -Path $srcPath -Filter "Fix_*.ps1" | Sort-Object Name

if ($fixScripts.Count -eq 0) {
    Write-ErrorMsg "No fix scripts found in $srcPath"
    exit 1
}

Write-Info "Found $($fixScripts.Count) fix script(s):"
$fixScripts | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
Write-Host ""

# Handle ListOnly mode
if ($ListOnly) {
    Write-Info "Available fixes:"
    foreach ($script in $fixScripts) {
        $synopsis = (Select-String -Path $script.FullName -Pattern "^\.SYNOPSIS" -Context 0,2 -ErrorAction SilentlyContinue)
        $description = ""
        if ($synopsis) {
            $description = ($synopsis.Context.PostContext | Where-Object { $_ -match '\S' } | Select-Object -First 1).Trim()
        }
        Write-Host "`n$($script.BaseName):" -ForegroundColor Cyan
        if ($description) {
            Write-Host "  $description" -ForegroundColor Gray
        }
    }
    Write-Host ""
    exit 0
}

# Handle All mode
if ($All) {
    Write-Warn "Running all fixes in Force mode..."
    foreach ($script in $fixScripts) {
        Write-Info "Running $($script.Name)..."
        try {
            & $script.FullName -Force
            Write-Success "Completed $($script.Name)"
        } catch {
            Write-ErrorMsg "Failed to run $($script.Name): $_"
        }
        Write-Host ""
    }
    Write-Success "All fixes completed."
    exit 0
}

# Handle DryRun mode
if ($DryRun) {
    Write-Warn "Running in DRY-RUN mode (no actual changes will be made)..."
    foreach ($script in $fixScripts) {
        Write-Info "Would run: $($script.Name)"
        # Check if script supports DryRun parameter
        $scriptContent = Get-Content $script.FullName -Raw
        if ($scriptContent -match '\$DryRun') {
            try {
                & $script.FullName -DryRun
                Write-Success "Dry-run completed for $($script.Name)"
            } catch {
                Write-ErrorMsg "Failed to dry-run $($script.Name): $_"
            }
        } else {
            Write-Warn "$($script.Name) does not support DryRun mode"
        }
        Write-Host ""
    }
    exit 0
}

# Interactive mode (default)
Write-Info "Interactive mode - Select fixes to run:"
Write-Host ""

$selectedScripts = @()
foreach ($i = 0; $i -lt $fixScripts.Count; $i++) {
    $script = $fixScripts[$i]
    $choice = Read-Host "Run $($script.Name)? (Y/N)"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        $selectedScripts += $script
    }
}

if ($selectedScripts.Count -eq 0) {
    Write-Warn "No fixes selected. Exiting."
    exit 0
}

Write-Host ""
Write-Info "Running $($selectedScripts.Count) selected fix(es)..."
Write-Host ""

foreach ($script in $selectedScripts) {
    Write-Info "Running $($script.Name)..."
    try {
        & $script.FullName
        Write-Success "Completed $($script.Name)"
    } catch {
        Write-ErrorMsg "Failed to run $($script.Name): $_"
    }
    Write-Host ""
}

Write-Success "All selected fixes completed."
