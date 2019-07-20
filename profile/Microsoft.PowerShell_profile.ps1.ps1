function Global:prompt { "PS [$Env:username]$PWD`n>" } 

$path = Split-Path -Path $PROFILE

if (Test-Path -Path "$path\myScripts") {
  Get-ChildItem -Path "$path\myscripts" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
  }
}