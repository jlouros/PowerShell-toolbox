#Requires -Version 4.0

function Get-SQLServerDataTools-Location {
	[CmdletBinding()]
	param()
	<#
	.SYNOPSIS
		Gets path for SQL Server Data tools
	#>

	Write-Verbose 'Locating SQL Data tools!'

	Write-Verbose 'Trying to locate it in Visual Studio 2012 directory'
	$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\120\sqlpackage.exe'

	if((Test-Path $SqlPackageLocation) -eq $false) {
		Write-Verbose 'Trying to locate it in Visual Studio 2013 directory'
		$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\120\sqlpackage.exe'
	}

	if((Test-Path $SqlPackageLocation) -eq $false) {
		Write-Verbose 'Trying to locate it in SQL Server 2014 directory'
		$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\sqlpackage.exe'
	}

	if((Test-Path $SqlPackageLocation) -eq $false) {
		Write-Verbose 'Trying to locate it in SQL Server 2012 directory'
		$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin\sqlpackage.exe'
	}

	if((Test-Path $SqlPackageLocation) -eq $false) {
		Write-Output "'SqlPackage.exe' was not found on this machine."
		Write-Error "Script execution terminated due missing required program 'SQL Server Data Tools'"  -ErrorAction Stop
	}

	return $SqlPackageLocation
}

function Apply-ConnectionString-PublishProfile {
	param(
		[parameter(Mandatory=$true)]
		[System.String] $connectionString)

	$pubFile = $(Get-ChildItem . -Recurse | Where-Object { $_.Name -match '.InvasiveMode.' }).FullName
	[xml]$xml = Get-Content $pubFile

	Write-Output "Setting connection string value '$connectionString' to publish profile '$pubFile'"
	$conn = $xml.GetElementsByTagName('TargetConnectionString').Item(0).InnerText = $connectionString

	$xml.Save($pubFile)
}


function Perform-Dacpac-Publish {
	param(
		[parameter(Mandatory=$true)]
		[System.String] $dacpacPackageName,
		[Switch] $InvasiveMode)


	$SqlPackageLocation = Get-SQLServerDataTools-Location -Verbose

	if($InvasiveMode) {
		Write-Output "Performing DACPAC publish in 'Invasive mode'"
		$publishProfileLocation = $(Get-ChildItem . -Recurse | Where-Object { $_.Name -match '.InvasiveMode.' }).FullName
	}  else  {
		Write-Output "Performing DACPAC publish in 'Strict mode'"
		$publishProfileLocation = $(Get-ChildItem . -Recurse | Where-Object { $_.Name -match '.StrictMode.' }).FullName
	}

	$dacpacLocation = $(Get-ChildItem . | Where-Object { $_.Name -imatch "$dacpacPackageName.dacpac" }).FullName

	if((-not [string]::IsNullOrWhiteSpace($SqlPackageLocation)) -and (-not [string]::IsNullOrWhiteSpace($publishProfileLocation)) -and (-not [string]::IsNullOrWhiteSpace($dacpacLocation))) 
	{
		Write-Output 'Starting DACPAC publish'
		& $SqlPackageLocation /pr:$publishProfileLocation /sf:$dacpacLocation /a:Publish
	} else {
		Write-Error "Unabled to perform DACPAC publish. Please check the following parameters: >>> SQL Data Tools: '$SqlPackageLocation' | Publish profile: '$publishProfileLocation' | DACPAC: '$dacpacLocation' <<<"
	}
}