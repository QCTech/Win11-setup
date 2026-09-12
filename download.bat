@echo off
echo This batch file is part of QCT's setup process for new machines. It Will
echo -- create c:\qct if it does not exist
echo -- move you over to that dir so the next steps are easier
echo -- delete the current download.ps1 if it exists
echo -- download a powershell script to the current working directory
echo -- Call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
echo.
echo It just works better than trying to call it by hand.
echo.
echo If you don't want that to happen then now would be a good time to hit ctrl + c
pause
echo. 
REM Check for and create the directory
if not exist "C:\qct" (
    echo Dir does not exist, creating it
    mkdir "C:\qct"
)

c:
cd \qct

REM Check for and delete if present the existing download powershell file
if exist "C:\qct\download.ps1" (
    echo Existing download.ps1 exists, removing it
    del "C:\qct\download.ps1"
)

REM Download the most recent download powershell file from github
echo Downloading download.ps1 from github
curl -sS https://raw.githubusercontent.com/QCTech/Win11-setup/master/download.ps1 -o c:\qct\download.ps1

REM Execute the file whilst bypassing the execution policy restrictions
echo setup done, executing script now
echo.
powershell.exe -ExecutionPolicy Bypass -File c:\qct\download.ps1
