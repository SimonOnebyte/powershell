# Instructions for use
#
# Copy an paste a list of the IP address, MAC address etc from the list Medusa page
# Manager -> (Select a company) -> Status -> Current
#
# Paste the result into a file called macs.txt in this directory
# Then run this script. It will output a list of MACs & IP's along with the manufacturer
param (
    [switch]$ARP=$false
)

class Host {
    [string]$MAC
    [string]$IP
}

function NewHost($mac, $ip) {
    $h = [Host]::new()
    $h.MAC = $mac
    $h.IP = $ip
    $h
}

$apiKey = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJtYWN2ZW5kb3JzIiwiZXhwIjoxODM4MTAyMzgzLCJpYXQiOjE1MjM2MDYzODMsImlzcyI6Im1hY3ZlbmRvcnMiLCJqdGkiOiI3NDhmMWQxNi04NmQyLTRkNjctODFkMS1hMDdmOWFiZjdjMjgiLCJuYmYiOjE1MjM2MDYzODIsInN1YiI6IjIzMCIsInR5cCI6ImFjY2VzcyJ9.6NhgKTluSu8T2Hy-fsLofnG-O6XagGksBSg-fr-cTW9RYgQfQzWeqLqdsnssBSNUZJEJe-fPhzz3Kj57cEaDVQ"
$token = ConvertTo-SecureString -String $apiKey -AsPlainText -Force

$hosts = @()

if ($ARP) {
    $arpCols = 25, 34, 54, 76
    $delim = ","
    $content = Get-Content ".\arp.txt"
    foreach ($line in $content) {
        foreach ($c in $arpCols) {
            $line = $line.Insert($c, $delim)
        }
        $parts = $line.Replace("  ", "").Split(",")
        $hosts += (NewHost $parts[2] $parts[0])
    }
} else {
    $macs = Import-Csv -Path ".\macs.txt" -Header "IP","HWtype","MAC","Flag","Iface" -Delimiter "`t" | Sort-Object Mac
    foreach ($mac in $macs) {
        $hosts += (NewHost $mac.MAC $mac.IP)
    }
}



$url = "https://api.macvendors.com/v1/lookup"

foreach ($h in $hosts) {
    $mac = $($h.MAC)
    $ip = $($h.IP)

    Write-Host "Checking $mac - $ip `t: " -NoNewline
    try {
        $res = Invoke-RestMethod -Uri "$url/$mac)" -Authentication Bearer -Token $token -Headers @{"Accept"="text/plain"}
        Write-Host $res
    } catch {
        Write-Host "Failed" -ForegroundColor Red
    }
    Start-Sleep -Seconds 1
}

Read-Host "Press enter to close the window"