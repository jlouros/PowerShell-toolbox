Write-Host "Enabling IIS automatic backups!"

Import-Module -Name WebAdministration -ErrorAction Stop

$isTurnedOn = Get-WebConfigurationProperty system.webServer/wdeploy/backup -Name turnedOn | select Value
$isEnabled = Get-WebConfigurationProperty system.webServer/wdeploy/backup -Name enabled | select Value

Set-WebConfigurationProperty system.webServer/wdeploy/backup -Name turnedOn –Value $true
Set-WebConfigurationProperty system.webServer/wdeploy/backup -Name enabled –Value $true