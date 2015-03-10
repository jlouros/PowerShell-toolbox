function Swap-WebDeploy-Vars-With-Octopus-Vars()
{
	[CmdletBinding()]
	param()

	Write-Verbose "Replacing all variables in SetParameters with Octopus variables with the same names."
	
	$xmlFile = $(Get-ChildItem . | ? { $_.Name.EndsWith(".SetParameters.xml") }).FullName

	[xml]$xml = Get-Content $xmlFile;
	
	foreach($node in $xml.SelectNodes("/parameters/setParameter")) 
	{
		$node.value = "#{$($node.name.Replace(' ', '_'))}"
	}
	
	$xml.Save($xmlFile);
}


function Run-WebDeploy() 
{
	[CmdletBinding()]
	param()

	Write-Verbose "Looking for a local '.cmd' to run WebDeploy"

	$webDeployCmd = Get-ChildItem . | ? { $_.Name.EndsWith(".cmd") }
	$webDeployFile = $webDeployCmd.FullName

	& $webDeployFile /y
}