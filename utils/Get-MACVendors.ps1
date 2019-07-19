<#
.SYNOPSIS
    Reads a list of MAC addresses and displays the vendor for each MAC.

.DESCRIPTION
    Using this template allows the script to repsond to input form the pipeline
    as well as other standard parameters like -WhitIf and -Verbose.

.PARAMETER InFile
    Path to a file that holds a list of MAC addresses and optionally
    associated IP addresses

.EXAMPLE
  Get-MACVendors -InFile macs.txt
 
  Reads the MAC addressess in the file macs.txt and dispay the vendors

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 19th July 2019

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
    [String[]]$InFile
)

BEGIN {

    # Run one-time set-up tasks here, like defining variables, etc.
    Set-StrictMode -Version Latest
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

    # Details for Mac Vendors API
    $apiKey = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJtYWN2ZW5kb3JzIiwiZXhwIjoxODM4MTAyMzgzLCJpYXQiOjE1MjM2MDYzODMsImlzcyI6Im1hY3ZlbmRvcnMiLCJqdGkiOiI3NDhmMWQxNi04NmQyLTRkNjctODFkMS1hMDdmOWFiZjdjMjgiLCJuYmYiOjE1MjM2MDYzODIsInN1YiI6IjIzMCIsInR5cCI6ImFjY2VzcyJ9.6NhgKTluSu8T2Hy-fsLofnG-O6XagGksBSg-fr-cTW9RYgQfQzWeqLqdsnssBSNUZJEJe-fPhzz3Kj57cEaDVQ"
    $token = ConvertTo-SecureString -String $apiKey -AsPlainText -Force
    $apiUrl = "https://api.macvendors.com/v1/lookup"

    # Regex to match MAC addresses
    $MACreg = "([0-9A-F]{2}[:-]){5}([0-9A-F]{2})"

}


Process {
    # Place all script elements within the process block to allow processing of
    # pipeline correctly.
    
    # The process block can be executed multiple times as objects are passed through the pipeline into it.
    ForEach ($file In $InFile) {
        Write-Verbose "Processing -Param1:$file"

        $matches = Select-String -Path $file -Pattern $MACreg

        foreach ($match in $matches) {
            if ($match.Matches.Value -NotMatch "00:00:00:00:00:00") {
                $mac = $match.Matches.Value
                Write-Host "Checking  $mac  : " -NoNewline
                try {
                    $res = Invoke-RestMethod -Uri "$apiUrl/$mac)" -Authentication Bearer -Token $token -Headers @{"Accept"="text/plain"}
                    Write-Host $res
                } catch {
                    Write-Host "Failed" -ForegroundColor Red
                }
                Start-Sleep -Seconds 1
            } 
        }
        Write-Verbose "Complete   -Param1:$file"
    }
}

END {       
    # Finally, run one-time tear-down tasks here.
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."

    Read-Host "Press enter to close the window"
}















