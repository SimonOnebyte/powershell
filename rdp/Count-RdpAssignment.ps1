$staffOu = "OU=Staff,OU=Company,DC=ad,DC=pedderproperty,DC=com"
$roleOu = "OU=Roles,OU=Company,DC=ad,DC=pedderproperty,DC=com"
$rdpCount = 6

$users = Get-ADUser -Filter * -SearchBase $staffOu -Properties memberOf | Select-Object Name,SamAccountName,MemberOf
$spread = New-Object 'int[]' ($rdpCount+1)
# $spread
$folder = 1

Write-Host "`nStaff who are configured on more than one server:`n "

foreach ($user in $users) {
  $servers = 0
  for ($i=1; $i -le $rdpCount; $i++) {
    $cn = "CN=RDESKTOP0" + ($i) + " Users,$roleOu"
    If ($user.MemberOf -contains $cn ) {
      $spread[0]++
      $spread[$i]++
      $servers++
    }
  }

  if ($servers -gt 1) {
    Write-Host "-> $($user.Name) - $servers"
  }
  $folder++
  if ($folder -gt $rdpCount) { $folder = 1}
}

Write-Host "`nNumber of users assigned to each server:`n "
Write-Host "`nTotal numbner of RDP users: $($spread[0])`n`n"

for ($i = 1; $i -le $rdpCount; $i++) {
  Write-Host "-> Server $($i) Users: $($spread[$i])"
}


