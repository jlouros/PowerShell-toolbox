<#
.SYNOPSIS
	Opens a local instance of the selected SQL tools, using a 'local\administrator' credentials
.NOTES
    Useful for profiling Go Lab environments since 'local\administrator' is the default local administrator of those machines
#> 

Param([Switch] $SqlProfiler)

Process 
{
    # a new Command Prompt Window should be opened with this title
    $newCmdlineWindowTitle = "C:\Windows\System32\cmd.exe"
    
    # import required assemblies
    Add-Type -AssemblyName Microsoft.VisualBasic
    Add-Type -AssemblyName System.Windows.Forms


    Start-Process "cmd.exe"

    Start-Sleep -Milliseconds 1000
    [Microsoft.VisualBasic.Interaction]::AppActivate($newCmdlineWindowTitle)
    
    if($SqlProfiler) {
        # open SQL Server Profiler
        Write-Output "about to open SQL Server Profiler"
        [System.Windows.Forms.SendKeys]::SendWait('runas /netonly /user:local\administrator "C:\Program Files {(}x86{)}\Microsoft SQL Server\110\Tools\Binn\PROFILER.EXE"{ENTER}')
    } 
    else {    
        # open SQL Server Management Studio
        Write-Output "about to open SQL Server Management Studio"
        [System.Windows.Forms.SendKeys]::SendWait('runas /netonly /user:local\administrator "C:\Program Files {(}x86{)}\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe"{ENTER}')
    }

    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait('Password123{ENTER}')

    # close command prompt window
    Start-Sleep -Milliseconds 500
    [Microsoft.VisualBasic.Interaction]::AppActivate($newCmdlineWindowTitle)
    [System.Windows.Forms.SendKeys]::SendWait('exit{ENTER}')
 
    
    Write-Host "done!"   
}