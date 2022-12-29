#### This script will make some changes to the stock windows 11 install ####
#### It will make it work more like we (QCT) think it should

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
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name PassportForWork
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork -Name Enabled -Value 0 -PropertyType DWORD

### Disable Autorun/AutoPlay
New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun  -value 255 -type Dword

### Set power
powercfg /change monitor-timeout-ac 30
powercfg /change disk-timeout-ac 30
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

### Apply Windows updates
# Start BITS Service
Start-Service -Name "BITS"


### Install Chocolatey
Invoke-WebRequest -Uri $backgroundDownloadUrl/qct-desktop.jpg -OutFile $baseDirectory\qct-desktop.jpg
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
### Remove Crap
Get-AppxPackage -allusers | Where-Object name -notlike "Microsoft.WindowsStore" | Where-Object name -notlike "Microsoft.WindowsCalculator" | Where-Object name -notlike "Microsoft.MicrosoftStickyNotes" | Where-Object name -notlike "Microsoft.Windows.Photos" | Remove-AppPackage
Get-AppxProvisionedPackage -online | Where-Object packagename -notlike "Microsoft.WindowsStore*" | Where-Object packagename -notlike "Microsoft.WindowsCalculator*" | Where-Object packagename -notlike "Microsoft.MicrosoftStickyNotes*" | Where-Object packagename -notlike "Microsoft.Windows.Photos*" | Remove-AppxProvisionedPackage -online