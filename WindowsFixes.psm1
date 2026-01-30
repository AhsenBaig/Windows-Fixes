<#
.SYNOPSIS
    Windows-Fixes PowerShell Module
    
.DESCRIPTION
    This module provides Windows system repair utilities for common update and DISM errors.
    Import this module to access all fix functions in a clean, organized manner.
    
.EXAMPLE
    Import-Module .\WindowsFixes.psm1
    Invoke-Fix0x800f0915 -DryRun
    
.EXAMPLE
    Import-Module .\WindowsFixes.psm1
    Invoke-Fix0x80244018
    
.NOTES
    Author: Ahsen Baig
    Repository: Windows-Fixes
#>

# Import helper functions
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

<#
.SYNOPSIS
    Fixes DISM error 0x800f0915
    
.DESCRIPTION
    Full automated repair workflow for DISM error 0x800f0915.
    Includes logging, dry-run mode, force mode, GUI ISO picker,
    automatic ISO download, and automatic edition/index detection.
    
.PARAMETER DryRun
    Shows what would happen without making changes.
    
.PARAMETER Force
    Skips confirmations and runs all operations automatically.
    
.PARAMETER Chain
    Runs all other fix scripts in the repo after completing this repair.
    
.EXAMPLE
    Invoke-Fix0x800f0915 -DryRun
    
.EXAMPLE
    Invoke-Fix0x800f0915 -Force
#>
function Invoke-Fix0x800f0915 {
    [CmdletBinding()]
    param(
        [switch]$DryRun,
        [switch]$Force,
        [switch]$Chain
    )
    
    $fixScript = Join-Path $scriptPath "src\Fix_0x800f0915.ps1"
    if (Test-Path $fixScript) {
        & $fixScript @PSBoundParameters
    } else {
        Write-Error "Fix script not found: $fixScript"
    }
}

<#
.SYNOPSIS
    Fixes Windows Update error 0x80244018
    
.DESCRIPTION
    Interactive repair workflow for Windows Update error 0x80244018.
    Includes DISM, SFC, service restart, folder cleanup, registry fixes,
    and proxy settings checks.
    
.EXAMPLE
    Invoke-Fix0x80244018
#>
function Invoke-Fix0x80244018 {
    [CmdletBinding()]
    param()
    
    $fixScript = Join-Path $scriptPath "src\Fix_0x80244018.ps1"
    if (Test-Path $fixScript) {
        & $fixScript
    } else {
        Write-Error "Fix script not found: $fixScript"
    }
}

<#
.SYNOPSIS
    Gets available fix scripts
    
.DESCRIPTION
    Lists all available Windows fix scripts in the module.
    Returns information about each fix script including name, path, and description.
    
.EXAMPLE
    Get-AvailableFix
#>
function Get-AvailableFix {
    [CmdletBinding()]
    param()
    
    $srcPath = Join-Path $scriptPath "src"
    if (Test-Path $srcPath) {
        Get-ChildItem -Path $srcPath -Filter "Fix_*.ps1" | ForEach-Object {
            $synopsis = ""
            try {
                # Try to extract synopsis from comment-based help
                $content = Get-Content $_.FullName -Raw
                if ($content -match '\.SYNOPSIS\s+([^\r\n]+)') {
                    $synopsis = $matches[1].Trim()
                }
            } catch {
                # Ignore errors reading synopsis - file may be inaccessible or malformed
                Write-Verbose "Could not read synopsis from $($_.Name): $_"
            }
            
            [PSCustomObject]@{
                Name = $_.BaseName
                Path = $_.FullName
                Description = $synopsis
            }
        }
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Invoke-Fix0x800f0915',
    'Invoke-Fix0x80244018',
    'Get-AvailableFix'
)
