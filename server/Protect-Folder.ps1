<#
.SYNOPSIS
    Adjusts permissions on a folder to prevent it from being deleted, renamed or moved.

.EXAMPLE
    Protect-Folders -Path C:\Shares\Accounts

    Prevent the folder C:\Shares\Accounts from being renamed, deleted or moved.

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 25th July 2019
.LINK
  
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
  [String[]]$Path
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
    #   $READWRITEACL = @("Write", "Read", "Delete", "Traverse", "AppendData", "DeleteSubdirectoriesAndFiles")
    #   $READONLYACL = @("Read")
    #   $ADMINACL = "FullControl"
            
}

Process {
    # Place all script elements within the process block to allow processing of
    # pipeline correctly.
      
    # The process block can be executed multiple times as objects are passed through the pipeline into it.
    ForEach ($folder In $Path) {
        Write-Verbose "-->Protecting folder: $folder"
        Set-Permission $folder -UserOrGroup "Authenticated Users" -AclRightsToAssign $PROTECTACL -AccessControlType "Deny" -InheritedFolderPermissions "None"
        if ($? -eq $false) {
          continue
        }
    }
}

END {       
  # Finally, run one-time tear-down tasks here.
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
