@echo off
REM This batch file will call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.
curl https://raw.githubusercontent.com/QCTech/Win11-setup/master/initialCleanup.ps1 -o c:\qct\initialCleanup.ps1
powershell.exe -ExecutionPolicy Bypass -File initialCleanup.ps1