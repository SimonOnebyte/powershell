@@ECHO off
@@setlocal EnableDelayedExpansion
@@set LF=^


@@SET command=#
@@FOR /F "tokens=*" %%i in ('findstr -bv @@ "%~f0"') DO SET command=!command!!LF!%%i
@@powershell -noprofile -noexit -command !command! &amp; goto:eof


# *** POWERSHELL CODE STARTS HERE *** #
Write-Host ""
Write-Host ""
Write-Host "This script will deploy the PowerShell scripts listed below."
Write-Host "If you continue with this script, your existing profile will be"
Write-Host "overwritten and any customisations will be lost"
Write-Host ""
Write-Host ""

$ep = Get-ExecutionPolicy
if ($ep -ne """Unrestricted""") {
    Write-Host ""
    Write-Host "Before you can run this script, please do the followning."
    Write-Host ""
    Write-Host "1.  Launch PowerShell using 'Run as Administrator'"
    Write-Host "2.  Paste the following commmand into the window"
    Write-Host ""
    Write-Host "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force"
    Write-Host ""
    Write-Host "3.  Run this script again"

    Read-Host "Press enter to close this window"
    Exit
}

$scripts = Get-ChildItem -Path "." -Filter "*.ps1" | ForEach-Object { 
    if ($_.Name -ne """Microsoft.PowerShell_profile.ps1""" -and $_.Name -ne """Deploy-AllPowerShell6.ps1""") {
        $_
    }
} | Sort-Object -Property Name

foreach ($script in $scripts) {
    Write-Host "- --> $($script.Name)"
}

Write-Host ""
Write-Host ""
$r = Read-Host "Type 'yes' and press enter to continue."

if ($r -match 'yes') {
    Unblock-File -Path ".\Deploy-Script.ps1"

    $myScripts = (Split-Path -Path $profile -Parent)
    Remove-Item -Path """$myScripts\myScripts\*.ps1"""
    $force = $true
    foreach ($script in $scripts) {
        Write-Host "- -->Deploying $($script.Name)"
        Unblock-File -Path $script
        if (-not $force) {
            .\Deploy-Script.ps1 -Path """.\$($script.File)"""
        }
        else {
            .\Deploy-Script.ps1 -Path """.\$($script.Name)""" -ForceProfile
        }
    }
}

Write-Host ""
Write-Host ""
Read-Host "Press enter to close this window"
Exit