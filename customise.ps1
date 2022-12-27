#### This script will customise the look of a stock windows 11 install ####
#### It will make it look more like we (QCT) think it should

# Set some variables
$baseDirectory = "C:\qct\"
$desktopBackground = "qct-desktop.jpg"
$lockScreenBackground = "qct-lock.jpg"
$backgroundDownloadUrl = "https://qctech.co.uk/downloads/windows11/"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

# Set window title
$host.ui.RawUI.WindowTitle = "QCT - Windows 11 Customisation Script"

#Check if baseDirectory exists and create it if not
If ((Test-Path -Path $baseDirectory) -eq $false)
{
    Write-Host "File system path does not exist, creating it."
	New-Item -Path $baseDirectory -ItemType directory
}

# Check if the registry path exists and create if not
if (!(Test-Path $regPath))
{
	Write-Host "Registry path does not exist, creating it."
	New-Item -Path $regPath -Force | Out-Null
}

# Use TLS1.2 for downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download the files
Invoke-WebRequest -Uri $backgroundDownloadUrl/qct-desktop.jpg -OutFile $baseDirectory\qct-desktop.jpg
Invoke-WebRequest -Uri $backgroundDownloadUrl/qct-lock.jpg -OutFile $baseDirectory\qct-lock.jpg

# Set the registry keys for desktop
New-ItemProperty -Path $RegPath -Name DesktopImageStatus -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegPath -Name DesktopImagePath -Value $baseDirectory$desktopBackground -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegPath -Name DesktopImageUrl -Value $baseDirectory$desktopBackground -PropertyType STRING -Force | Out-Null

## Alternative method that might work
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies
# new, key "system"
# new string, Wallpaper, set to path of image
# new string, WallpaperStyle - 0 - Center, 1 tile, 2, stretch, 3 fit, 4 fill

#Set the registry keys for lockscreen
New-ItemProperty -Path $RegPath -Name LockScreenImageStatus -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegPath -Name LockScreenImagePath -Value $baseDirectory$lockScreenBackground -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegPath -Name LockScreenImageUrl -Value $baseDirectory$lockScreenBackground -PropertyType STRING -Force | Out-Null

## Another alternative that might work
# $regKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
# Set-ItemProperty -Path $regKey -Name LockScreenImage -value $baseDirectory$lockScreenBackground

# Make it happen
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True