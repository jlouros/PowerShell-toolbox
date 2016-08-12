<#
.SYNOPSIS
	Enable require SSL globally on IIS for 'Forms Authentication'
.NOTES
    This setting is applied even if 'Forms Authentication' is disabled. 
    This is a server configuration, keep in mind that, if set, website configurations can override this server settings.
    Recommended for PCI compliance.
#> 

#Requires -RunAsAdministrator 


& "$Env:SystemRoot\system32\inetsrv\appcmd.exe" set config /commit:WEBROOT /section:authentication /forms.requireSSL:true