<#
.SYNOPSIS
	Encrypts web config connection strings
.NOTES
    Checks each web config and encrypts every found connection string section. 
    Recommended for PCI compliance.
#> 

#Requires -Version 4.0 
#Requires -RunAsAdministrator 


Get-ChildItem -Path "$env:HOMEDRIVE\inetpub\" -Filter 'web.config' -Recurse | ForEach-Object {

    $directory = $_.Directory.FullName
    $filePath = $_.FullName
    $webConfig = [xml](Get-Content -Path $filePath)

    if($webConfig.SelectSingleNode('//connectionStrings').HasChildNodes) {
        Write-Output -InputObject "`r`nencrypting '$filePath' connection strings..."

        & $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -pef 'connectionStrings' $directory -prov 'DataProtectionConfigurationProvider'
    }

    if(-not ([string]::IsNullOrWhiteSpace($webConfig.SelectSingleNode('//system.web/sessionState[@sqlConnectionString]')))) {
        Write-Output -InputObject "`r`nencrypting '$filePath' session state..."

        & $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -pef 'system.web/sessionState' $directory -prov 'DataProtectionConfigurationProvider'
    }
}