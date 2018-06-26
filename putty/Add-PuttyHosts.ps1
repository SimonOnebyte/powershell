
Function New-RegString 
{
    param (
        [Parameter(Position=0)]
        $key, 
        [Parameter(Position=1)]
        $name, 
        [Parameter(Position=2)]
        $value
    )
    
    Try
    {
        New-ItemProperty $key -Name $name -PropertyType "String" -Value $value -ErrorAction Stop | Out-Null
    }
    Catch
    {
        Write-Output "ERROR: $key`n $($_)"
    }
}

Function New-RegDWord 
{
    param (
        [Parameter(Position=0)]
        $key, 
        [Parameter(Position=1)]
        $name, 
        [Parameter(Position=2)]
        $value
    )
    
    If ($value -NotLike "0x*") 
    {
        $value = "0x$value"
    }
    
    Try
    {
        New-ItemProperty $key -Name $name -PropertyType "DWord" -Value $value -ErrorAction Stop | Out-Null
    }
    Catch
    {
        Write-Output "ERROR: $key`n $($_)"
    }
}

$hosts = Import-Csv "PuttyHosts.csv"

$regBase = "Registry::HKCU\SOFTWARE\SimonTatham\PuTTY\Sessions\"    

Write-Verbose "Deleting old hosts"
$oldSessions = Get-ChildItem $regBase | Select-Object PsChildName | Where { $_.PsChildName -like "fw:*" -or $_.PsChildName -like "rtr:*" }
ForEach ($session in $oldSessions) {
    Remove-Item "$regBase\$($session.PsChildName)" -Recurse

}

