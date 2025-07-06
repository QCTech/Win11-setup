@echo off
REM This batch file will call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.
curl https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup-intune.ps1 -o c:\qct\initialCleanup-intune.ps1
powershell.exe -ExecutionPolicy Bypass -File initialCleanup-intune.ps1
