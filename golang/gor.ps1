<#
.SYNOPSIS
  The purpose of this script is to run Go actions

.DESCRIPTION
  This script gets round the limitiations in PowerShell, when compared to BASH
  that means you have to specific every .go file you want to pass to the 
  Go command.

.PARAMETER Action
  The action you want Go to execute, e.g. build, test or run.

.EXAMPLE
  Run the Go program in the current directory.
  gor -Action run

.EXAMPLE 
  Run the Go program in the current directory.
  gor run

.EXAMPLE 
  Build the Go program in the current directory.
  gor build

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 20th July 2019

#>

Param(
  [Parameter(
    Mandatory = $False,
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromPipelineByPropertyName = $True
  )]
  [ValidateSet("run", "test", "build")]
  [string]$Action = "run"
)

BEGIN {

  # Run one-time set-up tasks here, like defining variables, etc.
  Set-StrictMode -Version Latest
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

  $go = "go"
}


Process {
  # Place all script elements within the process block to allow processing of
  # pipeline correctly.
  
  $modules = Get-ChildItem -Filter "*.go"
  
  $cmd = "$go $Action"
  $params = @($Action)

  Write-Verbose "Running ..."
  foreach ($m in $modules) {
    Write-Verbose " .. $($m.Name)"
    $params += $m.Name
    $cmd += " $($m.Name)"
  }
  
  & $go $params

}

END {       
  # Finally, run one-time tear-down tasks here.
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}