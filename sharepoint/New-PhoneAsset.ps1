<#
.SYNOPSIS
    Ads a new Phone Asset to the asset register

.PARAMETER Tag
    A list of paths to one of more folders that should be created



.EXAMPLE
  New-Folder -Path "\\server01\Profiles\bob", "\\server02\Folders\bob" -ReadWrite "bob" 
 
.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 19th June 2019
  
.LINK
  https://docs.microsoft.com/en-gb/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
  https://social.technet.microsoft.com/wiki/contents/articles/36842.sharepoint-2013-ways-to-add-item-in-list.aspx#SharePoint_PowerShell
  
#>

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
    [Parameter(
        Mandatory = $True,
        Position = 0
    )]
    [ValidateLength(5, 8)]
    [String]$Tag,

    [Parameter(
        Mandatory = $True,
        Position = 1
    )]
    [ValidateSet("CP", "DV", "ED", "FH", "BR", "SY", "WN", "HH", "DC")]
    [String]$Site,

    [Parameter(
        Mandatory = $True,
        Position = 2
    )]
    [ValidateSet("Polycom", "Yealink")]
    [String]$Make,

    [Parameter(
        Mandatory = $False,
        Position = 3
    )]
    [ValidateLength(1, 256)]
    [String]$Model,

    [Parameter(
        Mandatory = $False,
        Position = 4
    )]
    [ValidateLength(4, 4)]
    [String]$Ext,

    [Parameter(
        Mandatory = $False,
        Position = 5
    )]
    [ValidateLength(12, 17)]
    [String]$Mac,

    [Parameter(
        Mandatory = $False,
        Position = 6
    )]
    [ValidateLength(4, 4)]
    [String]$Person
)

BEGIN {

    Write-Verbose "Ensure SharePoint modules are available"
    Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue
    if ($? -eq $false) {
        Write-Error
    }



    
# #Add SharePoint PowerShell Snapin which adds SharePoint specific cmdlets
# Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue
# #Variables that we are going to use for list editing
# $webURL = "http://yoursiteName Jump "
# $listName = "Demo List"
# #Get the SPWeb object and save it to a variable
# $web = Get-SPWeb $webURL
# #Get the SPList object to retrieve the "Demo List"
# $list = $web.Lists[$listName]
# #Create a new item
# $newItem = $list.Items.Add()
# #Add properties to this list item
# $newItem["Title"] = "Add item in sharepoint List Using SharePoint PowerShell"
# #Update the object so it gets saved to the list
# $newItem.Update()

        
}


Process {
    # Place all script elements within the process block to allow processing of
    # pipeline correctly.
    
    # The process block can be executed multiple times as objects are passed through the pipeline into it.
    ForEach ($folder In $Path) {
        Write-Verbose "Creating folder: $folder"

        if (Test-Path($folder)) {
            Write-Error "Unable to create folder that already exists: $folder"
            continue
        }

        New-Item -Path $folder -ItemType Directory | Out-Null
        if ($? -eq $false) {
            continue
        }

        if ($Protect) {
            Write-Verbose "Protecting folder: $folder"
            Set-Permission $folder -UserOrGroup "Authenticated Users" -AclRightsToAssign $PROTECTACL -AccessControlType "Deny" -InheritedFolderPermissions "None"
            if ($? -eq $false) {
                continue
            }
        }

        if ($ReadWrite -is [System.Array]) {
            foreach ($rw in $ReadWrite) {
                Write-Verbose "Permitting Read/Write for: $rw"
                Set-Permission $folder -UserOrGroup $rw -AclRightsToAssign $READWRITEACL
            }
        }

        if ($AdminAccess -is [System.Array]) {
            foreach ($aa in $AdminAccess) {
                Write-Verbose "Permitting Admin Access for: $aa"
                Set-Permission $folder -UserOrGroup $aa -AclRightsToAssign $OWNERACL
            }
        }

        if ($ReadOnly -is [System.Array]) {
            foreach ($ro in $ReadOnly) {
                Write-Verbose "Permitting Read Only for: $ro"
                Set-Permission $folder -UserOrGroup $ro -AclRightsToAssign $READONLYACL
            }
        }

    }
}

END {       
    # Finally, run one-time tear-down tasks here.
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
