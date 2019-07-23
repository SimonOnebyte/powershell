Write-Host ""
Write-Host ""
Write-Host "This script will deploy the PowerShell scripts listed below."
Write-Host "If you continue with this script, your existing profile will be"
Write-Host "overwritten and any customisations will be lost"
Write-Host ""
Write-Host ""

$scripts = Get-ChildItem -Path "." -Filter "*.ps1" | ForEach-Object { 
    if ($_.Name -ne "Microsoft.PowerShell_profile.ps1" -and $_.Name -ne "Deploy-All.ps1") {
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
    $myScripts = (Split-Path -Path $profile -Parent)
    Remove-Item -Path "$myScripts\myScripts\*.ps1"
    $force = $true
    foreach ($script in $scripts) {
        Write-Host "- -->Deploying $($script.Name)"
        if (-not $force) {
            .\Deploy-Script.ps1 -Path ".\$($script.File)"
        }
        else {
            .\Deploy-Script.ps1 -Path ".\$($script.Name)" -ForceProfile
        }
    }
}

Write-Host ""
Write-Host ""
Read-Host "Press enter to close this window"