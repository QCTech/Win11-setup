#### This script will check for and if missing install all the required powershell bits and bobs then
#### Install all windows updates whilst logging all available and all install output to a file

# Set window title
$host.ui.RawUI.WindowTitle = "QCT - Windows 11 Windows update Script"

# Ensure TLS 1.2 for PSGallery downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Ensure log directory exists
$logPath = "C:\qct\WindowsUpdate.txt"
$logDir = [System.IO.Path]::GetDirectoryName($logPath)
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Timestamp header
Add-Content -Path $logPath -Value "`n===== New update run started $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ====="

# Check for NuGet provider
Write-Host "Checking for NuGet provider..."
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Host "NuGet provider not found. Installing..."
    Install-PackageProvider -Name NuGet -Force
} else {
    Write-Host "NuGet provider is already installed."
}

# Check for PSWindowsUpdate module
Write-Host "Checking for PSWindowsUpdate module..."
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "PSWindowsUpdate module not found. Installing from PSGallery..."
    Install-Module -Name PSWindowsUpdate -Force
} else {
    Write-Host "PSWindowsUpdate module is already installed."
}

# Import the module
Import-Module PSWindowsUpdate -Force

Write-Host "PSWindowsUpdate module is ready for use."

# Log list of pending updates
Write-Host "Retrieving list of available updates..."
"--- Available Updates ---" | Add-Content -Path $logPath
Get-WindowsUpdate | Out-String | Add-Content -Path $logPath

# Install updates and log output
Write-Host "Installing all available updates..."
"--- Installing Updates ---" | Add-Content -Path $logPath
Install-WindowsUpdate -AcceptAll -AutoReboot:$false -Confirm:$false | Out-String | Add-Content -Path $logPath

Write-Host "Update process complete. Log saved to $logPath"
# Timestamp footer
Add-Content -Path $logPath -Value "`n===== run finished $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ====="