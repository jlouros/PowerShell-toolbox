[CmdletBinding()]
param(
	[ValidateNotNullOrEmpty()]
	[string]$serverInstance = 'localhost'
)

Function Resolve-InvokeSqlcmd() {
	if (-not (Get-Command 'Invoke-SqlCmd' -ErrorAction SilentlyContinue))
	{
		Write-Verbose 'Invoke-SqlCmd not found as a known command. Adding required PSSnapin'
		Add-PSSnapin SqlServerCmdletSnapin100 
		Add-PSSnapin SqlServerCmdletSnapin100 
	}

	if (-not (Get-Command 'Invoke-SqlCmd' -ErrorAction SilentlyContinue)) {
		Write-Error "Unable to resolve 'Invoke-SqlCmd' PowerShell command. This process can't continue without it!" -ErrorAction Stop
	}
}

Function Get-SQLServerDataToolsLocation {
	<#
	.SYNOPSIS
		Gets path for SQL Server Data tools
	
	.DESCRIPTION
		Gets path for SQL Server Data tools
	#>


	# Visual Studio 2012 SQL Package location
	$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\120\sqlpackage.exe'

	if((Test-Path $SqlPackageLocation) -eq $false) {
		# Visual Studio 2013 SQL Package location
		$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\120\sqlpackage.exe'
	}

	if((Test-Path $SqlPackageLocation) -eq $false) {
		# SQL Server 2014 SQL Package location
		$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\sqlpackage.exe'
	}

	if((Test-Path $SqlPackageLocation) -eq $false) {
		# SQL Server 2012 SQL Package location
		$SqlPackageLocation = 'C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin\sqlpackage.exe'
	}

	# Last verification point
	if((Test-Path $SqlPackageLocation) -eq $false) {
		Write-Host "'SqlPackage.exe' was not found on this machine."
		Write-Error "Script execution terminated due missing required program 'SQL Server Data Tools'"  -ErrorAction Stop
	}

	return $SqlPackageLocation
}

$verbosityFlag = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)

Resolve-InvokeSqlcmd

$SqlPackageLocation = Get-SQLServerDataToolsLocation

$publishProfiles = Get-ChildItem . -Recurse -Include *.publish.xml



Write-Verbose "Running 'DeleteMockedDatabases.sql' on '$serverInstance'..." 
Invoke-Sqlcmd -InputFile $(Join-Path ($(Get-Item .).FullName) 'DeleteMockedDatabases.sql') -ServerInstance $serverInstance -Verbose:$verbosityFlag



Write-Verbose "Running 'CreateDatabases.sql' on '$serverInstance'..." 
Invoke-Sqlcmd -InputFile $(Join-Path ($(Get-Item .).FullName) 'CreateDatabases.sql') -ServerInstance $serverInstance -Verbose:$verbosityFlag

Write-Verbose "Running 'CreateLinkedServers.sql' on '$serverInstance'..."
Invoke-Sqlcmd -InputFile $(Join-Path ($(Get-Item .).FullName) 'CreateLinkedServers.sql') -ServerInstance $serverInstance -Verbose:$verbosityFlag


foreach($publishProf in $publishProfiles) 
{
	$dacpac = Get-ChildItem $publishProf.Directory -Recurse -Include "$($publishProf.Directory.Name).dacpac"

	if($dacpac -eq $null) {
		Write-Error "dacpac for '$($publishProf.Directory.Name)' was not found. Make sure the solution was built!" -ErrorAction Continue
		continue
	}

	& $SqlPackageLocation /pr:"$($publishProf.FullName)" /sf:"$($dacpac.FullName)" /a:Publish 
	Write-Output '-----------------------------------------------------------------------------'
}

Set-Location $PSScriptRoot
