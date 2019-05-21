
Class VM {
	[string]$Hostname
	[int]$NumaNode
}

$samples = Get-Counter -Counter "\Hyper-V VM Vid Partition(*)\Preferred NUMA Node Index"

$vms = @()

foreach ($sample in $samples.CounterSamples) {
	if ($sample.InstanceName -ne "_total") {
		$newVm = New-Object VM
		$newVm.Hostname = $sample.InstanceName
		$newVm.NumaNode = $sample.CookedValue
		$vms += $newVm
	}
}

$vms | Sort-Object -Property Hostname