For ( $i=0; $i -lt $hosts.Length; $i++ ) 
{
    $type = "$($hosts[$i].Type)"
    $dns  = "$($hosts[$i].Host)"
    $fqdn = "$dns.onebyte.net"
    $name = "$($hosts[$i].Name)"
    $user = "$($hosts[$i].User)"

    $key  = "$regBase$($type): $dns : $name".Replace(" ", "%20")
    
    $msg = $fqdn.PadRight(35-$fqdn.Lenght, ' ')
    Write-Host "Adding host $msg `t" -NoNewLine
    
    If ( Test-Path "$key" ) 
    {
        Remove-Item "$key" -Recurse -Confirm:$false
        Write-Host "R" -NoNewLine
    }
    
    Try 
    {
        New-Item "$key" -ErrorAction Stop | Out-Null
    }
    Catch
    {
        Write-Output "ERROR: $key`n $($_)"
    }
    
    New-RegDWord -Key $key -Name "Present" -Value "00000001"
    New-RegString -Key $key -Name "HostName" -Value "$fqdn"
    New-RegString -Key $key -Name "LogFileName" -Value "putty.log"
    New-RegDWord -Key $key -Name "LogType" -Value "00000000"
    New-RegDWord -Key $key -Name "LogFileClash" -Value "ffffffff"
    New-RegDWord -Key $key -Name "LogFlush" -Value "00000001"
    New-RegDWord -Key $key -Name "SSHLogOmitPasswords" -Value "00000001"
    New-RegDWord -Key $key -Name "SSHLogOmitData" -Value "00000000"
    New-RegString -Key $key -Name "Protocol" -Value "ssh"
    New-RegDWord -Key $key -Name "PortNumber" -Value "00000016"
    New-RegDWord -Key $key -Name "CloseOnExit" -Value "00000001"
    New-RegDWord -Key $key -Name "WarnOnClose" -Value "00000001"
    New-RegDWord -Key $key -Name "PingInterval" -Value "00000000"
    New-RegDWord -Key $key -Name "PingIntervalSecs" -Value "00000000"
    New-RegDWord -Key $key -Name "TCPNoDelay" -Value "00000001"
    New-RegDWord -Key $key -Name "TCPKeepalives" -Value "00000000"
    New-RegString -Key $key -Name "TerminalType" -Value "xterm"
    New-RegString -Key $key -Name "TerminalSpeed" -Value "38400,38400"
    New-RegString -Key $key -Name "TerminalModes" -Value "INTR=A,QUIT=A,ERASE=A,KILL=A,EOF=A,EOL=A,EOL2=A,START=A,STOP=A,SUSP=A,DSUSP=A,REPRINT=A,WERASE=A,LNEXT=A,FLUSH=A,SWTCH=A,STATUS=A,DISCARD=A,IGNPAR=A,PARMRK=A,INPCK=A,ISTRIP=A,INLCR=A,IGNCR=A,ICRNL=A,IUCLC=A,IXON=A,IXANY=A,IXOFF=A,IMAXBEL=A,ISIG=A,ICANON=A,XCASE=A,ECHO=A,ECHOE=A,ECHOK=A,ECHONL=A,NOFLSH=A,TOSTOP=A,IEXTEN=A,ECHOCTL=A,ECHOKE=A,PENDIN=A,OPOST=A,OLCUC=A,ONLCR=A,OCRNL=A,ONOCR=A,ONLRET=A,CS7=A,CS8=A,PARENB=A,PARODD=A,"
    New-RegDWord -Key $key -Name "AddressFamily" -Value "00000000"
    New-RegString -Key $key -Name "ProxyExcludeList" -Value ""
    New-RegDWord -Key $key -Name "ProxyDNS" -Value "00000001"
    New-RegDWord -Key $key -Name "ProxyLocalhost" -Value "00000000"
    New-RegDWord -Key $key -Name "ProxyMethod" -Value "00000000"
    New-RegString -Key $key -Name "ProxyHost" -Value "proxy"
    New-RegDWord -Key $key -Name "ProxyPort" -Value "00000050"
    New-RegString -Key $key -Name "ProxyUsername" -Value ""
    New-RegString -Key $key -Name "ProxyPassword" -Value ""
    New-RegString -Key $key -Name "ProxyTelnetCommand" -Value "connect %host %port\\n"
    New-RegString -Key $key -Name "Environment" -Value ""
    New-RegString -Key $key -Name "UserName" -Value "$user"
    New-RegDWord -Key $key -Name "UserNameFromEnvironment" -Value "00000000"
    New-RegString -Key $key -Name "LocalUserName" -Value ""
    New-RegDWord -Key $key -Name "NoPTY" -Value "00000000"
    New-RegDWord -Key $key -Name "Compression" -Value "00000000"
    New-RegDWord -Key $key -Name "TryAgent" -Value "00000001"
    New-RegDWord -Key $key -Name "AgentFwd" -Value "00000000"
    New-RegDWord -Key $key -Name "GssapiFwd" -Value "00000000"
    New-RegDWord -Key $key -Name "ChangeUsername" -Value "00000000"
    New-RegString -Key $key -Name "Cipher" -Value "aes,blowfish,3des,WARN,arcfour,des"
    New-RegString -Key $key -Name "KEX" -Value "dh-gex-sha1,dh-group14-sha1,dh-group1-sha1,rsa,WARN"
    New-RegDWord -Key $key -Name "RekeyTime" -Value "0000003c"
    New-RegString -Key $key -Name "RekeyBytes" -Value "1G"
    New-RegDWord -Key $key -Name "SshNoAuth" -Value "00000000"
    New-RegDWord -Key $key -Name "SshBanner" -Value "00000001"
    New-RegDWord -Key $key -Name "AuthTIS" -Value "00000000"
    New-RegDWord -Key $key -Name "AuthKI" -Value "00000001"
    New-RegDWord -Key $key -Name "AuthGSSAPI" -Value "00000001"
    New-RegString -Key $key -Name "GSSLibs" -Value "gssapi32,sspi,custom"
    New-RegString -Key $key -Name "GSSCustom" -Value ""
    New-RegDWord -Key $key -Name "SshNoShell" -Value "00000000"
    New-RegDWord -Key $key -Name "SshProt" -Value "00000002"
    New-RegString -Key $key -Name "LogHost" -Value ""
    New-RegDWord -Key $key -Name "SSH2DES" -Value "00000000"
    New-RegString -Key $key -Name "PublicKeyFile" -Value ""
    New-RegString -Key $key -Name "RemoteCommand" -Value ""
    New-RegDWord -Key $key -Name "RFCEnviron" -Value "00000000"
    New-RegDWord -Key $key -Name "PassiveTelnet" -Value "00000000"
    New-RegDWord -Key $key -Name "BackspaceIsDelete" -Value "00000001"
    New-RegDWord -Key $key -Name "RXVTHomeEnd" -Value "00000000"
    New-RegDWord -Key $key -Name "LinuxFunctionKeys" -Value "00000000"
    New-RegDWord -Key $key -Name "NoApplicationKeys" -Value "00000000"
    New-RegDWord -Key $key -Name "NoApplicationCursors" -Value "00000000"
    New-RegDWord -Key $key -Name "NoMouseReporting" -Value "00000000"
    New-RegDWord -Key $key -Name "NoRemoteResize" -Value "00000000"
    New-RegDWord -Key $key -Name "NoAltScreen" -Value "00000000"
    New-RegDWord -Key $key -Name "NoRemoteWinTitle" -Value "00000000"
    New-RegDWord -Key $key -Name "RemoteQTitleAction" -Value "00000001"
    New-RegDWord -Key $key -Name "NoDBackspace" -Value "00000000"
    New-RegDWord -Key $key -Name "NoRemoteCharset" -Value "00000000"
    New-RegDWord -Key $key -Name "ApplicationCursorKeys" -Value "00000000"
    New-RegDWord -Key $key -Name "ApplicationKeypad" -Value "00000000"
    New-RegDWord -Key $key -Name "NetHackKeypad" -Value "00000000"
    New-RegDWord -Key $key -Name "AltF4" -Value "00000001"
    New-RegDWord -Key $key -Name "AltSpace" -Value "00000000"
    New-RegDWord -Key $key -Name "AltOnly" -Value "00000000"
    New-RegDWord -Key $key -Name "ComposeKey" -Value "00000000"
    New-RegDWord -Key $key -Name "CtrlAltKeys" -Value "00000001"
    New-RegDWord -Key $key -Name "TelnetKey" -Value "00000000"
    New-RegDWord -Key $key -Name "TelnetRet" -Value "00000001"
    New-RegDWord -Key $key -Name "LocalEcho" -Value "00000002"
    New-RegDWord -Key $key -Name "LocalEdit" -Value "00000002"
    New-RegString -Key $key -Name "Answerback" -Value "PuTTY"
    New-RegDWord -Key $key -Name "AlwaysOnTop" -Value "00000000"
    New-RegDWord -Key $key -Name "FullScreenOnAltEnter" -Value "00000000"
    New-RegDWord -Key $key -Name "HideMousePtr" -Value "00000000"
    New-RegDWord -Key $key -Name "SunkenEdge" -Value "00000000"
    New-RegDWord -Key $key -Name "WindowBorder" -Value "00000001"
    New-RegDWord -Key $key -Name "CurType" -Value "00000000"
    New-RegDWord -Key $key -Name "BlinkCur" -Value "00000000"
    New-RegDWord -Key $key -Name "Beep" -Value "00000000"
    New-RegDWord -Key $key -Name "BeepInd" -Value "00000000"
    New-RegString -Key $key -Name "BellWaveFile" -Value ""
    New-RegDWord -Key $key -Name "BellOverload" -Value "00000001"
    New-RegDWord -Key $key -Name "BellOverloadN" -Value "00000005"
    New-RegDWord -Key $key -Name "BellOverloadT" -Value "000007d0"
    New-RegDWord -Key $key -Name "BellOverloadS" -Value "00001388"
    New-RegDWord -Key $key -Name "ScrollbackLines" -Value "000000c8"
    New-RegDWord -Key $key -Name "DECOriginMode" -Value "00000000"
    New-RegDWord -Key $key -Name "AutoWrapMode" -Value "00000001"
    New-RegDWord -Key $key -Name "LFImpliesCR" -Value "00000000"
    New-RegDWord -Key $key -Name "CRImpliesLF" -Value "00000000"
    New-RegDWord -Key $key -Name "DisableArabicShaping" -Value "00000000"
    New-RegDWord -Key $key -Name "DisableBidi" -Value "00000000"
    New-RegDWord -Key $key -Name "WinNameAlways" -Value "00000001"
    New-RegString -Key $key -Name "WinTitle" -Value ""
    New-RegDWord -Key $key -Name "TermWidth" -Value "00000050"
    New-RegDWord -Key $key -Name "TermHeight" -Value "00000018"
    New-RegString -Key $key -Name "Font" -Value "Courier New"
    New-RegDWord -Key $key -Name "FontIsBold" -Value "00000000"
    New-RegDWord -Key $key -Name "FontCharSet" -Value "00000000"
    New-RegDWord -Key $key -Name "FontHeight" -Value "0000000a"
    New-RegDWord -Key $key -Name "FontQuality" -Value "00000000"
    New-RegDWord -Key $key -Name "FontVTMode" -Value "00000004"
    New-RegDWord -Key $key -Name "UseSystemColours" -Value "00000000"
    New-RegDWord -Key $key -Name "TryPalette" -Value "00000000"
    New-RegDWord -Key $key -Name "ANSIColour" -Value "00000001"
    New-RegDWord -Key $key -Name "Xterm256Colour" -Value "00000001"
    New-RegDWord -Key $key -Name "BoldAsColour" -Value "00000001"
    New-RegString -Key $key -Name "Colour0" -Value "187,187,187"
    New-RegString -Key $key -Name "Colour1" -Value "255,255,255"
    New-RegString -Key $key -Name "Colour2" -Value "0,0,0"
    New-RegString -Key $key -Name "Colour3" -Value "85,85,85"
    New-RegString -Key $key -Name "Colour4" -Value "0,0,0"
    New-RegString -Key $key -Name "Colour5" -Value "0,255,0"
    New-RegString -Key $key -Name "Colour6" -Value "0,0,0"
    New-RegString -Key $key -Name "Colour7" -Value "85,85,85"
    New-RegString -Key $key -Name "Colour8" -Value "187,0,0"
    New-RegString -Key $key -Name "Colour9" -Value "255,85,85"
    New-RegString -Key $key -Name "Colour10" -Value "0,187,0"
    New-RegString -Key $key -Name "Colour11" -Value "85,255,85"
    New-RegString -Key $key -Name "Colour12" -Value "187,187,0"
    New-RegString -Key $key -Name "Colour13" -Value "255,255,85"
    New-RegString -Key $key -Name "Colour14" -Value "0,0,187"
    New-RegString -Key $key -Name "Colour15" -Value "85,85,255"
    New-RegString -Key $key -Name "Colour16" -Value "187,0,187"
    New-RegString -Key $key -Name "Colour17" -Value "255,85,255"
    New-RegString -Key $key -Name "Colour18" -Value "0,187,187"
    New-RegString -Key $key -Name "Colour19" -Value "85,255,255"
    New-RegString -Key $key -Name "Colour20" -Value "187,187,187"
    New-RegString -Key $key -Name "Colour21" -Value "255,255,255"
    New-RegDWord -Key $key -Name "RawCNP" -Value "00000000"
    New-RegDWord -Key $key -Name "PasteRTF" -Value "00000000"
    New-RegDWord -Key $key -Name "MouseIsXterm" -Value "00000000"
    New-RegDWord -Key $key -Name "RectSelect" -Value "00000000"
    New-RegDWord -Key $key -Name "MouseOverride" -Value "00000001"
    New-RegString -Key $key -Name "Wordness0" -Value "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
    New-RegString -Key $key -Name "Wordness32" -Value "0,1,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1"
    New-RegString -Key $key -Name "Wordness64" -Value "1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,2"
    New-RegString -Key $key -Name "Wordness96" -Value "1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1"
    New-RegString -Key $key -Name "Wordness128" -Value "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"
    New-RegString -Key $key -Name "Wordness160" -Value "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"
    New-RegString -Key $key -Name "Wordness192" -Value "2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2"
    New-RegString -Key $key -Name "Wordness224" -Value "2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2"
    New-RegString -Key $key -Name "LineCodePage" -Value ""
    New-RegDWord -Key $key -Name "CJKAmbigWide" -Value "00000000"
    New-RegDWord -Key $key -Name "UTF8Override" -Value "00000001"
    New-RegString -Key $key -Name "Printer" -Value ""
    New-RegDWord -Key $key -Name "CapsLockCyr" -Value "00000000"
    New-RegDWord -Key $key -Name "ScrollBar" -Value "00000001"
    New-RegDWord -Key $key -Name "ScrollBarFullScreen" -Value "00000000"
    New-RegDWord -Key $key -Name "ScrollOnKey" -Value "00000000"
    New-RegDWord -Key $key -Name "ScrollOnDisp" -Value "00000001"
    New-RegDWord -Key $key -Name "EraseToScrollback" -Value "00000001"
    New-RegDWord -Key $key -Name "LockSize" -Value "00000000"
    New-RegDWord -Key $key -Name "BCE" -Value "00000001"
    New-RegDWord -Key $key -Name "BlinkText" -Value "00000000"
    New-RegDWord -Key $key -Name "X11Forward" -Value "00000000"
    New-RegString -Key $key -Name "X11Display" -Value ""
    New-RegDWord -Key $key -Name "X11AuthType" -Value "00000001"
    New-RegString -Key $key -Name "X11AuthFile" -Value ""
    New-RegDWord -Key $key -Name "LocalPortAcceptAll" -Value "00000000"
    New-RegDWord -Key $key -Name "RemotePortAcceptAll" -Value "00000000"
    New-RegString -Key $key -Name "PortForwardings" -Value ""
    New-RegDWord -Key $key -Name "BugIgnore1" -Value "00000000"
    New-RegDWord -Key $key -Name "BugPlainPW1" -Value "00000000"
    New-RegDWord -Key $key -Name "BugRSA1" -Value "00000000"
    New-RegDWord -Key $key -Name "BugIgnore2" -Value "00000000"
    New-RegDWord -Key $key -Name "BugHMAC2" -Value "00000000"
    New-RegDWord -Key $key -Name "BugDeriveKey2" -Value "00000000"
    New-RegDWord -Key $key -Name "BugRSAPad2" -Value "00000000"
    New-RegDWord -Key $key -Name "BugPKSessID2" -Value "00000000"
    New-RegDWord -Key $key -Name "BugRekey2" -Value "00000000"
    New-RegDWord -Key $key -Name "BugMaxPkt2" -Value "00000000"
    New-RegDWord -Key $key -Name "StampUtmp" -Value "00000001"
    New-RegDWord -Key $key -Name "LoginShell" -Value "00000001"
    New-RegDWord -Key $key -Name "ScrollbarOnLeft" -Value "00000000"
    New-RegString -Key $key -Name "BoldFont" -Value ""
    New-RegDWord -Key $key -Name "BoldFontIsBold" -Value "0018ff78"
    New-RegDWord -Key $key -Name "BoldFontCharSet" -Value "2a8cace8"
    New-RegDWord -Key $key -Name "BoldFontHeight" -Value "770971d5"
    New-RegString -Key $key -Name "WideFont" -Value ""
    New-RegDWord -Key $key -Name "WideFontIsBold" -Value "0018faf0"
    New-RegDWord -Key $key -Name "WideFontCharSet" -Value "0018ff78"
    New-RegDWord -Key $key -Name "WideFontHeight" -Value "77053cc3"
    New-RegString -Key $key -Name "WideBoldFont" -Value ""
    New-RegDWord -Key $key -Name "WideBoldFontIsBold" -Value "000003f8"
    New-RegDWord -Key $key -Name "WideBoldFontCharSet" -Value "0018faf0"
    New-RegDWord -Key $key -Name "WideBoldFontHeight" -Value "0100acc8"
    New-RegDWord -Key $key -Name "ShadowBold" -Value "00000000"
    New-RegDWord -Key $key -Name "ShadowBoldOffset" -Value "00000001"
    New-RegString -Key $key -Name "SerialLine" -Value "COM1"
    New-RegDWord -Key $key -Name "SerialSpeed" -Value "00002580"
    New-RegDWord -Key $key -Name "SerialDataBits" -Value "00000008"
    New-RegDWord -Key $key -Name "SerialStopHalfbits" -Value "00000002"
    New-RegDWord -Key $key -Name "SerialParity" -Value "00000000"
    New-RegDWord -Key $key -Name "SerialFlowControl" -Value "00000001"
    New-RegString -Key $key -Name "WindowClass" -Value ""

    Write-Host "C"

}

