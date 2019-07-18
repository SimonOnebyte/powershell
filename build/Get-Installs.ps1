<#
.SYNOPSIS
    Refreshes the installers for the standard suite of software installed on workstations.

.EXAMPLE
  Refreshes the current directory
 
  Get-Installs

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 8th July 2019

  .LINK
  <link to any documentation relating to this script in IT Glue>

#>

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
  # [Parameter(
  #     Mandatory = $True,
  #     Position = 0,
  #     ValueFromPipeline = $True,
  #     ValueFromPipelineByPropertyName = $True
  # )]
  # [ValidateLength(1, 256)]
  # [String[]]$Param1,

  # [Parameter(
  #     Mandatory = $False,
  #     Position = 1,
  #     ValueFromPipeline = $False,
  #     ValueFromPipelineByPropertyName = $False
  # )]
  # [ValidateLength(1, 256)]
  # [String[]]$Param2="Empty"
)

BEGIN {

  # Run one-time set-up tasks here, like defining variables, etc.
  Set-StrictMode -Version Latest
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

  # Declare any classes used later in the sript
  # #########################################################################
  Class Installer {
    [string]$Name

    [ValidateSet("exe", "msi")]
    [string]$Type

    [string]$SourceURL


    # Constructor
    Installer($Name, $Type, $SourceURL) {
      $this.Name = $Name
      $this.Type = $Type
      $this.SourceURL = $SourceURL
    }
  }

  # Declare any supporting functions here
  # #########################################################################
  function directDownload([string]$name, [string]$uri, [string]$outFile) {
    Write-Verbose "Downloading $name from $uri to $outFile"
    Invoke-WebRequest -Uri $uri -OutFile $outFile
  }

  function regexLinkDownload([string]$name, [string]$baseUri, [string]$page = "", [string]$outFile, [string]$regex) {
    Write-Verbose "Downloading $name from $baseUri$page to $outFile from link matching $regex"
    
    $res = Invoke-WebRequest -Uri $baseUri$page
    $ignore = $false
    foreach ($link in $res.Links) {
      if (-not $ignore -and $link.href -match $regex) {
        Invoke-WebRequest -Uri "$($baseUri)$($link.href)" -OutFile $outFile
        $ignore = $true
      }
    }
  }
}


Process {
  
  $firefoxUri = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-GB"
  directDownload -name "Firefox" -uri $firefoxUri -outFile "firefox.exe"

  $chromeUri = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BC4348067-C07A-AB3A-24D4-49A0F069B2DC%7D%26lang%3Den%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup64.exe"
  directDownload -name "Chrome" -uri $chromeUri -outFile "chrome.exe"

  $vlcURI = "http://download.videolan.org/pub/videolan/vlc/last/win64/"
  regexLinkDownload -name "VLC Player" -baseUri $vlcURI -outFile "vlc.exe" -regex "vlc-[0-9.]*-win64.exe$"

  $7zipURI = "https://www.7-zip.org/"
  regexLinkDownload -name "7-Zip" -baseUri $7zipURI -page "download.html" -outFile "7zip.msi" -regex "a/7z[0-9]*-x64.msi$"

}

END {       
  # Finally, run one-time tear-down tasks here.
  Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
