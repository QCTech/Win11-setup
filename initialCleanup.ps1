#### This script will make some changes to the stock windows 11 install ####
#### It will make it work more like we (QCT) think it should
#### On a clean machine run the following to download this script directly from github
# Invoke-WebRequest -uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup.ps1  -outfile $baseDirectory\initialCleanup.ps1

## Setup Logging
# Get current running path
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
# set logfile to current path with the date appended to the end of the file
$LogFile    = Join-Path $ScriptRoot ("initialcleanup-{0}.txt" -f (Get-Date -Format 'yyyyMMdd'))
# set execution start time
$StartTime  = Get-Date
Start-Transcript -Path $LogFile -Append | Out-Null

function Write-Log {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [ValidateSet('INFO','WARN','ERROR')] [string] $Level = 'INFO'
    )
    $line = "{0} [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    $line | Tee-Object -FilePath $LogFile -Append
}

function Invoke-Step {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [scriptblock] $Action
    )
    Write-Log "START: $Name"
    try {
        & $Action
        Write-Log "OK:    $Name"
    }
    catch {
        Write-Log ("FAIL:  {0} | {1}" -f $Name, $_.Exception.Message) 'ERROR'
        Write-Log ("At: {0}" -f ($_.InvocationInfo.PositionMessage -replace '\r?\n',' ')) 'ERROR'
        # keep going (don’t throw) so you get a full log of what failed
    }
}

Write-Log "Script started. ScriptRoot: $ScriptRoot"
# ---------------------------------------------------------

try {

# Set some variables
$baseDirectory = "C:\qct\"

# Set window title
$host.ui.RawUI.WindowTitle = "QCT - Windows 11 Cleanup Script"

#Check if baseDirectory exists and create it if not
Invoke-Step "Ensure base directory exists: $baseDirectory" {
    if (-not (Test-Path -Path $baseDirectory)) {
        Write-Host "File system path does not exist, creating it."
        New-Item -Path $baseDirectory -ItemType Directory -Force | Out-Null
    }
}

### Disable passport
#Write-Host "Disabling MS Passport."
#New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name PassportForWork
#New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork -Name Enabled -Value 0 -PropertyType DWORD

### Disable Autorun/AutoPlay
Invoke-Step "Disable Autorun AutoPlay" {
    New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun -Value 255 -Type Dword -Force | Out-Null
}

### Disable the taskbar "widgets" (system wide)
Invoke-Step "Disable taskbar widgets" {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "Dsh" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name AllowNewsAndInterests -Type DWORD -Value 0 -Force | Out-Null
}

### Disable taskbar search box
Invoke-Step "Disable taskbar search box (current user)" {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0
}
Invoke-Step "Disable taskbar search box (default user)" {
    Set-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0
}

### Disable the web search from the start menu
Invoke-Step "Disable start menu web search (current user)" {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0
}
Invoke-Step "Disable start menu web search (default user)" {
    Set-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0
}

### Remove crap from logon screen
Invoke-Step "Disable lock screen content (current user)" {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ContentDeliveryManager" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWORD -Value 0 -Force | Out-Null
}
Invoke-Step "Disable lock screen content (default user)" {
    New-Item -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion" -Name "ContentDeliveryManager" -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWORD -Value 0 -Force | Out-Null
}

### Set power
Invoke-Step "Set power settings" {
    powercfg /change monitor-timeout-ac 30
    powercfg /change disk-timeout-ac 30
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
}

### Install Chocolatey
Invoke-Step "Install Chocolatey" {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# just checking, probably not required
Invoke-Step "Chocolatey upgrade all" {
    & "$env:ProgramData\chocolatey\bin\choco.exe" upgrade all -y
}

#Install base programs
Invoke-Step "Download defaultPrograms.config" {
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/defaultPrograms.config -OutFile (Join-Path $baseDirectory "defaultPrograms.config")
}
Invoke-Step "Install base programs (choco config)" {
    & "$env:ProgramData\chocolatey\bin\choco.exe" install (Join-Path $baseDirectory "defaultPrograms.config") -y
}

### Remove Crap
Invoke-Step "Remove Microsoft Teams Personal (if present)" {
    $teams = Get-AppxPackage -Name MicrosoftTeams -AllUsers
    if ($null -eq $teams) {
        Write-Output "Microsoft Teams Personal App not present."
        Write-Log "Microsoft Teams Personal App not present."
    }
    else {
        Write-Output "Removing Microsoft Teams Personal App."
        Write-Log "Removing Microsoft Teams Personal App."
        $teams | Remove-AppPackage -AllUsers -ErrorAction Stop
    }
}

Invoke-Step "Remove AppX packages (per user, keep Store Calculator StickyNotes Photos)" {
    Get-AppxPackage -AllUsers |
        Where-Object Name -notlike "Microsoft.WindowsStore" |
        Where-Object Name -notlike "Microsoft.WindowsCalculator" |
        Where-Object Name -notlike "Microsoft.MicrosoftStickyNotes" |
        Where-Object Name -notlike "Microsoft.Windows.Photos" |
        Remove-AppPackage -ErrorAction Stop
}

Invoke-Step "Remove provisioned AppX packages (system wide, keep Store Calculator StickyNotes Photos)" {
    Get-AppxProvisionedPackage -Online |
        Where-Object PackageName -notlike "Microsoft.WindowsStore*" |
        Where-Object PackageName -notlike "Microsoft.WindowsCalculator*" |
        Where-Object PackageName -notlike "Microsoft.MicrosoftStickyNotes*" |
        Where-Object PackageName -notlike "Microsoft.Windows.Photos*" |
        Remove-AppxProvisionedPackage -Online -ErrorAction Stop
}

### Apply Windows updates
Invoke-Step "Start BITS service" {
    Start-Service -Name "BITS"
}

Invoke-Step "Install PackageProvider Nuget" {
    Install-PackageProvider Nuget -Force
}

Invoke-Step "Trust PSGallery" {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
}

Invoke-Step "Install PSWindowsUpdate module" {
    Install-Module PSWindowsUpdate -Force
}

Invoke-Step "Add Microsoft Update service manager" {
    Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
}

Invoke-Step "Install Windows Updates (log to microsoftUpdate.log)" {
    $wuLog = Join-Path $baseDirectory "microsoftUpdate.log"
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll | Out-File $wuLog -Force
    Write-Log "Windows Update output written to: $wuLog"
}

}
finally {
    $EndTime  = Get-Date
    $Duration = $EndTime - $StartTime

    Write-Log "---- Timing ----"
    Write-Log ("Start time: {0}" -f $StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
    Write-Log ("End time:   {0}" -f $EndTime.ToString('yyyy-MM-dd HH:mm:ss'))
    Write-Log ("Total time: {0:hh\:mm\:ss\.fff}" -f $Duration)

    Stop-Transcript | Out-Null
}
