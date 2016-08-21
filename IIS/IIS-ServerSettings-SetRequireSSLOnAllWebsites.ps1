<#
.SYNOPSIS
	Enables 'Require SSL' (SSL Settings) on all websites
.NOTES
    Use this script mainly for verification.
    This script does NOT take care of 'Site Bindings". 
    Recommended for PCI compliance.
#> 

#Requires -Version 4.0 
#Requires -RunAsAdministrator 
#Requires -Modules WebAdministration 


Import-Module -Name WebAdministration -ErrorAction Stop
    
    
# get a list of all websites and web applications
$listWebsite = @()
$siteApp = & "$Env:SystemRoot\system32\inetsrv\appcmd.exe" list app
$siteApp | ForEach-Object {
    $webApp = [regex]::Match($_, 'APP\s\"([\w\.\/]+)\"').Groups[1].Value
    
    $listWebsite += ,@($webApp)
}
    
    
# apply necessary changes
$securityAccessPath = 'system.webserver/security/access'
$sslSetting = 'Ssl'
    
$listWebsite | ForEach-Object { 

    $accessSettings = Get-WebConfiguration -Filter $securityAccessPath -PSPath "IIS:\Sites\$_"

    if($accessSettings.sslFlags -ne $sslSetting) 
    {
        Write-Output -InputObject "Setting to require SSL on website '$_'"

        $accessSettings.sslFlags = $sslSetting
        $accessSettings | Set-WebConfiguration -Filter $securityAccessPath
    }
}
    
    
# verify all the settings are correct
$errorsFound = 0
$listWebsite | ForEach-Object { 
    
    $accessSettings = Get-WebConfiguration -Filter $securityAccessPath -PSPath "IIS:\Sites\$_"
    
    if($accessSettings.sslFlags -ne $sslSetting)  
    {
        $errorsFound += 1 
        Write-Output -InputObject "Error! Require SSL is not set on website '$_'"
    }
}
    
if($errorsFound -eq 0) 
{
    Write-Output -InputObject 'Success! Require SSL is enable on all websites.'
} 
else 
{
    Write-Error -Message 'Error! Require SSL is not properly set on all websites' -ErrorAction Stop
}