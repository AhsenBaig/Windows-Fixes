# Windows-Fixes

A collection of automated PowerShell scripts to fix common Windows update and system repair errors.

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/AhsenBaig/Windows-Fixes/workflows/PowerShell%20CI/badge.svg)](https://github.com/AhsenBaig/Windows-Fixes/actions)

## 🚀 Quick Start

### Option 1: Run Individual Fix Scripts

```powershell
# Fix DISM error 0x800f0915
.\src\Fix_0x800f0915.ps1

# Fix Windows Update error 0x80244018
.\src\Fix_0x80244018.ps1
```

### Option 2: Use the Wrapper Script

```powershell
# Interactive mode - select which fixes to run (default)
.\Run-AllFixes.ps1

# Run all fixes automatically
.\Run-AllFixes.ps1 -All

# Dry-run mode (see what would happen)
.\Run-AllFixes.ps1 -DryRun

# List available fixes
.\Run-AllFixes.ps1 -ListOnly
```

**Note**: The wrapper script uses mutually exclusive modes - you can only use one mode at a time.

### Option 3: Import as PowerShell Module

```powershell
# Import the module
Import-Module .\WindowsFixes.psm1

# Use module functions
Invoke-Fix0x800f0915 -DryRun
Invoke-Fix0x80244018
Get-AvailableFixes
```

## 📋 Available Fixes

### Fix_0x800f0915.ps1
**DISM Error 0x800f0915 - Component Store Corruption**

Full automated repair workflow with:
- ✅ Logging to timestamped log files
- ✅ Dry-run mode for testing
- ✅ Force mode for unattended execution
- ✅ GUI ISO picker
- ✅ Automatic ISO download (UUP) [planned]
- ✅ Automatic edition/index detection
- ✅ Wrapper chaining for all scripts

**Usage:**
```powershell
# Interactive with prompts
.\src\Fix_0x800f0915.ps1

# Dry-run (no changes)
.\src\Fix_0x800f0915.ps1 -DryRun

# Fully automated
.\src\Fix_0x800f0915.ps1 -Force

# Chain all fixes after completion
.\src\Fix_0x800f0915.ps1 -Chain
```

**What it does:**
1. Checks for Administrator privileges
2. Detects Windows build version
3. Detects or prompts for Windows ISO
4. Mounts ISO if needed
5. Detects install.wim or install.esd
6. Auto-detects Windows edition and index
7. Runs DISM RestoreHealth with correct source
8. Runs SFC /scannow
9. Optionally chains other fix scripts

### Fix_0x80244018.ps1
**Windows Update Error 0x80244018 - Update Service Issues**

Interactive repair workflow with:
- ✅ DISM and SFC scans
- ✅ Windows Update service restart
- ✅ SoftwareDistribution and catroot2 cleanup
- ✅ Registry fixes (ThresholdOptedIn)
- ✅ BITS service check
- ✅ Proxy settings verification
- ✅ Timestamped backups

**Usage:**
```powershell
# Interactive mode with prompts for each step
.\src\Fix_0x80244018.ps1
```

**What it does:**
1. Runs DISM ScanHealth and RestoreHealth
2. Runs SFC /scannow
3. Stops Windows Update services
4. Renames SoftwareDistribution and catroot2 folders (with timestamp backup)
5. Restarts Windows Update services
6. Backs up and removes ThresholdOptedIn registry entry
7. Checks BITS service status
8. Verifies proxy settings
9. Optionally reboots the system

## 🛠️ Requirements

- **Windows 10/11** (or Windows Server 2016+)
- **PowerShell 5.1+** (Windows PowerShell or PowerShell Core)
- **Administrator privileges** (required for all fixes)

## 📦 Installation

1. Clone or download this repository:
   ```powershell
   git clone https://github.com/AhsenBaig/Windows-Fixes.git
   cd Windows-Fixes
   ```

2. Run PowerShell as Administrator

3. Set execution policy if needed:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 🔧 Module Usage

The `WindowsFixes.psm1` module provides a clean interface to all fixes:

```powershell
# Import the module
Import-Module .\WindowsFixes.psm1

# List available fixes
Get-AvailableFixes

# Run specific fixes
Invoke-Fix0x800f0915 -Force
Invoke-Fix0x80244018

# Dry-run mode
Invoke-Fix0x800f0915 -DryRun

# Remove module when done
Remove-Module WindowsFixes
```

## 🤖 Wrapper Script Features

The `Run-AllFixes.ps1` wrapper provides orchestration capabilities with four mutually exclusive modes:

- **Default (Interactive) Mode**: Choose which fixes to run via prompts
- **All Mode**: Run all fixes sequentially (uses -Force where supported)
- **DryRun Mode**: Preview actions without making changes (only for scripts that support it)
- **ListOnly Mode**: Display available fixes without running them
- **Color-coded output**: Easy to read logs
- **Error handling**: Continues even if one fix fails
- **No admin required for ListOnly**: Other modes require Administrator privileges

## 📝 Logging

All scripts generate detailed log files:
- **Location**: Same directory as the script
- **Format**: `Fix_<ErrorCode>_YYYYMMDD_HHMMSS.log`
- **Content**: Complete transcript of all operations
- **Excluded from git**: Log files are in `.gitignore`

## 🧪 Testing

Run the PowerShell linter and tests:

```powershell
# Install PSScriptAnalyzer if not already installed
Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser

# Run linter on all scripts
Get-ChildItem -Path .\src -Filter *.ps1 -Recurse | ForEach-Object {
    Invoke-ScriptAnalyzer -Path $_.FullName
}

# Run linter on module
Invoke-ScriptAnalyzer -Path .\WindowsFixes.psm1

# Run linter on wrapper
Invoke-ScriptAnalyzer -Path .\Run-AllFixes.ps1
```

The repository includes a GitHub Actions workflow that automatically lints all PowerShell scripts on every push and pull request.

## 🔒 Security

- All scripts require Administrator privileges
- Registry entries are backed up before modification
- Folders are renamed with timestamps (not deleted)
- DryRun mode available for testing
- No external dependencies or downloads (except optional UUP)
- Code is linted with PSScriptAnalyzer

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Follow existing code style
4. Test your changes thoroughly
5. Ensure scripts pass PSScriptAnalyzer
6. Submit a pull request

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

## 👤 Author

**Ahsen Baig**

## 🐛 Known Issues

- UUP automatic ISO download is not yet implemented
- Some fixes may require a system reboot

## 📚 Additional Resources

- [Microsoft DISM Documentation](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism---deployment-image-servicing-and-management-technical-reference-for-windows)
- [Windows Update Troubleshooting](https://support.microsoft.com/en-us/windows/windows-update-troubleshooting)
- [System File Checker](https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e)

## ⚠️ Disclaimer

These scripts modify system settings and should be used with caution. Always:
- Create a system restore point before running
- Backup important data
- Test in a non-production environment first
- Review the code before running

The authors are not responsible for any damage caused by these scripts.
