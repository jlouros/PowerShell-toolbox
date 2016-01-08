<#
.SYNOPSIS
	Runs Performance Monitor (perfmon.msc) on the specified server
.NOTES    
	Performance counters based of information gathered from:
		'Measuring .NET Application Performance' https://msdn.microsoft.com/en-us/library/ff647791.aspx
		'Tuning .NET Application Performance' https://msdn.microsoft.com/en-us/library/ff647813.aspx
#>  

param (
	[Parameter(Mandatory=$True)]
    [string]$FileName,

	[ValidateRange(1,30)] 
    [int]$SampleRate = 15,

	[ValidateSet('Full', 'Basic', 'SqlClient')]
	[string]$ReportType = 'Basic',

	[ValidateNotNullOrEmpty()]
	[string[]]$AppServers = @(
				'44020-D1PRFAPP.MWE.LOCAL',
				'44021-D1PRFAPP.MWE.LOCAL',
				'44022-D1PRFAPP.MWE.LOCAL',
				'44023-D1PRFAPP.MWE.LOCAL',
				'44024-D1PRFAPP.MWE.LOCAL',
				'44025-D1PRFAPP.MWE.LOCAL',
				'44026-D1PRFAPP.MWE.LOCAL',
				'44027-D1PRFAPP.MWE.LOCAL',
				'44028-D1PRFAPP.MWE.LOCAL')
)

