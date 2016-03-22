<#
.SYNOPSIS
	Open Windows Explorer in the  'local\administrator' credentials
.NOTES
    Quickly open a new Windows Explorer Windows using 'local\adminstrator' credentials
#> 

param(
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
 
    $vmRootLocation = Join-Path "\\$($testedHostname.Address)" "\C$\"
    
    Write-Host "opening Windows Explorer at '$vmRootLocation' using 'local\administrator' credentials!"
    explorer /root,$vmRootLocation
    
    # handle the security prompt to enter username and password
    if(FindWindow("Windows Security")) {
        Start-Sleep -Milliseconds 250
        [System.Windows.Forms.SendKeys]::SendWait('local\administrator{TAB}')
        [System.Windows.Forms.SendKeys]::SendWait('Password123{ENTER}')
    }
    
    
    Write-Host "done!"
}