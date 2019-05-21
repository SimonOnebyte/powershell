function Connect-Office365 {
    param (
        # Key for the client portal to connect to
        [Parameter(Mandatory = $TRUE, Position = 0, ValueFromPipeline = $TRUE, ParameterSetName = "connect")]
        [string]$Key,

        [Parameter(Mandatory = $FALSE, Position = 1, ValueFromPipeline = $FALSE, ParameterSetName = "list")]
        [switch]$List
    
    )

    # Load list of client portals
    $cfgFile = "$($ENV:ProgramData)\Onebyte\office365.json"

    if (-not (Test-Path -Path $cfgFile)) {
        Write-Error "Uanble to find $cfgFile"
        return 1
    }

    $o365 = (Get-Content $cfgFile) -join "`n" | ConvertFrom-Json

    if ($List) {
        $o365.portals | Format-Table
        return 
    }
    $found = $FALSE

    foreach ( $portal in $o365.portals ) {
        if ( $portal.key -like $Key ) {
            $found = $TRUE
            Write-Host "Connecting to $($portal.client) Office 365 portal"

            $cred = Get-Credential -UserName $portal.account -Message "Enter password for $client"

            Write-Verbose "Connecting to MS Online Service"
            Connect-MsolService 
            # -Credential $cred
        
            Write-Verbose "Connecting to Azure AD"
            Connect-AzureAD 
            # -Credential $cred

            Write-Verbose "Connecting to MS Exchange Online"
            $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $cred -Authentication "Basic" -AllowRedirection
            # -Credential $cred -Authentication "Basic" -AllowRedirection
            Import-PSSession $exchangeSession

            break
        }
    }

    if ( $found -ne $TRUE ) {
        Write-Error "Unable to find details for $key"
        return 1
    }
}