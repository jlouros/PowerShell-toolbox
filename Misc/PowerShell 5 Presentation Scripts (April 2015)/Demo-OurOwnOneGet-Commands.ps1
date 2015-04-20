#Requires -Version 5.0


#register my OneGet Server
Register-PackageSource -Name myChocolateyRepository -Location 'http://john-pc:8000/nuget' -Provider chocolatey -Trusted -Verbose

#list all packages from this source
Find-Package -Source myChocolateyRepository

#find package with UI and install the selected one
Find-Package -Source myChocolateyRepository -AllVersions | Out-Gridview -PassThru | Install-Package

#unregister 
Unregister-PackageSource -Name myChocolateyRepository
