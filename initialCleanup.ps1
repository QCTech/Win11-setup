#### This script will make some changes to the stock windows 11 install ####
#### It will make it work more like we (QCT) think it should
#### On a clean machine run the following to download this script directly from github
# Invoke-WebRequest -uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup.ps1  -outfile $baseDirectory\initialCleanup.ps1

# Set some variables
$baseDirectory = "C:\qct\"

# Set window title
$host.ui.RawUI.WindowTitle = "QCT - Windows 11 Cleanup Script"

#Check if baseDirectory exists and create it if not
If ((Test-Path -Path $baseDirectory) -eq $false)
{
    Write-Host "File system path does not exist, creating it."
	New-Item -Path $baseDirectory -ItemType directory
}

### Disable passport
#Write-Host "Disabling MS Passport."
#New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name PassportForWork
#New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork -Name Enabled -Value 0 -PropertyType DWORD

### Disable Autorun/AutoPlay
New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun  -value 255 -type Dword

### Disable the taskbar "widgets" (system wide)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "Dsh"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name AllowNewsAndInterests -Type DWORD -Value 0

### Disable taskbar search box
    ### For the current user
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0

    ### For the default user
    Set-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0

### Disable the web search from the start menu
    ### For the current user
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0
    
    ### For the default user
    Set-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0


### Remove crap from logon screen
    ### for current user
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ContentDeliveryManager"
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWORD -Value 0
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled"  -Type DWORD -Value 0
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled"  -Type DWORD -Value 0
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled"  -Type DWORD -Value 0

    ### for default user
    New-Item -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion" -Name "ContentDeliveryManager"
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWORD -Value 0
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled"  -Type DWORD -Value 0
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled"  -Type DWORD -Value 0
    New-ItemProperty -Path "Registry::\HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled"  -Type DWORD -Value 0

### Set power
powercfg /change monitor-timeout-ac 30
powercfg /change disk-timeout-ac 30
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

### Install Chocolatey
# Download and Run the installer script direct from chocolatey.org
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# just checking, probably not required
%programdata%\chocolatey\bin\choco.exe upgrade all -y

#Install base programs
Invoke-WebRequest -uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/defaultPrograms.config  -outfile $baseDirectory\defaultPrograms.config
%programdata%\chocolatey\bin\choco.exe install $baseDirectory\defaultPrograms.config -y

### Remove Crap
    # Specific target for MS Teams
    If ($null -eq (Get-AppxPackage -Name MicrosoftTeams -AllUsers)) {
        Write-Output “Microsoft Teams Personal App not present.”
    }
    Else {
        Try {
            Write-Output “Removing Microsoft Teams Personal App.”
            Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppPackage -AllUsers
        }
        catch {
            Write-Output “Error removing Microsoft Teams Personal App.”
        }
    }

    # Get rid if the per user stuff first
    Get-AppxPackage -allusers | Where-Object name -notlike "Microsoft.WindowsStore" | Where-Object name -notlike "Microsoft.WindowsCalculator" | Where-Object name -notlike "Microsoft.MicrosoftStickyNotes" | Where-Object name -notlike "Microsoft.Windows.Photos" | Remove-AppPackage

    # Then remove the system wide stuff so additional users don't get it
    Get-AppxProvisionedPackage -online | Where-Object packagename -notlike "Microsoft.WindowsStore*" | Where-Object packagename -notlike "Microsoft.WindowsCalculator*" | Where-Object packagename -notlike "Microsoft.MicrosoftStickyNotes*" | Where-Object packagename -notlike "Microsoft.Windows.Photos*" | Remove-AppxProvisionedPackage -online

### Apply Windows updates
# Start BITS Service
Start-Service -Name "BITS"

# Update Nuget
Install-PackageProvider Nuget -Force

# Get and Install Win update PS module
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module PSWindowsUpdate -Force

# Install MS and Win updates
Add-WUServiceManager -MicrosoftUpdate -Confirm:$false

# Run updates
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll | Out-File "$baseDirectory\microsoftUpdate.log" -Force 
