param(
	[parameter(Mandatory=$true)]
	[string]$ApiKey,
    [parameter(Mandatory=$true)]
    [string]$csprojLocation
)

# removes existing '*.nupkg' packages in the current folder
Get-ChildItem . | Where-Object { $_.Name -imatch ".nupkg$" } | ForEach-Object { Remove-Item $_.FullName }

# creates nuget package
..\NuGet.exe pack $csprojLocation -Prop Configuration=Release

# publish package
$packageName = Get-ChildItem . | Where-Object { $_.Name -imatch ".nupkg$" }

Write-Output "`r`nAbout to publish '$packageName'."
$userConfirm = Read-Host 'Do you want to proceed? [Y]es/[N]o'

if($userConfirm -match 'Y') 
{
	Write-Output "`r`nPublishing package..."	
	..\NuGet.exe push $packageName -ApiKey $ApiKey	
} 
else 
{
	Write-Output "`r`nPublish operation skipped by the user."	
}