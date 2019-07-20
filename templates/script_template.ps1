<#
.SYNOPSIS
  Template script to be used a the basis for all scripts.

  .DESCRIPTION
  Using this template allows the script to repsond to input form the pipeline
  as well as other standard parameters like -WhitIf and -Verbose.

.PARAMETER Param1
  Describe the parameter

.EXAMPLE
  Example
 
  Example description

.EXAMPLE
  Example
 
  Example description

.NOTES
  Authored By: <your full name>
  Email: <your onebyte email address>
  Date: <The date in long form, e.g. 21st February 2019>

.LINK
  <link to any documentation relating to this script in IT Glue>

#>

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
  [Parameter(
    Mandatory = $True,
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromPipelineByPropertyName = $True
  )]
  [ValidateLength(1, 256)]
  [String[]]$Param1,

  [Parameter(
    Mandatory = $False,
    Position = 1,
    ValueFromPipeline = $False,
    ValueFromPipelineByPropertyName = $False
  )]
  [ValidateLength(1, 256)]
  [String[]]$Param2 = "Empty"
)

BEGIN {

  # Run one-time set-up tasks here, like defining variables, etc.
  Set-StrictMode -Version Latest
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

  # Declare any classes used later in the sript
  # #########################################################################
  Class MyClass {
    [string]$Field1

    [int]$Field2

    [ValidateSet("Opt1", "Opt2", "Opt3")]
    [string]$Field3

    # Constructor
    ProfileFolder($Field1, $Field2, $Field3) {
      $this.$Field1 = $Field1
      $this.$Field2 = $Field2
      $this.$Field3 = $Field3
    }
  }

  # Declare any supporting functions here
  # #########################################################################
  function myFunc([string]$p) {
    Write-Host "myFunc called with"
  }
}


Process {
  # Place all script elements within the process block to allow processing of
  # pipeline correctly.
    
  # The process block can be executed multiple times as objects are passed through the pipeline into it.
  ForEach ($item In $Param1) {
    Write-Verbose "Processing -Param1:$item"

    upsertFolder "$dstRoot\$profile"

    Write-Verbose "Complete   -Param1:$item"
  }
}

END {       
  # Finally, run one-time tear-down tasks here.
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
