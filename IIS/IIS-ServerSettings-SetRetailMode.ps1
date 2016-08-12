<#
.SYNOPSIS
	Sets IIS to run in retail mode
.NOTES
    Retail mode disables development settings. 
    Recommended for PCI compliance.
#> 

#Requires -RunAsAdministrator 


& "$Env:SystemRoot\system32\inetsrv\appcmd.exe" set config /section:deployment /retail:true /commit:MACHINE