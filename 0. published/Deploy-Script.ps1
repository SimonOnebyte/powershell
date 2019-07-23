<#
.SYNOPSIS
  Deploys a script local profile directory for dot sourcing into profile

.DESCRIPTION
  First checks that there is a profile setup and creates if it isn't. Then 
  copies the specified script(s) into the 'myScripts' directory in the same
  directory as the profile directory.

  Each script added is checked to ensure the first line is a 'function' 
  statement and if it is not, the entire script is wrapped ina function 
  whose name is the same as the filename. 

.PARAMETER Path
  The script or scripts that you want dot sources by the local profile

.PARAMETER ForceProfile
  Setting this switch will force the existing profile to be replaced with
  the Onebyte default profile.

.EXAMPLE
  DeployScript -Path .\My-Script.ps1
 
  Will copy the script 'My-Script' into the profile so it is always available

.EXAMPLE
  DeployScript -Path .\My-Script.ps1 -ForceProfile
 
  Will copy the script 'My-Script' into the profile so it is always available
  Will also repalce the existing profile with the default one

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 22th July 2019

#>

# [CmdletBinding(SupportsShouldProcess = $True)]
Param(
  [Parameter(
    Mandatory = $True,
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromPipelineByPropertyName = $True
  )]
  [ValidateLength(1, 256)]
  [String[]]$Path,

  [Parameter(
    Mandatory= $false,
    Position=2
  )]
  [switch]$ForceProfile
)

BEGIN {

  # Run one-time set-up tasks here, like defining variables, etc.
  Set-StrictMode -Version Latest
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."
  $myScripts = "$(Split-Path -Path $profile -Parent)\myScripts"

  if ($ForceProfile) {
    Write-Verbose "ForceProfile specified. Profile will be overwriten"
  }

  $prof = @"
function Global:prompt { "PS [`$Env:username]`$PWD`n>" } 

`$path = Split-Path -Path `$PROFILE

if (Test-Path -Path "`$path\myScripts") {
  Get-ChildItem -Path "`$path\myscripts" -Filter *.ps1 | ForEach-Object {
    . `$_.FullName
  }
}
"@

  Write-Verbose "Checking to see if a profile exists"
  if ((Test-Path $profile) -eq $false -or $ForceProfile) {
    Write-Verbose "Creating profile"
    New-Item -Path $profile -Force | Out-Null
    $prof | Out-File -FilePath $profile
  }

  Write-Verbose "Checking to see if myScripts folder exists"
  if (-not (Test-Path $myScripts)) {
    Write-Verbose "Creating myScripts folder"
    New-Item -Path $myScripts -ItemType Directory | Out-Null
  }
}


Process {
  # Place all script elements within the process block to allow processing of
  # pipeline correctly.
    
  # The process block can be executed multiple times as objects are passed through the pipeline into it.
  ForEach ($item In $Path) {
    Write-Verbose "Deploying -Param1:$item"

    $script = Get-Content -Path $item
    if ($script[0] -notmatch "function") {
      $name = Split-Path -Path $item -Leaf
      Write-Verbose "Wrapping $name in a function"
      $scriptOut = "function $name {`n"
      foreach ($l in $script) {
        $scriptOut += "$l`n"
      }
      $scriptOut += "`n}"
      $script = $scriptOut
    }
    $script | Out-File -FilePath "$myScripts\$name.ps1" -Force
  }
}

END {       
  # Finally, run one-time tear-down tasks here.
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
