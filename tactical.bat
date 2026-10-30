@echo off
REM This batch file is part of QCT's setup process for new machines. It will
REM Call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.

powershell.exe -ExecutionPolicy Bypass -File .\tactical.ps1
