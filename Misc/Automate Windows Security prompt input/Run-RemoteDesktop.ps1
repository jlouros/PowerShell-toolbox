<#
.SYNOPSIS
	Start Remote Desktop with 'local\administrator' credentials
.NOTES
    Useful to rapidly connect to a Go Lab VM
#> 

Param(
    [string]$hostname = "dev.vm-001.local"
)

Process 
{
    # helper function to locate a open program using by a given Window name
    Function FindWindow([string]$windowName, [int]$retries = 5, [int]$sleepInterval = 1000) {
        
        [int]$currentTry = 0;
        [bool]$windowFound = $false;
        
        Do {
            $currentTry++;
            
            Start-Sleep -Milliseconds $sleepInterval
            Try {
                [Microsoft.VisualBasic.Interaction]::AppActivate($windowName)
                $windowFound = $true;    
            } Catch {
                Write-Host "   [$currentTry out of $retries] failed to find Window with title '$windowName'" -ForegroundColor Yellow
                $windowFound = $false;
            }
        } While ($currentTry -lt $retries -and $windowFound -eq $false)
        

        return $windowFound;
    }

    # import required assemblies
    Add-Type -AssemblyName Microsoft.VisualBasic
    Add-Type -AssemblyName System.Windows.Forms


    # test if the provided hostname is valid
    $testedHostname = Test-Connection $hostname -Count 1 -ErrorAction SilentlyContinue

    if($testedHostname -eq $null) {
        Write-Error "the provided hostname could not be resolved '$hostname'" -ErrorAction Stop
    }
    
    $vmIp = $testedHostname.IPV4Address.IPAddressToString

    # open Remote Desktop with 'local\administrator'
    Write-Host "starting connection to '$testedHostname' using 'local\administrator' credentials!"
    cmdkey /generic:TERMSRV/$vmIp /user:local\administrator
    mstsc /v:$vmIp
    
    # first prompt to enter the password
    if(FindWindow("Windows Security")) {
        Start-Sleep -Milliseconds 500
        [System.Windows.Forms.SendKeys]::SendWait('Password123{ENTER}')    
    }
    
    # second prompt to accept the certificate
    if(FindWindow("Remote Desktop Connection")) {
        Start-Sleep -Milliseconds 250
        [System.Windows.Forms.SendKeys]::SendWait('Y')
    }


    Write-Host "done!"
}