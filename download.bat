@echo off
REM This batch file will call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.
curl https://raw.githubusercontent.com/QCTech/Win11-setup/master/download.ps1 -o download.ps1
powershell.exe -ExecutionPolicy Bypass -File download.ps1
