#Requires -Version 4.0

param(
    [string]$targetServer, 
    [switch]$interActiveMode
)

Function Get-WebDeployCmdFile {
    # Get Application WebDeploy cmd file
    $webDeployCmdMatch = (Get-Item .).GetFiles() | Where-Object { $_.Name.EndsWith('.cmd') }

    if($webDeployCmdMatch.Count -eq 0) {
        Write-Error 'WebDeploy .cmd file not found. Missing package files.' -ErrorAction Stop
    }
    if($webDeployCmdMatch.Count -gt 1) {
        Write-Error 'Too many .cmd files found. Deployment can not proceed' -ErrorAction Stop
    }
    $currDir = (Get-Item -Path '.\').FullName
    return Join-Path $currDir $webDeployCmdMatch.Name
}

Function Verify-SetParametersFileExist {
    # Check if 'SetParameters file exist'
    $setParamMatch = (Get-Item .).GetFiles() | Where-Object { $_.Name -match 'SetParameters.xml' }

    if($setParamMatch.Count -eq 0) {
        Write-Error 'SetParameters file not found. Missing package files.' -ErrorAction Stop
    }
    if($setParamMatch.Count -gt 1) {
        Write-Error 'Too many SetParameters files found. Deployment can not proceed' -ErrorAction Stop
    }
}

Function Execute-WebDeploy {
    Param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$webDeployCmd,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$targetComputerName,
        [parameter(Mandatory=$true)]
        [Switch]$interActiveMode)

    
    Write-Output "Deploying to '$targetComputerName'"
    if($interActiveMode -eq $true) {
        $userConfirm = Read-Host 'Do want you proceed? [Y/N]'
    } else {
        $userConfirm = 'y'
    }

    if(($userConfirm -match 'y') -eq $false) {
        # Skip
        Write-Output "Skipping deployment on server '$targetComputerName'" -ForegroundColor Gray
    } else {
        # Execute WebDeploy
        Write-Output "Starting WebDeploy execution on '$targetComputerName'"  -ForegroundColor Green
        $cmdOutput = & $webDeployCmd /y /m:$targetComputerName 2>&1 #| Out-Host

        foreach($msg in $cmdOutput) {
            Write-Output $msg
        }

        if(($cmdOutput | Where-Object { $_.GetType() -match 'System.Management.Automation.ErrorRecord' })) {
            Write-Output "WebDeployment unsucessfull, please check logged messages on 'Log.txt' file."
            Throw 'Terminating Script Execution!'
        }   
    }
}

Function Get-Servers
{
    $matches = (Get-Item .).GetFiles() | Where-Object { $_.Name -match 'Servers.txt' }
    
    if($matches.Count -eq 0) {
        Write-Output "Could find any 'Servers.txt' file" -ErrorAction Stop
        return
    }
    if($matches.Count -gt 1) {
        Write-Output "Too many files matching 'Servers.txt' found. Skipping this step"
        return
    }

    Get-Content $matches -ErrorAction Continue
}

Function Get-ScriptDirectory {
   Split-Path $script:MyInvocation.MyCommand.Path
}

#
# main script execution
#

Set-Location (Get-ScriptDirectory)
$logFile = Join-Path (Get-ScriptDirectory) 'log.txt'

Start-Transcript $logFile

Try
{
    Write-Output 'Executing custom WebPackage installer!'

    $webDeployCmd = Get-WebDeployCmdFile

    if((Test-Path $webDeployCmd) -eq $false) {
        Write-Error "WebDeploy cmd file not found. Verify your build output location. Parsed the follwing path: '$webDeployCmd'" -ErrorAction Stop
    }

    Verify-SetParametersFileExist

    if([string]::IsNullOrWhiteSpace($targetServer) -eq $false) {
        Execute-WebDeploy $webDeployCmd $targetServer -interActiveMode:$interActiveMode
    } else {
        Write-Output "No 'targetServer' param specified. Moving on to next operation"
    }

    # parse and use "Servers.txt"
    [System.Object[]]$servers = Get-Servers

    $serverCount = $servers.Count
    [int]$serverIdx = 0;

    while($serverIdx -lt $serverCount)
    {
        $targetServerName = $servers.Get($serverIdx)

        Write-Output $targetServerName
        # move to next server index
        $serverIdx++;

        Execute-WebDeploy $webDeployCmd $targetServerName -interActiveMode:$interActiveMode
        #Write-Output "Starting deployment on server '$currentServer'"
    }

    # If interactive mode is off, don't ask for other servers
    $askForNewDeploy = $interActiveMode;
    while($askForNewDeploy -eq $true) {
        $userWantsToProceed = Read-Host 'Do want you deploy to another machine? [Y/N]'

        if(($userWantsToProceed -match 'y') -eq $false) {   
            $askForNewDeploy = $false
        } else {
            $desiredServer = Read-Host 'Please enter the server name you want to deploy to: '

            Execute-WebDeploy $webDeployCmd $desiredServer
        }
    }

    Write-Output "We are done here! Check the log file at: '$logFile'" -ForegroundColor Gray

}
Finally 
{
    Stop-Transcript
}