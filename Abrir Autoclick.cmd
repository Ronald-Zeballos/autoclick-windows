@echo off
setlocal
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0Autoclick.ps1"
if errorlevel 1 pause
