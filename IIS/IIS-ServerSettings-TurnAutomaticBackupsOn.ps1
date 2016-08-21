Write-Output -InputObject 'Enabling IIS automatic backups!'

Import-Module -Name WebAdministration -ErrorAction Stop

$isTurnedOn = Get-WebConfigurationProperty -Filter system.webServer/wdeploy/backup -Name turnedOn | Select-Object -ExpandProperty Value
$isEnabled = Get-WebConfigurationProperty -Filter system.webServer/wdeploy/backup -Name enabled | Select-Object -ExpandProperty Value

Set-WebConfigurationProperty -Filter system.webServer/wdeploy/backup -Name turnedOn –Value $true
Set-WebConfigurationProperty -Filter system.webServer/wdeploy/backup -Name enabled –Value $true