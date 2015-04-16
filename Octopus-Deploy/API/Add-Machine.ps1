#Requires -Version 4.0

param(
	[parameter(Mandatory=$true)]
	[System.String] $machineName
)
<#
.SYNOPSIS
	Adds a tentacle machine to the development environment for Octopus Deploy
#>

$octopusDeployAPIUrl = 'YOUR OCTOPUS SERVER API URL'
$baseMachinesEndpoint = "$octopusDeployAPIUrl/machines"
$discoverMachineEndpoint = "$baseMachinesEndpoint/discover?host=$machineName&port=10933"

$headers = @{'X-Octopus-ApiKey'='YOUR OCTOPUS API KEY'}

Write-Output "Discovering - $machineName"
$discoverResponse = Invoke-RestMethod -Uri $discoverMachineEndpoint -Headers $headers -Method GET -ContentType 'application/json'

Write-Output "Found       - $machineName - Thumbprint of: " $discoverResponse.Thumbprint
Write-Output "Adding      - $machineName to development environment..."

$addMachineRequestBody = @{
		Uri = 'https://' + $machineName + ':10933';
		EnvironmentIds = [array]('Environments-1');
		Thumbprint = $discoverResponse.Thumbprint;
		CommunicationStyle = 'TentaclePassive';
		Name = "$machineName";
		Roles = ('database-server','web-server');
    }  

$addMachineRequestBodyJSON = ConvertTo-Json -InputObject  $addMachineRequestBody -Compress 
$addMachineResponse = Invoke-RestMethod -Uri $baseMachinesEndpoint -Headers  $headers -Method  POST -ContentType  'application/json' -Body $addMachineRequestBodyJSON

Write-Output "Finished    - $machineName tentacle addition to '$octopusDeployAPIUrl'"
