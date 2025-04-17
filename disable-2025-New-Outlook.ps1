write-host "=================================" -foregroundcolor Black -backgroundcolor Yellow
write-host "= QCTech 2025 'new' outlook Fix =" -foregroundcolor Black -backgroundcolor Yellow
write-host "=================================" -foregroundcolor Black -backgroundcolor Yellow
# First we disable the UI that allows a user to enable new outlook
# Then we disable the auto migration and reminder notifications
# Then we disable new outlook if enabled
# Then we remove new outlook

#Disable UI
    write-host "Started 1/5 - disable new outlook select UI" -foregroundcolor Black -backgroundcolor Yellow
    # Setup a couple of variables <-- change these to your situation
    $theRegPath="HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"
    $theRegKey="HideNewOutlookToggle"
    $theRegType="DWord" 
    $theRegValue = 1

    # Return > 0 if something went wrong, assume all is good
    $retval = 0

    #Test if the path exists and create it if not
    if (-not (test-path $theRegPath)){
        write-host "Registry path does not exist, creating..."
        New-Item -Path "$theRegPath" -Force
    }

    # The path should now exist but check to be sure
    if (-not (test-path $theRegPath)){
        write-host "Registry path does not exist, something went wrong..."
        $retval++
        exit
    } else {
        write-host "Registry path exists moving forward"
    }

    #Test if the key exists and create it if not, set it if it does
    if (Get-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -ErrorAction SilentlyContinue){
        # It exists, tell the user and update the key
        write-host "Registry Key exists, updating value..."
        Set-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -Value $theRegValue
    } else {
        # It does not exist, tell the user and create the key
        write-host "Registry Key does not exist, creating..."
        New-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -Value "$theRegValue" -PropertyType "$theRegType" -Force
    }
    # Check the key created correctly and exit if not
    if (Get-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -ErrorAction SilentlyContinue){
        # It exists, good news
        write-host "Registry Key has been set"
    } else {
        # It does not exist, tell the user and create the key
        write-host "Registry Key does not exist, something went wrong, exiting"
        $retval++
        exit
    }

    write-host "Finished 1/5 - disable new outlook select UI" -foregroundcolor Black -backgroundcolor Yellow
    $disableUiRetval=$retval

# Disable the auto migration stuff key 1 of 2
write-host "Started 2/5 - disable auto migrate" -foregroundcolor Black -backgroundcolor Yellow
    # Setup a couple of variables
    $theRegPath="HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"
    $theRegKey="DoNewOutlookAutoMigration"
    $theRegType="DWord" 
    $theRegValue = 0

    # We know the path exists as we tested that above

    #Test if the key exists and create it if not, set it if it does
    if (Get-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -ErrorAction SilentlyContinue){
        # It exists, tell the user and update the key
        write-host "Registry Key exists, updating value..."
        Set-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -Value $theRegValue
    } else {
        # It does not exist, tell the user and create the key
        write-host "Registry Key does not exist, creating..."
        New-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -Value "$theRegValue" -PropertyType "$theRegType" -Force
    }
    # Check the key created correctly and exit if not
    if (Get-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -ErrorAction SilentlyContinue){
        # It exists, good news
        write-host "Registry Key has been set"
    } else {
        # It does not exist, tell the user and create the key
        write-host "Registry Key does not exist, something went wrong, exiting"
        exit
    }

    write-host "Finished 2/5 - disable auto migrate" -foregroundcolor Black -backgroundcolor Yellow

# Disable reminders to migrate
write-host "Started 3/5 - disable retries" -foregroundcolor Black -backgroundcolor Yellow
    # Setup a couple of variables
    $theRegPath="HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"
    $theRegKey="NewOutlookAutoMigrationRetryIntervals"
    $theRegType="DWord" 
    $theRegValue = 0

    # We know the path exists as we tested that above

    #Test if the key exists and create it if not, set it if it does
    if (Get-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -ErrorAction SilentlyContinue){
        # It exists, tell the user and update the key
        write-host "Registry Key exists, updating value..."
        Set-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -Value $theRegValue
    } else {
        # It does not exist, tell the user and create the key
        write-host "Registry Key does not exist, creating..."
        New-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -Value "$theRegValue" -PropertyType "$theRegType" -Force
    }
    # Check the key created correctly and exit if not
    if (Get-ItemProperty -Path "$theRegPath" -Name "$theRegKey" -ErrorAction SilentlyContinue){
        # It exists, good news
        write-host "Registry Key has been set"
    } else {
        # It does not exist, tell the user and create the key
        write-host "Registry Key does not exist, something went wrong, exiting"
        exit
    }

    write-host "Finished 3/5 - disable retries" -foregroundcolor Black -backgroundcolor Yellow

# Remove the fucker
write-host "Started 4/5 - Remove new outlook" -foregroundcolor Black -backgroundcolor Yellow
# Start by removing the provisioned / installed copies
if (Get-AppxPackage -allusers | where-object name -like 'Microsoft.outlookforwindows'){
    write-host "At least one copy found provisioned or installed... nuke it!"
    Get-AppxPackage -allusers | where-object name -like 'Microsoft.outlookforwindows' | remove-apppackage -allusers
} else {
    write-host "good news, no one seems to have been had yet"
}
# Double check
if (Get-AppxPackage -allusers | where-object name -like 'Microsoft.outlookforwindows'){
    write-host "Our attempt to cleanse the system failed. Manual intervention required"
    exit
}

# Now make sure that the provisionedpackage isn't available so new users don't get it by default
if (Get-AppxprovisionedPackage -online |where-object displayname -eq "Microsoft.OutlookForWindows"){
    write-host "The provisioning package Exists, lets fix that"
    Get-AppxprovisionedPackage -online | where-object displayname -eq "Microsoft.OutlookForWindows" | Remove-AppxProvisionedPackage -online
    } else {
    write-host "All clear, no provisioning package"
    }
if (Get-AppxprovisionedPackage -online |where-object displayname -eq "Microsoft.OutlookForWindows"){
    write-host "The provisioning package STILL exists, manual intervention required"
    exit
    }
write-host "Finished 4/5 - Remove new outlook" -foregroundcolor Black -backgroundcolor Yellow

# Prevent it from coming back
write-host "Started 5/5 - Prevent it coming back" -foregroundcolor Black -backgroundcolor Yellow
    # Setup a couple of variables <-- change these to your situation
    $theRegPath="HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate"

    #Test if the path exists and create it if not
    if (test-path $theRegPath){
        write-host "Registry path exists, removing it" -foregroundcolor Black -backgroundcolor Yellow
        Remove-Item $theRegPath -Recurse
    }

    # The path should now exist but check to be sure
    if (test-path $theRegPath){
        write-host "Registry path still exists, something went wrong"
        exit
    } else {
        write-host "Confirmed path no longer exists"
    }
write-host "Finished 5/5 - Prevent it coming back" -foregroundcolor Black -backgroundcolor Yellow

return $retval
