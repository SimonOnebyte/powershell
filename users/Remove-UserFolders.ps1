<#
.SYNOPSIS
    Deletes Redirected folders for disabled and deleted accounts

.DESCRIPTION
    Gets a list of active accounts from the AD and deletes OST folders for that exists with no account

.PARAMETER WhatIf
    Don't delete anything, just report folders and size.

.EXAMPLE
    Clean-RedirectFolders

    Delete Redirect folders from default file share \\SERVER01\REDIRECTS

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 2019/05/15
.LINK
  
#>

[CmdletBinding()]
param (
    # Parameter help description
    [Parameter(
        Mandatory=$false, 
        Position=0, 
        ValueFromPipeline=$false)]
    [switch]$WhatIf
)


Begin {
    Write-Verbose "Remove-UserFolders - Started"
    $stopWatch = [System.Diagnostics.StopWatch]::StartNew()
    # $searchBase = "ou=Staff,ou=Company,dc=ad,dc=pedderproperty,dc=com"
    $locations = @(".\")
}

Process {

    Write-Verbose "Retrieving list of users from the AD"
    # $users = Get-ADUser -SearchBase $searchBase -Filter "Enabled -eq '$true'" | ForEach-Object { $_.sAMAccountName }
    $users = @("Test2")
    Write-Verbose "  ${$users.Lenght} accounts found in the AD"
    
    Write-Verbose "Retriveing list of Redirect Folders from "
    $folders = Get-ChildItem -Path $ostPath -Directory

    Write-Verbose "Comparing $($users.Length) users against $($folders.Length) folders"
    $size = 0
    $count = 0
    $toDelete = @()
    foreach ($folder in $folders) {
        $f = $folder.Name
        $fp = $($folder.FullName)
        if ($users -notcontains $f) {
            $count++
            $size += (Get-ChildItem -Path $fp -Recurse | Measure-Object -Sum Length).Sum / 1GB
            $toDelete += ,$fp
        }
    }

    $toDelete
    Write-Output "$count folders being deleted freeing $size GB"

    foreach ($f in $toDelete) {
        Write-Output "Deleting Redirect folder $f"
        if (-not $WhatIf) {
            Remove-Item -Path $f -Recurse -Force
        }
    }
}

End {
    Write-Verbose "Clean-RedirectFolders - Finished, elapsed time $($stopWatch.Elapsed.TotalSeconds) seconds"
}
