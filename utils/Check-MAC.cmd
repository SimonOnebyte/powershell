@echo off
IF NOT EXIST "C:\Program Files\PowerShell\6\pwsh.exe" (
    echo Please install PowerSehll 6 from https://github.com/PowerShell/PowerShell
    set /p Cont="Press enter to close window"
    exit 1
)
"C:\Program Files\PowerShell\6\pwsh.exe" -file .\Check-MACs.ps1