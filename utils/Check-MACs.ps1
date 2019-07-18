# Instructions for use
#
# Copy an paste a list of the IP address, MAC address etc from the list Medusa page
# Manager -> (Select a company) -> Status -> Current
#
# Paste the result into a file called macs.txt in this directory
# Then run this script. It will output a list of MACs & IP's along with the manufacturer
# param (
#     [switch]$ARP=$false
# )

$apiKey = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJtYWN2ZW5kb3JzIiwiZXhwIjoxODM4MTAyMzgzLCJpYXQiOjE1MjM2MDYzODMsImlzcyI6Im1hY3ZlbmRvcnMiLCJqdGkiOiI3NDhmMWQxNi04NmQyLTRkNjctODFkMS1hMDdmOWFiZjdjMjgiLCJuYmYiOjE1MjM2MDYzODIsInN1YiI6IjIzMCIsInR5cCI6ImFjY2VzcyJ9.6NhgKTluSu8T2Hy-fsLofnG-O6XagGksBSg-fr-cTW9RYgQfQzWeqLqdsnssBSNUZJEJe-fPhzz3Kj57cEaDVQ"
$token = ConvertTo-SecureString -String $apiKey -AsPlainText -Force

$MACreg = "([0-9A-F]{2}[:-]){5}([0-9A-F]{2})"

$matches = Select-String -Path ".\macs.txt" -Pattern $MACreg

$macs = @()
foreach ($match in $matches) {
    if ($match.Matches.Value -NotMatch "00:00:00:00:00:00") {
        $macs += $match.Matches.Value
    } 
}

$url = "https://api.macvendors.com/v1/lookup"

foreach ($mac in $macs) {

    Write-Host "Checking  $mac  : " -NoNewline
    try {
        $res = Invoke-RestMethod -Uri "$url/$mac)" -Authentication Bearer -Token $token -Headers @{"Accept"="text/plain"}
        Write-Host $res
    } catch {
        Write-Host "Failed" -ForegroundColor Red
    }
    Start-Sleep -Seconds 1
}

Read-Host "Press enter to close the window"