REM This batch file will call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.
@echo off
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File initialCleanup.ps1