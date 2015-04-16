Write-Output 'Enabling IIS automatic backups!'

Import-Module -Name WebAdministration -ErrorAction Stop

$isTurnedOn = Get-WebConfigurationProperty system.webServer/wdeploy/backup -Name turnedOn | Select-Object Value
$isEnabled = Get-WebConfigurationProperty system.webServer/wdeploy/backup -Name enabled | Select-Object Value

Set-WebConfigurationProperty system.webServer/wdeploy/backup -Name turnedOn –Value $true
Set-WebConfigurationProperty system.webServer/wdeploy/backup -Name enabled –Value $true