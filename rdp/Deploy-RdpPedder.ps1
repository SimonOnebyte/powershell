
# Global Options
$rdps = @("1", "2", "3", "4", "5", "6")

$users = Get-ChildItem "C:\Users"
ForEach ($user in $users) {
    if (Test-Path "C:\Users\$($user.Name)\Desktop" ) {
        Get-ChildItem "C:\Users\$($user.Name)\Desktop" -Filter "*.rdp" | Remove-Item
    }
}

foreach ($rdp in $rdps) {
    $src = "https://resources.onebyte.net/pps001/Server$rdp.rdp"
    $dst = "C:\Users\Public\Desktop\Server $rdp.rdp"

    Write-Output "Downloading: $src"
    (New-Object Net.WebClient).DownloadFile($src, $dst)
}
