#Requires -Version 5.0

#register my PowerShellGet Server
$PowerShellGetServerUrl = 'http://john-pc:8001/nuget' #location of your PowerShellGet server
Register-PackageSource -Name myPowerShellGetRepository -Location $PowerShellGetServerUrl -Provider PSModule -Trusted -Verbose

#list all packages from this source
Find-Package -Source myPowerShellGetRepository

#find package with UI and install the selected one
Find-Package -Source myPowerShellGetRepository -AllVersions | Out-Gridview -PassThru | Install-Package

#get package 'PSReadLine' and uninstall it
Get-Package -Name PSReadLine | Uninstall-Package

#unregister previously registered PowerShellGet server
Unregister-PackageSource -Name myPowerShellGetRepository


#other useful commands

#list all locations where PowerShell modules can be installed
[Environment]::GetEnvironmentVariable('PSModulePath')

#lists all commands included in 'PSReadLine' module
Get-Command -Module PSReadLine