#### This script will make some changes to the stock windows 11 install ####
#### It will make it work more like we (QCT) think it should

####Disable passport####
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name PassportForWork
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork -Name Enabled -Value 0 -PropertyType DWORD

####Set power####
powercfg /change monitor-timeout-ac 30
powercfg /change disk-timeout-ac 30
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

####Remove Crap####
Get-AppxPackage -allusers | where name -notlike "Microsoft.WindowsStore" | where name -notlike "Microsoft.WindowsCalculator" | where name -notlike "Microsoft.MicrosoftStickyNotes" | where name -notlike "Microsoft.Windows.Photos" | Remove-AppPackage
Get-AppxProvisionedPackage -online | where packagename -notlike "Microsoft.WindowsStore*" | where packagename -notlike "Microsoft.WindowsCalculator*" | where packagename -notlike "Microsoft.MicrosoftStickyNotes*" | where packagename -notlike "Microsoft.Windows.Photos*" | Remove-AppxProvisionedPackage -online