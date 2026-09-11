@echo off
REM ==========================================
REM Batch file to launch split-terminal.ps1
REM with predefined safe parameters
REM ==========================================

REM Get the directory of this batch file
set SCRIPT_DIR=%~dp0

REM Pass all arguments from batch to PowerShell as an array
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%split-terminal.ps1" %*

REM pause

