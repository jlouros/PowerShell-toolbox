#use http://msdn.microsoft.com/en-us/library/windows/desktop/bb736357(v=vs.85).aspx for API reference

Function Create-ScheduledTask{
     param (
         [string]
         $TaskName,
         [string]
         $RunAsUser,
         [string]
         $RunAsUserPassword,
         [string]
         $TaskRun,
         [string]
         $Schedule,
         [string]
         $StartTime,
         [string]
         $StartDate
     )

	$cmdStartDate = if([string]::IsNullOrWhiteSpace($StartDate)){''}else{"/sd $StartDate"}
	$cmdStartTime = if([string]::IsNullOrWhiteSpace($StartTime)){''}else{"/st $StartTime"}
	$cmdInterval = if([string]::IsNullOrWhiteSpace($Interval)){''}else{"/ri $Interval"}
	$cmdDuration = if([string]::IsNullOrWhiteSpace($Duration)){''}else{"/du $Duration"}
	$cmdRunAsUser = if((-not [string]::IsNullOrWhiteSpace($RunAsUser)) -and (-not [string]::IsNullOrWhiteSpace($RunAsUserPassword))){"/ru '$RunAsUser' /rp '$RunAsUserPassword'"} else {''}

    if($RunAsUser -match 'System') {
        $cmdRunAsUser = "/ru $RunAsUser"
    }

    if($Schedule -match 'MINUTE' -or $Schedule -match 'HOURLY' -or $Schedule -match 'ONSTART' -or $Schedule -match 'ONLOGON' -or $Schedule -match 'ONIDLE' -or $Schedule -match 'ONEVENT') {
        $cmdInterval = if([string]::IsNullOrWhiteSpace($Interval)){''}else{"/mo $Interval"}
    }

	$Command = "schtasks.exe /create $cmdRunAsUser /tn `"$TaskName`" /tr `"'$($TaskRun)'`" /sc $Schedule $cmdStartDate $cmdStartTime /F $cmdInterval $cmdDuration"

	Write-Output $Command          
	Invoke-Expression $Command            
 }

Function Delete-ScheduledTask {
     param (
         [string]
         $TaskName
     )
   
	$Command = "schtasks.exe /delete /s localhost /tn `"$TaskName`" /F"            
	Invoke-Expression $Command 
}

Function Stop-ScheduledTask {
     param (
         [string]
         $TaskName
     )
  
	$Command = "schtasks.exe /end /s localhost /tn `"$TaskName`""            
	Invoke-Expression $Command 
}

Function Start-ScheduledTask {
     param (
         [string]
         $TaskName
     )
   
	$Command = "schtasks.exe /run /s localhost /tn `"$TaskName`""            
	Invoke-Expression $Command 
}

Function Enable-ScheduledTask {
     param (
         [string]
         $TaskName
     )
  
	$Command = "schtasks.exe /change /s localhost /tn `"$TaskName`" /ENABLE"            
	Invoke-Expression $Command 
}

Function Check-IfScheduledTaskExists {
     param (
         [string]
         $taskName
     )

   $schedule = new-object -com Schedule.Service 
   $schedule.connect() 
   $tasks = $schedule.getfolder('\').gettasks(0)

   foreach ($task in ($tasks | Select-Object Name)) {
	  #echo "TASK: $($task.name)"
	  if($task.Name -eq $taskName) {
		 #write-output "$task already exists"
		 return $true
	  }
   }

   return $false
} 


$taskName = $OctopusParameters['TaskName']
$runAsUser = $OctopusParameters['RunAsUser']
$runAsUserPassword = $OctopusParameters['RunAsUserPassword']
$command = $OctopusParameters['Command']
$schedule = $OctopusParameters['Schedule']
$startTime = $OctopusParameters['StartTime']
$startDate = $OctopusParameters['StartDate']
$interval = $OctopusParameters['Interval']
$duration = $OctopusParameters['Duration']

if((Check-IfScheduledTaskExists($taskName))){
	Write-Output "$taskName already exists, Tearing down..."
	Write-Output "Stopping $taskName..."
	Stop-ScheduledTask($taskName)
	Write-Output "Successfully Stopped $taskName"
	Write-Output "Deleting $taskName..."
	Delete-ScheduledTask($taskName)
	Write-Output "Successfully Deleted $taskName"
}

Write-Output "Creating Scheduled Task - $taskName"
Create-ScheduledTask $taskName $runAsUser $runAsUserPassword $command $schedule $startTime $startDate
Write-Output "Successfully Created $taskName"
Enable-ScheduledTask($taskName)
Write-Output "$taskName enabled"