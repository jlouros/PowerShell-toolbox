<#
.SYNOPSIS
	Encrypts web config connection strings
.NOTES
    Checks each web config and encrypts every found connection string section. 
    Recommended for PCI compliance.
#> 

#Requires -Version 4.0 
#Requires -RunAsAdministrator 


Get-ChildItem 'C:\inetpub\' -Filter 'web.config' -Recurse | ForEach-Object {

    $directory = $_.Directory.FullName
    $filePath = $_.FullName
    $webConfig = [xml](Get-Content $filePath)

    if($webConfig.SelectSingleNode('//connectionStrings').HasChildNodes) {
        Write-Output "`r`nencrypting '$filePath' connection strings..."

        & $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -pef 'connectionStrings' $directory -prov 'DataProtectionConfigurationProvider'
    }

    if(-not ([string]::IsNullOrWhiteSpace($webConfig.SelectSingleNode('//system.web/sessionState[@sqlConnectionString]')))) {
        Write-Output "`r`nencrypting '$filePath' session state..."

        & $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -pef 'system.web/sessionState' $directory -prov 'DataProtectionConfigurationProvider'
    }
}