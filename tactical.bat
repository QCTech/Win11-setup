@echo off
REM This batch file is part of QCT's setup process for new machines. It will
REM Download a powershell script to the current working directory
REM Call the powershell script whilst also bypassing the execution policy so you don't have to do that manually.
REM It just works better than trying to call it by hand.

curl https:qctech.co.uk/downloads/tactical/rmm-onboarding-onboarding-workstation-1.4.0.ps1 -o rmm-onboarding-onboarding-workstation-1.4.0.ps1
powershell.exe -ExecutionPolicy Bypass -File .\rmm-onboarding-onboarding-workstation-1.4.0.ps1