Process {

	$counters = @(
		# CPU
		'\Processor(*)\% Processor Time',
		'\Processor(*)\% Privileged Time',
		'\System\Processor Queue Length',
		'\System\Context Switches/sec',
	

		# Memory
		'\Memory\Available MBytes',
		'\Memory\Page Reads/sec',
		'\Memory\Pages/sec',
		'\Memory\Cache Bytes',
		'\Memory\Cache Faults/sec',
		'\Cache\MDL Read Hits %',


		# Disk I/O
		'\PhysicalDisk(*)\Avg. Disk Queue Length',
		'\PhysicalDisk(*)\Avg. Disk Read Queue Length',
		'\PhysicalDisk(*)\Avg. Disk Write Queue Length',
		'\PhysicalDisk(*)\Avg. Disk sec/Read',
		'\PhysicalDisk(*)\Avg. Disk sec/Transfer',
		'\PhysicalDisk(*)\Avg. Disk sec/Write',


		# Network I/O
		'\Network Interface(*)\Bytes Total/sec',
		'\Network Interface(*)\Bytes Received/sec',
		'\Network Interface(*)\Bytes Sent/sec',
		'\Processor(*)\% Interrupt Time',


		# CLR
			# Memory
		'\Process(*)\Private Bytes',
		'\.NET CLR Memory(_GLOBAL_)\# Bytes in all Heaps',
		'\.NET CLR Memory(_GLOBAL_)\# Gen 0 Collections',
		'\.NET CLR Memory(_GLOBAL_)\# Gen 1 Collections',
		'\.NET CLR Memory(_GLOBAL_)\# Gen 2 Collections',
		'\.NET CLR Memory(_GLOBAL_)\# of Pinned Objects',
		'\.NET CLR Memory(_GLOBAL_)\% Time in GC',
		'\.NET CLR Memory(_GLOBAL_)\Large Object Heap size',
			# Working Set
		'\Process(*)\Working Set',
			# Exceptions
		'\.NET CLR Exceptions(_GLOBAL_)\# of Exceps Thrown / sec',
			# Contention
		'\.NET CLR LocksAndThreads(_GLOBAL_)\Contention Rate / sec',
		'\.NET CLR LocksAndThreads(_GLOBAL_)\Current Queue Length',
			# Threading
		'\.NET CLR LocksAndThreads(_GLOBAL_)\# of current physical Threads',
			# Threading (very verbose)
		#'\Thread(*)\% Processor Time',
		#'\Thread(*)\Context Switches/sec',
		#'\Thread(*)\Thread State',
			# Code Access Security
		'\.NET CLR Security(_GLOBAL_)\Stack Walk Depth',
		'\.NET CLR Security(_GLOBAL_)\Total Runtime Checks',


		# ASP.Net
			# Worker Process
		'\ASP.NET\Worker Process Restarts',
			# Throughput
		'\ASP.NET Applications(__TOTAL__)\Requests/Sec',
		'\Web Service(*)\ISAPI Extension Requests/sec',
		'\ASP.NET\Requests Current',
		'\ASP.NET\Requests Queued',
		'\ASP.NET Applications(__TOTAL__)\Requests Executing',
		'\ASP.NET Applications(__TOTAL__)\Requests Timed Out',
		'\ASP.NET Applications(__TOTAL__)\Requests In Application Queue',
			# Response time / latency
		'\ASP.NET\Request Execution Time',
			# Cache
		'\ASP.NET Applications(__TOTAL__)\Cache API Hit Ratio',
		'\ASP.NET Applications(__TOTAL__)\Cache API Turnover Rate',
		'\ASP.NET Applications(__TOTAL__)\Cache Total Entries',
		'\ASP.NET Applications(__TOTAL__)\Cache Total Hit Ratio',
		'\ASP.NET Applications(__TOTAL__)\Cache Total Turnover Rate',
		'\ASP.NET Applications(__TOTAL__)\Output Cache Entries',
		'\ASP.NET Applications(__TOTAL__)\Output Cache Hit Ratio',
		'\ASP.NET Applications(__TOTAL__)\Output Cache Turnover Rate'


		# (optional) CPU
		#'\System\Threads',

		# (optional) ASP.Net Errors
		#'\ASP.NET Applications(__TOTAL__)\Errors Total/Sec',
		#'\ASP.NET Applications(__TOTAL__)\Errors During Execution',
		#'\ASP.NET Applications(__TOTAL__)\Errors Unhandled During Execution/Sec',
	)

	if($ReportType -eq 'Basic') {
		$counters = @(
			'\Processor(*)\% Processor Time',
			'\.NET CLR Memory(_GLOBAL_)\% Time in GC',
			'\.NET CLR Exceptions(_GLOBAL_)\# of Exceps Thrown / sec',
			'\.NET CLR LocksAndThreads(_GLOBAL_)\Contention Rate / sec',
			'\ASP.NET Applications(__TOTAL__)\Requests/Sec',
			'\ASP.NET\Requests Queued',
			'\ASP.NET\Request Execution Time')
	}

	if($ReportType -eq 'SqlClient') {
		$counters = @(
			'\Processor(*)\% Processor Time',
			'\.NET Data Provider for SqlServer(*)\NumberOfStasisConnections',
			'\.NET Data Provider for SqlServer(*)\NumberOfReclaimedConnections',
			'\.NET Data Provider for SqlServer(*)\NumberOfPooledConnections',
			'\.NET Data Provider for SqlServer(*)\NumberOfNonPooledConnections',
			'\.NET Data Provider for SqlServer(*)\NumberOfInactiveConnectionPools',
			'\.NET Data Provider for SqlServer(*)\NumberOfInactiveConnectionPoolGroups',
			'\.NET Data Provider for SqlServer(*)\NumberOfFreeConnections',
			'\.NET Data Provider for SqlServer(*)\NumberOfActiveConnections',
			'\.NET Data Provider for SqlServer(*)\NumberOfActiveConnectionPools',
			'\.NET Data Provider for SqlServer(*)\NumberOfActiveConnectionPoolGroups',
			'\.NET Data Provider for SqlServer(*)\HardConnectsPerSecond',
			'\.NET Data Provider for SqlServer(*)\HardDisconnectsPerSecond',
			'\.NET Data Provider for SqlServer(*)\SoftConnectsPerSecond',
			'\.NET Data Provider for SqlServer(*)\SoftDisconnectsPerSecond')
	}



	$outputPath = "C:\PerfLogs\$FileName.blg"

	Write-Output 'running PerfMon in continuous mode, on all specified servers. Output file will be written to '$outputPath' ...'
	Write-Output 'Press [Ctrl] + [C] to stop!'

	Get-Counter -Counter $counters -SampleInterval $SampleRate -ComputerName $AppServers -Continuous | 
		Export-Counter -Path $outputPath -FileFormat 'BLG'


}