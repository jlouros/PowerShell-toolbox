#Requires -RunAsAdministrator


# define the process name here
$target = "PROCESS-NAME-TO-KILL" 


$process = Get-Process $target -ErrorAction SilentlyContinue

if ($process -ne $null)
{
    $process.Kill()
}
