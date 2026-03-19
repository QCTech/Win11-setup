#### This script will make some changes to the stock windows 11 install ####
#### It will make it work more like we (QCT) think it should
#### On a clean machine run the following to download this script directly from github
# Invoke-WebRequest -uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup.ps1  -outfile $baseDirectory\initialCleanup.ps1

# Set some variables
$baseDirectory = "C:\qct\"

# Set window title
$host.ui.RawUI.WindowTitle = "QCT - Windows 11 Cleanup Script"

#Check if baseDirectory exists and create it if not
    if (-not (Test-Path -Path $baseDirectory)) {
        Write-Host "File system path does not exist, creating it."
        New-Item -Path $baseDirectory -ItemType Directory -Force | Out-Null
    }

### Disable passport
#Write-Host "Disabling MS Passport."
#New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name PassportForWork
#New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork -Name Enabled -Value 0 -PropertyType DWORD

### Disable Autorun/AutoPlay
    New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun -Value 255 -Type Dword -Force | Out-Null

### Disable the taskbar "widgets" (system wide)
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "Dsh" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name AllowNewsAndInterests -Type DWORD -Value 0 -Force | Out-Null

### Disable taskbar search box
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0
    Set-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0

### Disable the web search from the start menu
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0
    Set-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0

### Remove crap from logon screen
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ContentDeliveryManager" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWORD -Value 0 -Force | Out-Null
    New-Item -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion" -Name "ContentDeliveryManager" -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWORD -Value 0 -Force | Out-Null

### Set power
    powercfg /change monitor-timeout-ac 30
    powercfg /change disk-timeout-ac 30
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0

### Install Chocolatey
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# just checking, probably not required
    & "$env:ProgramData\chocolatey\bin\choco.exe" upgrade all -y

#Install base programs
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/defaultPrograms.config -OutFile (Join-Path $baseDirectory "defaultPrograms.config")
    & "$env:ProgramData\chocolatey\bin\choco.exe" install (Join-Path $baseDirectory "defaultPrograms.config") -y

### Remove Crap
    $teams = Get-AppxPackage -Name MicrosoftTeams -AllUsers
    if ($null -eq $teams) {
        Write-Output "Microsoft Teams Personal App not present."
        }
    else {
        Write-Output "Removing Microsoft Teams Personal App."
        $teams | Remove-AppPackage -AllUsers -ErrorAction Stop
    }

    Get-AppxPackage -AllUsers |
        Where-Object Name -notlike "Microsoft.WindowsStore" |
        Where-Object Name -notlike "Microsoft.WindowsCalculator" |
        Where-Object Name -notlike "Microsoft.MicrosoftStickyNotes" |
        Where-Object Name -notlike "Microsoft.Windows.Photos" |
        Remove-AppPackage
    Get-AppxProvisionedPackage -Online |
        Where-Object PackageName -notlike "Microsoft.WindowsStore*" |
        Where-Object PackageName -notlike "Microsoft.WindowsCalculator*" |
        Where-Object PackageName -notlike "Microsoft.MicrosoftStickyNotes*" |
        Where-Object PackageName -notlike "Microsoft.Windows.Photos*" |
        Remove-AppxProvisionedPackage -Online
        
### Apply Windows updates
    Start-Service -Name "BITS"
    Install-PackageProvider Nuget -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module PSWindowsUpdate -Force
    Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
    $wuLog = Join-Path $baseDirectory "microsoftUpdate.log"
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll | Out-File $wuLog -Force
