<#
.SYNOPSIS
	Start, stops or gets information from Intellitrace stand-alone collector
.NOTES    
	 Using the IntelliTrace stand-alone collector instructions https://msdn.microsoft.com/en-us/library/vstudio/hh398365(v=vs.140).aspx
	 Warning, Visual Studio Enterprise (or Ultimate) is required to view Intellitrace reports.

	 1) Download IntelliTrace Standalone Collector (IntelliTraceCollector.exe) https://www.microsoft.com/en-us/download/confirmation.aspx?id=44909
	 2) Save IntelliTraceCollector.exe to the collector directory 'C:\IntelliTraceCollector'
	 3) Run IntelliTraceCollector.exe. This extracts the 'IntelliTraceCollection.cab' file.
	 4) Open a command prompt window as an administrator and change directory to 'C:\IntelliTraceCollector'
	 5) Use the expand command, including the period (.) at the end, to expand IntelliTraceCollection.cab
		 expand /f:* IntelliTraceCollection.cab .
	 6) Use the Windows icacls command to give the server administrator full permissions to the collector directory
		 icacls "C:\IntelliTraceCollector" /grant "<Domain\AdministratorID>":F
	 7) Give the application pool for the Web app or SharePoint application read and execute permissions to the collector directory
		 icacls "C:\IntelliTraceCollector" /grant "IIS APPPOOL\MwSmartpaymentsAppPool":RX
	 8) On your app’s server, create the .iTrace file directory, for example: 'C:\IntelliTraceLogFiles'
		 icacls "C:\IntelliTraceLogFiles" /grant "IIS APPPOOL\MwSmartpaymentsAppPool":F
#> 

param(
	[Parameter(Position = 0, ValueFromPipeline=$true)]
	[ValidateSet('Start', 'Stop', 'GetStatus')]
	[string] $Action = 'GetStatus',

	[Parameter(Position = 1)]
	[ValidateNotNullOrEmpty()]
	[string[]] $AppPools = @('DefaultAppPool')
)


Process {

	$intelInstallDir = 'C:\IntelliTraceCollector'
	$intelLogsDir = 'C:\IntelliTraceLogFiles'


	Import-Module "$intelInstallDir\Microsoft.VisualStudio.IntelliTrace.PowerShell.dll"

	if($Action -eq 'Start') {
	
		Write-Output 'Starting Intellitrace'
		$AppPools | ForEach-Object {
			Start-IntelliTraceCollection $_ "$intelInstallDir\collection_plan.ASP.NET.default.xml" $intelLogsDir -Confirm:$false
		}

	} elseif ($Action -eq 'Stop') {

		Write-Output "Stopping Intellitrace. Logs can be found at '$intelLogsDir'"
		$AppPools | ForEach-Object {
			Stop-IntelliTraceCollection $_ -Confirm:$false
		}

	} else {

		Write-Output 'Getting Intellitrace status'
		$AppPools | ForEach-Object {
			Get-IntelliTraceCollectionStatus $_
		}

	}

}