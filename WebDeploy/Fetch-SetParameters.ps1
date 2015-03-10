#Requires -Version 4.0

Param(
	[Parameter(Mandatory=$true)]
	[string]$AppName,
	[string]$TargetEnvironment = "localhost",
	[string]$PackageLocation = $PSScriptRoot,
	[string]$StashFilesRestUrl = "http://STASH_URL/rest/api/1.0/projects/POW/repos/REPOSITORY_NAME/files/ApplicationsEnvironmentSettings?limit=1000",
	[string]$StashSettingsLocationUrl = "http://STASH_URL/projects/PROJECT_NAME/repos/REPOSITORY_NAME/browse/ApplicationsEnvironmentSettings/{0}?raw",
	[switch]$AllowDefaultSettings
)

Function FindSettingsFileOnStash {
	param(
		[string]$TargetEnvironment,
		[string]$AppName,
		[string]$FilesStashRestUrl)

	return (Invoke-RestMethod -Uri $FilesStashRestUrl -Method Get).values | where { $_ -match $AppName -and $_ -match $TargetEnvironment }
}

Function DownloadSettingsFileFromStash {
	param(
		[string]$settingsFile,
		[string]$StashSettingsLocationUrl,
		[string]$targetDeploymentFolder)

	$targetFileLocation = Join-Path $targetDeploymentFolder $settingsFile

	$webClient = New-Object System.Net.WebClient 
	$fileDownloadUrl = [string]::Format($StashSettingsLocationUrl, $settingsFile)
	$webClient.DownloadFile($fileDownloadUrl, $targetFileLocation)
	$webClient.Dispose();
}

Write-Host "Initializing WebDeploy powershell script with the following input parameters:"
Write-Host "   - Application name -> '$AppName'"
Write-Host "   - Target environment -> '$TargetEnvironment'"
Write-Host "   - Package location -> '$PackageLocation'"
Write-Host "   - Stash files REST url -> '$StashFilesRestUrl'"
Write-Host "   - Stash settings location url -> '$StashSettingsLocationUrl'"
if($AllowDefaultSettings) {
	Write-Host "   -> Allowing default settings. If no environment settings can be found, 'localhost' settings will be used instead!"
}
Write-Host "`r`n"

if ((Test-Path $PackageLocation) -eq $false) { Write-Error "Unreachable 'package location'" -ErrorAction Stop }


# Get Application deployment parameters location
$settingsMatch = FindSettingsFileOnStash $TargetEnvironment $AppName $StashFilesRestUrl

if($AllowDefaultSettings -and ($settingsMatch.Count -eq 0)) {
	Write-Warning "Couldn't find '$TargetEnvironment'. Trying with 'localhost' settings instead!"

	$settingsMatch = FindSettingsFileOnStash "localhost" $AppName $StashFilesRestUrl
}

if($settingsMatch.Count -eq 0) { Write-Error "Settings file not found. Verify your input parameters." -ErrorAction Stop }
if($settingsMatch.Count -gt 1) { Write-Error "Too many file matches found. Please clean up our 'EnvironmentSettings' location." -ErrorAction Stop }


# delete default SetParameters file
$defaultSettingsFile = (Get-Item $PackageLocation).GetFiles() | where { $_.Name -match "SetParameters.xml" }
Write-Host "Removing default '*SetParameters.xml' file which is '$defaultSettingsFile'`r`n"
Remove-Item $defaultSettingsFile.FullName -ErrorAction Stop


# copy the targetd SetParameters file
Write-Host "Downloading settings file from Stash`r`n"
DownloadSettingsFileFromStash $settingsMatch $StashSettingsLocationUrl $PackageLocation
	

# rename the targetd SetParameters file
$newSettingsFile = (Get-Item $PackageLocation).GetFiles() | where { $settingsMatch.EndsWith($_.Name)  }
Write-Host "Renaming environment specific '*SetParameters.xml' file with '$newSettingsFile' to '$defaultSettingsFile'"
mv $newSettingsFile.FullName $defaultSettingsFile.FullName