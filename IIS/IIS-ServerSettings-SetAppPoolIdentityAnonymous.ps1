<#
.SYNOPSIS
	Set anonymous authention to 'Application pool identity'
.NOTES
    Ensures that 'Application pool identity' is used for anonymous users. 
    This is a server configuration, keep in mind that, if set, website configurations can override this server settings.
    Recommended for PCI compliance.
#> 

#Requires -RunAsAdministrator 


& "$Env:SystemRoot\system32\inetsrv\appcmd.exe" set config /section:anonymousAuthentication /username:'' --password