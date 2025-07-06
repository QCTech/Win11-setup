# Set some variables
$baseDirectory = "C:\qct\"

# Set window title
$host.ui.RawUI.WindowTitle = "QCT - Windows 11 Setup downloader"

#Check if baseDirectory exists and create it if not
If ((Test-Path -Path $baseDirectory) -eq $false)
{
    Write-Host "File system path does not exist, creating it."
	New-Item -Path $baseDirectory -ItemType directory
}

write-host "Downloading initialCleanup.bat."
Invoke-WebRequest -uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup.bat  -outfile $baseDirectory\initialCleanup.bat

write-host "Downloading initialCleanup-intune.bat."
Invoke-WebRequest -uri https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup-intune.bat  -outfile $baseDirectory\initialCleanup-intune.bat

write-host "Please now run either initialCleanup.bat or initialCleanup-intune.bat file depending on what type of setup the customer has."
