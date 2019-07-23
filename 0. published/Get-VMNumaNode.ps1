<#
.SYNOPSIS
	List VMs by NUMA node
	
.DESCRIPTION
	Examine the runnig Hyper-V guest machines and return the NUMA node
	each one is running on

.EXAMPLE
  .\Get-VMNumaNode.ps1
 
  Lists VMs by NUMA node

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 21st May 2019

  .LINK
  https://onebyte.eu.itglue.com/269174305390819/docs/1121244393242834#documentMode=edit&version=published

#>

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
)

BEGIN {

    # Run one-time set-up tasks here, like defining variables, etc.
    Set-StrictMode -Version Latest
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

    # Declare any classes used later in the sript
    # #########################################################################
    Class VM {
        [int]$NumaNode
        [string]$Hostname

        VM($NumaNode, $Hostname) {
            $this.NumaNode = $NumaNode
            $this.Hostname = $Hostname
        }
    }
}

Process {
    # Place all script elements within the process block to allow processing of
    # pipeline correctly.
    
    $counters = Get-Counter -Counter "\Hyper-V VM Vid Partition(*)\Preferred NUMA Node Index"

    $vms = @()

    foreach ($sample in $counters.CounterSamples) {
        if ($sample.InstanceName -ne "_total") {
            $newVm = [VM]::new($sample.CookedValue, $sample.InstanceName)
            $vms += $newVm
        }
    }

    $vms | Sort-Object -Property NumaNode, Hostname
}

END {       
    # Finally, run one-time tear-down tasks here.
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}




