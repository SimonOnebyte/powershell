<#
.SYNOPSIS
    Creates a folder and assigns standard permssions

.PARAMETER Path
    A list of paths to one of more folders that should be created

.PARAMETER Protect
    Deny 'Authenticated Users' the ability to delete the folder

.PARAMETER ReadWrite
    Grant read & write permissions to the specified users/groups

.PARAMETER AdminAccess
    Grant full permissions to the specified users/groups

.PARAMETER Owner
    The account or group to assign as the owner
    Default is Administrators

.PARAMETER ReadOnly
    Grant read only permissions to the specified users/groups

.EXAMPLE
  New-Folder -Path "\\server01\Profiles\bob", "\\server02\Folders\bob" -ReadWrite "bob" 
 
  This will create the two folders and assign read/write permissions to the user account 'bob'
  The owner of the folder will also be set to 'Administrators
  The folders will not be protected from accidentaly renames, moves or deletions

.EXAMPLE
  New-Folder -Path "\\server01\Profiles\bob", "\\server02\Folders\bob" -ReadWrite "bob" -Protected
 
  This will create the two folders and assign read/write permissions to the user account 'bob'
  The owner of the folder will also be set to 'Administrators
  The folders will be protected from accidentaly renames, moves or deletions

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 7th June 2019
  
.LINK
  http://wiki.onebyte.net/doku.php?id=contents:powershell

  NTFS permissions
  https://blog.netwrix.com/2018/04/18/how-to-manage-file-system-acls-with-powershell-scripts/#How%20to%20set%20file%20and%20folder%20permissions
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
    [String[]]$Path,

    [Parameter(
        Mandatory = $False,
        Position = 1
    )]
    [switch]$Protect,

    [Parameter(
        Mandatory = $False,
        Position = 2
    )]
    [ValidateLength(1, 256)]
    [String[]]$ReadWrite,

    [Parameter(
        Mandatory = $False,
        Position = 3
    )]
    [ValidateLength(1, 256)]
    [String[]]$AdminAccess,

    [Parameter(
        Mandatory = $False,
        Position = 4
    )]
    [ValidateLength(1, 256)]
    [String]$Owner="Administrators",

    [Parameter(
        Mandatory = $False,
        Position = 5
    )]
    [ValidateLength(1, 256)]
    [String[]]$ReadOnly

)

BEGIN {

    # Run one-time set-up tasks here, like defining variables, etc.
    Set-StrictMode -Version Latest
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

    function Remove-Permission($StartingDir, $UserOrGroup = "", $All = $false) {
        $acl = get-acl -Path $StartingDir
        if ($UserOrGroup -ne "") {
            foreach ($access in $acl.Access) {
                if ($access.IdentityReference.Value -eq $UserOrGroup) {
                    $acl.RemoveAccessRule($access) | Out-Null
                }
            }
        } 
        if ($All -eq $true) {
            foreach ($access in $acl.Access) {
                $acl.RemoveAccessRule($access) | Out-Null
            }
        }
        Set-Acl -Path $folder.FullName -AclObject $acl
    }

    function Set-Inheritance($StartingDir, $DisableInheritance = $false, $KeepInheritedAcl = $false) {
        $acl = get-acl -Path $StartingDir
        $acl.SetAccessRuleProtection($DisableInheritance, $KeepInheritedAcl)
        $acl | Set-Acl -Path $StartingDir
    }
    function Set-Permission($StartingDir, $UserOrGroup = "", $InheritedFolderPermissions = "ContainerInherit, ObjectInherit", $AccessControlType = "Allow", $PropagationFlags = "None", $AclRightsToAssign) {
        ### The possible values for Rights are:
        # ListDirectory, ReadData, WriteData, CreateFiles, CreateDirectories, AppendData, Synchronize, FullControl
        # ReadExtendedAttributes, WriteExtendedAttributes, Traverse, ExecuteFile, DeleteSubdirectoriesAndFiles, ReadAttributes 
        # WriteAttributes, Write, Delete, ReadPermissions, Read, ReadAndExecute, Modify, ChangePermissions, TakeOwnership
        
        ### Principal expected
        # domain\username 
        
        ### Inherited folder permissions:
        # Object inherit    - This folder and files. (no inheritance to subfolders)
        # Container inherit - This folder and subfolders.
        # Inherit only      - The ACE does not apply to the current file/directory
        
        ### Propogation Flags
        # 
        #define a new access rule.
        $acl = Get-Acl -Path $StartingDir
        $perm = $UserOrGroup, $AclRightsToAssign, $InheritedFolderPermissions, $PropagationFlags, $AccessControlType
        $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $perm
        $acl.SetAccessRule($rule)
        set-acl -Path $StartingDir $acl
    }

    $PROTECTACL = @("Delete", "DeleteSubdirectoriesAndFiles")
    $READWRITEACL = @("Write", "Read", "Delete", "Traverse", "AppendData", "DeleteSubdirectoriesAndFiles")
    $READONLYACL = @("Read")
    $OWNERACL = "FullControl"
        
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
