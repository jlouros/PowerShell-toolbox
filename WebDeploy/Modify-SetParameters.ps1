#Requires -Version 4.0

param([string]$xmlLocation, [System.Collections.Hashtable]$valuesTable)

Function ChangeSetParameterValue
{
    param ([xml]$xmlDoc, [string]$paramName, [string]$newValue)

    # XPath query
    $checkParam = $xmlDoc.SelectSingleNode("/parameters/setParameter[@name='$paramName']")

    if($checkParam -ne $null) 
    {
        Write-Host "Setting '$paramName' with value '$newValue'"
        $checkParam.Value=$newValue
    } 
    else { Write-Host "Parameter '$paramName' not found!" -ForegroundColor Yellow }
}

[xml]$xml = Get-Content $xmlLocation;

if($xml -eq $null) { Write-Error "Unable to get XML document, please check directory path" -ErrorAction Stop }

ChangeSetParameterValue $xml 'IIS Web Application Name' '%DeployIisAppPath%'
ChangeSetParameterValue $xml 'Smtp Configuration' 'smtp.server.dev'
ChangeSetParameterValue $xml 'Environment' 'Debug'

foreach($tblKey in $valuesTable.Keys) 
{
    $tblValue = $valuesTable[$tblKey]
    
    ChangeSetParameterValue $xml $tblKey $tblValue
}

$emptyParams = $xml.SelectNodes("/parameters/setParameter[@value='']")
if($emptyParams.Count -gt 0) 
{
    Write-Host "The following parameters were not modified: "

    foreach($blank in $emptyParams) 
    {
        Write-Host $blank.name
    }

    Write-Error "Deployment won't be successful due to blank values." -ErrorAction Stop
}

$xml.Save($xmlLocation);