<#
.SYNOPSIS
	Filters requests to only allow MIME types defined by us.
.NOTES
    Whitelist only known MIME types. 
    Recommended for PCI compliance.
#> 

#Requires -Version 4.0 
#Requires -RunAsAdministrator 
#Requires -Modules WebAdministration 


Import-Module -Name WebAdministration -ErrorAction Stop
    
    
$requestFilterPath = 'system.webServer/security/requestFiltering/fileExtensions'
    
    
#clear all previously set configurations for file extensions request filtering
Clear-WebConfiguration -Filter $requestFilterPath
    
    
# disallow unknown file extensions
$fileExt = Get-WebConfiguration -Filter $requestFilterPath
    
Write-Output -InputObject 'Setting to disallow unlisted file extensions on IIS'
    
$fileExt.allowUnlisted = $false
$fileExt.applyToWebDAV = $true
$fileExt | Set-WebConfiguration -Filter $requestFilterPath
    
            
        
# allowing known file extensions
Add-WebConfigurationProperty -Filter $requestFilterPath -Name Collection -Value @(
    @{fileExtension='.'; allowed='true'}, 
    @{fileExtension='.aspx'; allowed='true'},
    @{fileExtension='.asmx'; allowed='true'}
    @{fileExtension='.axd'; allowed='true'},
    @{fileExtension='.htm'; allowed='true'},
    @{fileExtension='.html'; allowed='true'},
    @{fileExtension='.js'; allowed='true'},
    @{fileExtension='.json'; allowed='true'},
    @{fileExtension='.css'; allowed='true'},
    @{fileExtension='.png'; allowed='true'},
    @{fileExtension='.gif'; allowed='true'},
    @{fileExtension='.jpg'; allowed='true'},
    @{fileExtension='.jpeg'; allowed='true'},
    @{fileExtension='.txt'; allowed='true'},
    @{fileExtension='.xml'; allowed='true'},
    @{fileExtension='.wsdl'; allowed='true'},
    @{fileExtension='.svc'; allowed='true'},		
    @{fileExtension='.ashx'; allowed='true'},
    @{fileExtension='.asp'; allowed='true'},
    @{fileExtension='.bmp'; allowed='true'},
    @{fileExtension='.ico'; allowed='true'},
    @{fileExtension='.sitemap'; allowed='true'},
    @{fileExtension='.xls'; allowed='true'},
    @{fileExtension='.zip'; allowed='true'},
    @{fileExtension='.xslx'; allowed='true'},
    @{fileExtension='.csv'; allowed='true'},
    @{fileExtension='.pdf'; allowed='true'})