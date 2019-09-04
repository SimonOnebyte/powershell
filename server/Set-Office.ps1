<#
.SYNOPSIS
  Set the office details for a Pedder user

  .DESCRIPTION
  Set the the office phone number and address details for a Pedder user.

.PARAMETER UserName
  The User Name of the user

.PARAMETER OfficeCode
  The two letter code that denotes the office details you want to use


.EXAMPLE
  Set-Office -UserName alice -OfficeCode wn
 
  Set the West Norwood office details for Alice.

.PARAMETER ListOffices
  List out the configured offices and their two letter code

.EXAMPLE
  Set-Office -ListOffices
 
  This will list out the permitted offices and the code to use on the -Office paramater.

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 4th September 2019

.LINK
  

#>

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
    [Parameter(
        ParameterSetName = "SET",
        Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True
    )]
    [ValidateLength(1, 16)]
    [String[]]$UserName,

    [Parameter(
        ParameterSetName = "SET",
        Mandatory = $True,
        Position = 1,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName = $False
    )]
    [ValidateLength(2, 2)]
    [String]$OfficeCode,

    [Parameter(
        ParameterSetName = "LIST",
        Position = 0,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName = $False
    )]
    [switch]$ListOffices

)

BEGIN {

    # Run one-time set-up tasks here, like defining variables, etc.
    Set-StrictMode -Version Latest
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

    # Declare any classes used later in the sript
    # #########################################################################
    Class PedderOffice {
        [string]$ShortCode
        [string]$Name
        [string]$Phone
        [string]$Street
        [string]$City
        [string]$Postcode

        # Constructor
        PedderOffice() { }
        # Office([string]$ShortCode, [string]$Name, [string]$Phone, [string]$Street, [string]$City, [string]$Postcode) {
        #     $this.ShortCode = $ShortCode
        #     $this.Name = $Name
        #     $this.Phone = $Phone
        #     $this.Street = $Street
        #     $this.City = $City
        #     $this.Postcode = $Postcode
        # }
    }

    # Load office details from JSON
    $officesText = Get-Content -Path ".\offices.json"
    $officesJson = $officesText | ConvertFrom-Json 
    Write-Verbose("Loaded Offices from offices.json")
    $offices = @()
    foreach ($officeJson in $officesJson.offices) {
        $newOffice = [PedderOffice]::New()
        $newOffice.ShortCode = $officeJson.short_code
        $newOffice.Name = $officeJson.name
        $newOffice.Phone = $officeJson.phone
        $newOffice.Street = $officeJson.steet
        $newOffice.City = $officeJson.city
        $newOffice.Postcode = $officeJson.postcode
        $offices += $newOffice
        Write-Verbose "$($newOffice.ShortCode) - $($newOffice.Name)"
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
    if ($ListOffices) {
        Write-Output "Accepted values for -OfficeCode Paramter"
        Write-Output ""
        foreach ($office in $offices) {
            Write-Output "  $($office.ShortCode) - $($office.Name)"
        }
        Write-Output ""
    }
    else {
        $office = $null
        foreach ($o in $offices) {
            if ($o.ShortCode -eq $OfficeCode) {
                $office = $o
                break
            }
        }
        if (-not $office) {
            Write-Error "unable to match $OfficeCode to configuired offices"
            exit 1
        }
    
        ForEach ($user In $UserName) {

            # upsertFolder "$dstRoot\$profile"
            $adUser = Get-AdUser $user
            $adUser | Set-AdUser -Office $($office.Name)
            $adUser | Set-AdUser -OfficePhone $($office.Phone)
            $adUser | Set-AdUser -StreetAddres $($office.Street)
            $adUser | Set-AdUser -City $($office.City)
            $adUser | Set-AdUser -PostalCode $($office.Postcode)

            Write-Verbose "Complete   -Param1:$user"
        }
    }
}

END {       
    # Finally, run one-time tear-down tasks here.
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
