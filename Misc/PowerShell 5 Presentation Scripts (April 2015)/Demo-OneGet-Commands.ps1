#Requires -Version 5.0

#List all commands for 'OneGet' powershell module
Get-Command -Module OneGet

#Get a list of package providers
Get-PackageProvider

#Register Chocolatey as package source
#Or read PackageSource information if already installed
Get-PackageSource -Provider chocolatey

#Discover some packages
Find-Package -Name zoomit -AllVersions

#find package with UI
Find-Package zoomit -AllVersions | Out-Gridview 

#Install a package
Install-Package -Name zoomit -Verbose

#Show what packages are installed
Get-Package

#Filter to Chocolatey only
Get-Package -ProviderName Chocolatey

#find package with UI, pick it and install it
Find-Package zoomit -AllVersions | Out-Gridview -PassThru | Install-Package


#get package and uninstall it
Get-Package -Name zoomit | Uninstall-Package