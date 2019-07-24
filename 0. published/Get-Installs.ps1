<#
.SYNOPSIS
    Refreshes the installers for the standard suite of software installed on workstations.

.DESCRIPTION
    Refreshes the installers for the standard suite of software installed on workstations.

    Specific application installers which are downloaded.

      Firefox         is downloaded to Firefox.exe
      Chrome          is downloaded to Chrome.exe
      VLC Player      is downloaded to vlc.exe
      7-Zip           is downloaded to 7zip.msi
      Acrobat Reader  is download to AcrobatReader.exe
    
    Currently it is not possible to download the following.

      Photscape
      
.EXAMPLE
  Refreshes the current directory
 
  Get-Installs

.NOTES
  Authored By: Simon Buckner
  Email: simon@onebyte.net
  Date: 24th July 2019

.LINK
  

#>

[CmdletBinding(SupportsShouldProcess = $True)]
Param(
)

BEGIN {

    # Run one-time set-up tasks here, like defining variables, etc.
    Set-StrictMode -Version Latest
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Started."

    # Disable progress bar to make downloads much quicker
    $ProgressPreference = 'SilentlyContinue'

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

    function adobeDownload([string]$outFile) {
        $FTPFolderUrl = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/"
        $pwd = (Get-Location).Path

        #connect to ftp, and get directory listing
        $FTPRequest = [System.Net.FtpWebRequest]::Create("$FTPFolderUrl") 
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        $FTPResponse = $FTPRequest.GetResponse()
        $ResponseStream = $FTPResponse.GetResponseStream()
        $FTPReader = New-Object System.IO.Streamreader -ArgumentList $ResponseStream
        $DirList = $FTPReader.ReadToEnd()

        #from Directory Listing get last entry in list, but skip one to avoid the 'misc' dir
        $Updates = $DirList -split '[\r\n]' | Where-Object { $_ } | Select-Object -Last 1 -Skip 2

        $LatestFile = "AcroRdrDC" + $Updates + "_en_US.exe"

        #build download url for latest file
        $DownloadURL = "$FTPFolderUrl" + $Updates + "/$LatestFile"

        #download file
        Write-Verbose "Download Acrobat Reader from $DownloadURL to $outFile"
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, "$pwd\$outFile")
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

    adobeDownload -outFile "acrobatReader.exe"
}

END {       
    # Finally, run one-time tear-down tasks here.
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Complete."
}
