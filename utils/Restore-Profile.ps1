<#
.SYNOPSIS
    Restores key files and folders to a user profile that have previously been
    backed up by the Backup-Profile script.
.DESCRIPTION
    
.PARAMETER Param1
     
.EXAMPLE
  Example
 
  Example description
.EXAMPLE
  Example
 
  Example description
.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 22nd February 2019
.LINK
  http://wiki.onebyte.net/doku.php?id=contents:powershell

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
    [String[]]$Profiles,

    [Parameter(
        Mandatory = $False,
        Position = 1,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName = $False
    )]
    [ValidateLength(1, 256)]
    [String[]]$Server = "."
)

BEGIN {

    # Run one-time set-up tasks here, like defining variables, etc.
    Set-StrictMode -Version Latest
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

    Class ProfileFolder {
        [string]$Source

        [string]$Destination

        [ValidateSet("Normal", "Firefox", "AutoComplete")]
        [string]$Mode

        ProfileFolder($source, $destination, $mode) {
            $this.Source = $source
            $this.Destination = $destination
            $this.Mode = $mode
        }
    }

    function normalBackup([string]$src, [string]$dst) {
        if (-not (Test-Path -Path "$src")) {
            Write-Verbose " Skippng (Does not exist): $src"
            return
        }

        Copy-Item -Path "$src\*.*" -Destination "$dst" -Force -Recurse
    }
    
    function firefoxBackup([string]$src, [string]$dst) {
        if (-not (Test-Path -Path "$src")) {
            Write-Verbose " Skippng (Does not exist): $src"
            return
        }
        $profile = (Get-ChildItem $dst)[0].Name

        Copy-Item -Path "$src\*.*" -Destination "$dst\$profile\" -Force -Recurse
    }
    
    # function autoCompleteBackup([string]$src, [string]$dst) {
    #     if (-not (Test-Path -Path "$src")) {
    #         Write-Verbose " Skippng (Does not exist): $src"
    #         return
    #     }
    #     upsertFolder "$dst"
    #     $srcAC = (Get-ChildItem -Path $src -Filter "Stream_Autocomplete_0_*.dat")[0].Name
    #     Copy-Item -Path "$src\$cache" -Destination "$dst" -Force
    # }

    # function upsertFolder($path) {
    #     Write-Verbose " Upserting: $path"
    #     if (-not (Test-Path -Path "$path")) {
    #         New-Item -Path "$path" -ItemType Directory
    #     }
    # }

    $Folders = @(
        [ProfileFolder]::New("Chrome", "AppData\Local\Google\Chrome\User Data\Default", "Normal"),
        [ProfileFolder]::New("Firefox", "AppData\Roaming\Mozilla\Firefox\Profiles", "Firefox"),
        [ProfileFolder]::New("Signatures", "AppData\Roaming\Microsoft\Signatures", "Normal"),
        # [ProfileFolder]::New("Autocomplete", "AppData\Local\Microsoft\Outlook\RoamCache", "AutoComplete"),
        [ProfileFolder]::New("Desktop", "Desktop", "Normal"),
        [ProfileFolder]::New("Documents", "Documents", "Normal"),
        [ProfileFolder]::New("Favorites", "Favorites", "Normal"),
        [ProfileFolder]::New("Links", "Links", "Normal"),
        [ProfileFolder]::New("Pictures", "Pictures", "Normal"),
        [ProfileFolder]::New("Videos", "Videos", "Normal")
    )

    $srcRoot = "$((Get-Location).Path)"

    $dstRoot = "C:\Users"
    if ($Server -ne ".") {
        $dstRoot = "\\$Server\C$\Users"
    }
}


Process {
    # Place all script elements within the process block to allow processing of
    # pipeline correctly.
    
    # The process block can be executed multiple times as objects are passed through the pipeline into it.
    ForEach ($profile In $Profiles) {
        Write-Verbose "Restoring from backup of $profile"

        foreach ($folder in $Folders) {
            Write-Verbose "    Restoring -> $srcRoot\$profile\$($folder.Source)"
            switch -Exact ($folder.Mode) {
                "FireFox" {
                    firefoxBackup "$srcRoot\$profile\$($folder.Source)" "$dstRoot\$profile\$($folder.Destination)"
                }
                "AutoComplete" {
                    autoCompleteBackup "$srcRoot\$profile\$($folder.Source)" "$dstRoot\$profile\$($folder.Destination)"
                }
                Default {
                    normalBackup "$srcRoot\$profile\$($folder.Source)" "$dstRoot\$profile\$($folder.Destination)" 
                }
            }
        }


        Write-Verbose "Restore of $profile complete"
    }
}

END {       
    # Finally, run one-time tear-down tasks here.
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}









# # CMD exe's that are needed
# $takeown = "takeown"
# $robocopy = "robocopy"

# $sRoot = "C:\REST\FILES\O\UserData\SSaunders.NSP\Application Data\Mozilla\Firefox\Profiles"

# $userdata = @(
#     @("charles.wates", "CWates.NSP"),
#     @("coral.lewis", "CLewis.NSP"),
#     @("edmond.calthorpe", "EdmondCalthorpe"),
#     @("edward.snowdon", "ESnowdon.NSP"),
#     @("jeanette.jones", "JJones.NSP"),
#     @("jo.lenharth", "JoLenharth"),
#     @("natasha.walker", "natasha"),
#     @("richard.trimming", "RTrimming.NSP"),
#     @("simone.saunders", "SSaunders.NSP"),
#     @("tracey.wallace", "TraceyWallace")
# )

# foreach ($user in $userdata) {
#     $sourceRoot = "C:\REST\FILES\O\UserData\$($user[1])\Application Data\Mozilla\Firefox\Profiles"
#     $sourceProfile = (Get-ChildItem $sourceRoot)[0].Name
#     $source = "$sourceRoot\$sourceProfile"

#     $destRoot = "F:\Users\$($user[0])\AppData\Roaming\Mozilla\Firefox\Profiles"
#     $destProfile = (Get-ChildItem $destRoot)[0].Name
#     $dest = "$destRoot\$destProfile\"

#     $params = @(
#         "$source",
#         "$dest",
#         "/mir"
#     )
#     # Write-Host  $params
#     & $robocopy $params
# }
