

class OutRow {
  [string]$UPN
  [string]$Email
  [string]$DisplayName
  [string]$Title
  [string]$Office
  [string]$Department
  [string]$PhoneNumber
  [string]$MobileNumber
}

$users = Get-MsolUser | Where-Object { $_.IsLicensed -eq $true }

$out = @()

foreach ($u in $users) {
  $row = [OutRow]::New()
  $row.UPN = $u.UserPrincipalName
  $row.Email = $u.UserPrincipalName
  $row.DisplayName = $u.DisplayName
  $row.Title = $u.Title
  $row.Office = $u.Office
  $row.Department = $u.Department
  $row.PhoneNumber = $u.Office
  $row.MobileNumber = $u.MobilePhone
  $out += $row
}

$out | ConvertTo-Json | Out-File -FilePath ".\Get-OfficeUsers.json" -Encoding utf8 -Force
$out | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath ".\Get-OfficeUsers.csv" -Encoding utf8 -Force