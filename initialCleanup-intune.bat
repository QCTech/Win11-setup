@echo off
REM This batch file will call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.
powershell.exe -ExecutionPolicy Bypass -File initialCleanup-intune.ps1
