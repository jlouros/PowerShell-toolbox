#Requires -Version 4.0

function Change-WebConfig-ConnectionStringKeys() {
	[CmdletBinding()]
	param(
	    [parameter(Mandatory=$true)]
	    [ValidateScript({Test-Path $_})]
	    [ValidatePattern("\.config$")]
	    [string]$xmlFileLocation
    )

	Write-Verbose "Read content from '$xmlFileLocation'"
	[xml]$xml = Get-Content $xmlFileLocation

    $connStringsElem = $xml.GetElementsByTagName("connectionStrings");

    foreach($conn in $connStringsElem.Item(0).add) {
        $octoVar =  "#{$($conn.name)}"
        Write-Verbose "changing '$($conn.name)' to '$octoVar'"
        $conn.name = $octoVar
    }

	Write-Verbose "Saving '$xmlFileLocation' file..."
	$xml.Save($xmlFileLocation)
}

Change-WebConfig-ConnectionStringKeys "C:\temp\web.config" -Verbose