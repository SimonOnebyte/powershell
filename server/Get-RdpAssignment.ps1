$staffOu = "OU=Staff,OU=Company,DC=ad,DC=pedderproperty,DC=com"
$roleOu = "OU=Roles,OU=Company,DC=ad,DC=pedderproperty,DC=com"
$rdpCount = 6

class User {
  [string]$DisplayName
  [string]$UserName
  [string]$Server

  User([string]$DisplayName, [string]$UserName, [string]$Server) {
    $this.DisplayName = $DisplayName
    $this.UserName = $UserName
    $this.Server = $Server
  }
}

$adUsers = Get-ADUser -Filter * -SearchBase $staffOu -Properties memberOf | Select-Object Name,SamAccountName,MemberOf
$users = @()

foreach ($user in $adUsers) {
  
  for ($i=1; $i -le $rdpCount; $i++) {
    $cn = "CN=RDESKTOP0" + ($i) + " Users,$roleOu"
    If ($user.MemberOf -contains $cn ) {
      $u = [User]::New($user.Name, $user.SamAccountName, "Server0$i")
      $users += $u
    }
  }
}

$users
