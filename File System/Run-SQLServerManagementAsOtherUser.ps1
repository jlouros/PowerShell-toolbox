<#
.SYNOPSIS
	Opens a local instance of the selected SQL tools, using a 'local\administrator' credentials
.NOTES
    Useful when you need to use 'Windows Authention' to reach out a machine hosted on a different Active Directory
#> 

Param(
    [String] $DomainUser = 'local\administrator',
    [Switch] $SqlProfiler
)

# path to Sql Server 2012 Management Studio
$Ssms2012Path = 'C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe'

# path to Sql Server 2012 Profiler
$SqlProfiler2012Path = 'C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\PROFILER.EXE'


# pick Ssms or Profile depending on what the user picked
$selectedApp = $Ssms2012Path
if($SqlProfiler) {
    $selectedApp = $SqlProfiler2012Path
}


if(-not(Test-Path $selectedApp)) {
    
    Write-Error "Invalid path provided: '$selectedApp'" -ErrorAction Stop
}


runas.exe /netonly /user:$DomainUser $selectedApp 