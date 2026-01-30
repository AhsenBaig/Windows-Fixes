# 0x80244018

# Function to backup a registry entry if it exists
Function Backup-ThresholdOptedIn {
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\Applicability\ThresholdOptedIn"

    # Check if the registry entry exists before backing it up
    if (Test-Path $RegistryPath) {
        # Get the value of the registry entry
        $RegistryValue = Get-ItemProperty -Path $RegistryPath

        # Backup the entry with a unique name (e.g., appending "_backup" to the name)
        $BackupRegistryPath = $RegistryPath + "_backup"
        Set-ItemProperty -Path $BackupRegistryPath -Name $RegistryValue.PSObject.Properties.Name -Value $RegistryValue.PSObject.Properties.Value
    }
}

# Function to add a timestamp to the folder name
Function Add-Timestamp {
    param (
        [string]$FolderPath
    )

    $Timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $NewFolderName = "$FolderPath.old_$Timestamp"
    Rename-Item -Path $FolderPath -NewName $NewFolderName
}

# Prompt for each step
$RunStep1 = Read-Host "Do you want to run Step 1: DISM and SFC commands? (Y/N)"
if ($RunStep1 -eq "Y") {
    # Step 1: DISM and SFC commands
    DISM /Online /Cleanup-Image /ScanHealth
    DISM /Online /Cleanup-Image /RestoreHealth
    sfc /scannow
}

$RunStep2 = Read-Host "Do you want to run Step 2: Restart Update Service and Rename Folders? (Y/N)"
if ($RunStep2 -eq "Y") {
    # Step 2: Restart Update Service and Rename Folders
    Stop-Service -Name wuauserv, cryptSvc, bits, msiserver
    Add-Timestamp -FolderPath "C:\Windows\SoftwareDistribution"
    Add-Timestamp -FolderPath "C:\Windows\System32\catroot2"
    Start-Service -Name wuauserv, cryptSvc, bits, msiserver
}

$RunStep3 = Read-Host "Do you want to run Step 3: Delete the ThresholdOptedIn Registry Entry? (Y/N)"
if ($RunStep3 -eq "Y") {
    # Step 3: Backup and delete the ThresholdOptedIn Registry Entry if it exists
    Backup-ThresholdOptedIn
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -Name "ThresholdOptedIn" -ErrorAction SilentlyContinue
}

$RunStep4 = Read-Host "Do you want to run Step 4: Uninstall third-party antivirus and VPN software? (Y/N)"
if ($RunStep4 -eq "Y") {
    # For third-party antivirus, you would need to provide the specific command or uninstaller for the software you have.
    # Example: Uninstall-ThirdPartyAntivirusSoftware

    # For VPN software, you would also need to provide the specific command or uninstaller.
    # Example: Uninstall-VPNSoftware

    # After uninstalling, reboot the machine.
}

$RunStep5 = Read-Host "Do you want to run Step 5: Check whether BITS service is running? (Y/N)"
if ($RunStep5 -eq "Y") {
    # Step 5: Check whether BITS service is running
    $BITSStatus = Get-Service -Name "BITS"
    if ($BITSStatus.Status -ne "Running") {
        # You can attempt to start the service here
        Start-Service -Name "BITS"
    }
}

$RunStep6 = Read-Host "Do you want to run Step 6: Check Proxy Settings? (Y/N)"
if ($RunStep6 -eq "Y") {
    # Step 6: Check Proxy Settings
    # You can't change the proxy settings directly through PowerShell. It's better to do it manually or guide the user.
    Write-Output "Please check your proxy settings manually and ensure that they are turned off."
}

$Reboot = Read-Host "Do you want to initiate a reboot? (Y/N)"
if ($Reboot -eq "Y") {
    # Optionally, you can initiate a reboot here
    Restart-Computer
}
