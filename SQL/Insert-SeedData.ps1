[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    $serverInstance = 'localhost'
)

if (-not (Get-Command 'Invoke-SqlCmd' -ErrorAction SilentlyContinue))
{
	Write-Verbose 'Invoke-SqlCmd not found as a known command. Adding required PSSnapin'
	Add-PSSnapin SqlServerCmdletSnapin100 
	Add-PSSnapin SqlServerCmdletSnapin100 
}

if (-not (Get-Command 'Invoke-SqlCmd' -ErrorAction SilentlyContinue)) {
	Write-Error "Unable to resolve 'Inovke-SqlCmd' powershell command. This process can't contiune without it!" -ErrorAction Stop
}


$verbosityFlag = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)



$setupScriptFiles = Get-ChildItem .\SetupScripts\ -Include '*.sql' -Recurse
$dataScriptFiles = Get-ChildItem .\DataScripts\ -Include '*.sql' -Recurse



Write-Output "Running 'Pre-Deploy' scripts..."
foreach($preDeployFile in $setupScriptFiles | Where-Object { $_.Name -lt '100'}) 
{
	Write-Verbose "<RUN> '$($preDeployFile.Name)'"
	Invoke-Sqlcmd -InputFile $preDeployFile.FullName -ServerInstance $serverInstance -Verbose:$verbosityFlag
}


Write-Output 'Running data scripts...'
foreach($dataFile in $dataScriptFiles) 
{
	Write-Verbose "<RUN> '$($dataFile.Name)'"
	Invoke-Sqlcmd -InputFile $dataFile.FullName -ServerInstance $serverInstance -DisableVariables -Verbose:$verbosityFlag
}


Write-Output 'Running other setup scripts...'
foreach($setupFile in $setupScriptFiles | Where-Object { $_.Name -ge '100' -and $_.Name -le '899'}) 
{
	Write-Verbose "<RUN> '$($setupFile.Name)'"
	Invoke-Sqlcmd -InputFile $setupFile.FullName -ServerInstance $serverInstance -Verbose:$verbosityFlag
}


Write-Output "Running 'Post-Deploy' scripts..."
foreach($postDeployFile in $setupScriptFiles | Where-Object { $_.Name -gt '899'}) 
{
	Write-Verbose "<RUN> '$($postDeployFile.Name)'"
	Invoke-Sqlcmd -InputFile $postDeployFile.FullName -ServerInstance $serverInstance -Verbose:$verbosityFlag
}



Write-Verbose 'Execution complete!'
Set-Location $PSScriptRoot