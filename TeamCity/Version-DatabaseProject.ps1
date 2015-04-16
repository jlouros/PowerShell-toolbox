#Requires -Version 4.0

# used to version SQL Server projects in TeamCity

function Set-DatabaseProjectVersion() {
	[CmdletBinding()]
	param(
	    [parameter(Mandatory=$true)]
	    [ValidateScript({Test-Path $_})]
	    [ValidatePattern("\.sqlproj$")]
	    [string]$sqlProjLocation,
	    [parameter(Mandatory=$true)]
	    [string]$versionNumber
    )


	Write-Verbose "Read content from '$sqlProjLocation'"
	[xml]$xml = Get-Content $sqlProjLocation

	[string]$versionTagName = 'DacVersion'
	$dacVersion = $xml.GetElementsByTagName($versionTagName)

	if($dacVersion.Count -eq 0)
	{
		Write-Verbose "Adding 'DacVersion' property to .sqlproj, since it wasn't found!"

		$ns = $xml.GetElementsByTagName('Project').Item(0).NamespaceURI

		$proj = $xml.GetElementsByTagName('PropertyGroup') | Where-Object { $_.GetElementsByTagName('ProjectGuid').Count -gt 0  } 
	
		$proj.AppendChild($xml.CreateElement($versionTagName, $ns))

		$dacVersion = $proj.GetElementsByTagName($versionTagName)
	}

	Write-Verbose "Setting version to '$versionNumber'"
	$dacVersion.Item(0).InnerText = $versionNumber

	Write-Verbose 'Saving .sqlproj file...'
	$xml.Save($sqlProjLocation)
}

Set-DatabaseProjectVersion