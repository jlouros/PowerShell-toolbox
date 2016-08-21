#Requires -Version 4.0
#Requires -RunAsAdministrator
#Requires -Modules WebAdministration

# this script creates IIS WebSite and Virtual Applications in batch
# just change the '$settings' variable with the desired configurations


# WARNING: current setting does not accept null values
$settings = @{
    'WebSite1' = @{ 
        'AppPoolName' = 'WebSite1'
        'ManagedRuntimeVersion' = 'v2.0'
        'PipelineMode' = 'Classic'
        'IdentityType' = 'LocalSystem'
        'CpuMode' = 'x86'
        'WebSiteName' = 'WebSite1'
        'WebBinding' = 'WebSite1.localhost'
        'PhysicalPath' = "$env:HOMEDRIVE\_CompanyName\Websites\WebSite1"
        'VirtualApplications' = @(
                @{
                'Name' = 'ContainerTagTest'
                'PhysicalPath' = "$env:HOMEDRIVE\_CompanyName\Websites\ContainerTagTest"
                'AppPoolName' = 'WebSite1'
                },
                @{
                'Name' = 'CompanyName'
                'PhysicalPath' = "$env:HOMEDRIVE\_CompanyName\Websites\CompanyName"
                'AppPoolName' = 'WebSite1'
                }
            )
    }
    'WebSite2' = @{ 
        'AppPoolName' = 'WebSite2'
        'ManagedRuntimeVersion' = 'v4.0'
        'PipelineMode' = 'Integrated'
        'IdentityType' = 'LocalSystem'
        'CpuMode' = 'x64'
        'WebSiteName' = 'WebSite2'
        'WebBinding' = 'WebSite2.localhost'
        'PhysicalPath' = "$env:HOMEDRIVE\_CompanyName\Websites\WebSite2-UI"
        'VirtualApplications' = @(
                @{
                'Name' = 'API'
                'PhysicalPath' = "$env:HOMEDRIVE\_CompanyName\Websites\WebSite2-API"
                'AppPoolName' = 'WebSite2'
                }
            )
    }
}



function Check-Windows() {

    $windows = [Environment]::OSVersion.Version -ge (New-Object -TypeName 'Version' -ArgumentList 6,1)

    if($windows -eq $false) {
        Write-Error -Message "'Windows 7' required, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] Windows' -ForegroundColor Green
    }
}

function Check-DotNetFramework() {
    
    $dotNetInstalled = $(Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
        Get-ItemProperty -Name Version -ErrorAction SilentlyContinue |
        Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |
        Select-Object -Property PSChildName, Version |
        Where-Object {$_.PSChildName -eq 'Full' -and $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 4,5)}) -ne
        $null

    if($dotNetInstalled -eq $false) {
        Write-Error -Message "'.Net Framework 4.5' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] .Net Framework' -ForegroundColor Green
    }
}

function Check-IIS() {

    $iisInstalled =  $(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\InetStp\  | 
        Select-Object -Property setupstring, @{N='Version'; E={(New-Object -TypeName 'Version' -ArgumentList $_.MajorVersion,$_.MinorVersion)}} |
        Where-Object { $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 7,5)}) -ne
        $null

    if($iisInstalled -eq $false) {
        Write-Error -Message "'IIS 7.5' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] IIS' -ForegroundColor Green
    }
}

function Check-SqlServer() {

    [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null
    $s = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.Server'

    $sqlServerInstalled = $($s | Select-Object -Property Version, EngineEdition |
        Where-Object { $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 10,50) -and $_.EngineEdition -eq [Microsoft.SqlServer.Management.Smo.Edition]::EnterpriseOrDeveloper }) -ne
        $null

    if($sqlServerInstalled -eq $false) {
        Write-Error -Message "'Sql Sever 2008 R2 (Developer edition)' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] Sql Server' -ForegroundColor Green
    }
}

function Check-WebServicesExtensions() {

    #http://www.microsoft.com/en-us/download/details.aspx?id=23689
    $webServerExt = $(Get-WmiObject -Class win32_product | 
        Where-Object {$_.Vendor -ieq 'Microsoft Corporation'} | 
        Where-Object {$_.Name -match 'Microsoft WSE 2.0 SP3' -and $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 2,0)}) -ne 
        $null

    if($webServerExt -eq $false) {
        Write-Error -Message "'Web Services Extensions 2.0 SP3' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] Web Services Extensions' -ForegroundColor Green
    }
}

function Check-VisualJSharp() {
    #http://www.microsoft.com/en-us/download/details.aspx?id=15468
    $jSharp =  $(Get-WmiObject -Class win32_product | 
        Where-Object {$_.Vendor -ieq 'Microsoft Corporation'} | 
        Where-Object {$_.Name -match 'Microsoft Visual J# 2.0' -and $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 2,0)}) -ne 
        $null

    if($jSharp -eq $false) {
        Write-Error -Message "'Visual J# 2.0' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] Visual J#' -ForegroundColor Green
    }
}

function Check-WebDeploy() {
    #http://www.microsoft.com/web/downloads/platform.aspx
    $webDeploy =  $(Get-WmiObject -Class win32_product | 
        Where-Object {$_.Vendor -ieq 'Microsoft Corporation'} | 
        Where-Object {$_.Name -match 'Microsoft Web Deploy' -and $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 3,1237)}) -ne 
        $null

    if($webDeploy -eq $false) {
        Write-Error -Message "'WebDeploy 3.5' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] WebDeploy' -ForegroundColor Green
    }
}

function Check-ReportViewer() {
    #http://www.microsoft.com/en-us/download/details.aspx?id=35747
    $reportViewer =  $(Get-WmiObject -Class win32_product | 
        Where-Object {$_.Vendor -ieq 'Microsoft Corporation'} | 
        Where-Object {$_.Name -match 'Microsoft Report Viewer 2012 Runtime' -and $_.Version -ge (New-Object -TypeName 'Version' -ArgumentList 11,1)}) -ne 
        $null

    if($reportViewer -eq $false) {
        Write-Error -Message "'Report Viewer 2012 Runtime' is not installed on your machine, unable to continue!" -ErrorAction Stop
    } else {
        Write-Host '[Pass] Report Viewer 2012' -ForegroundColor Green
    }
}

function New-IISAppPool() {
    [CmdletBinding(DefaultParameterSetName='Username')]
    Param
    (
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline=$true)]
        [ValidateScript({
            if (Test-Path -Path "IIS:\AppPools\$_") { Throw New-Object -TypeName System.ArgumentException -ArgumentList "The IIS Application Pool '$_' already exists.", 'Name' }
            else { $true; }
        })]
        [string] $Name,

        [Parameter(Position=1)]
        [Alias('MRV', 'V', 'Runtime')]
        [ValidateSet('v2.0', 'v4.0')]
        [string] $ManagedRuntimeVersion = 'v2.0',

        [Parameter(Position=2)]
        [Alias('Pipeline')]
        [ValidateSet('Integrated', 'Classic')]
        [string] $PipelineMode = 'Integrated',

        [Parameter(Position=3)]
        [Alias('CPU')]
        [ValidateSet('x86', 'x64')]
        [string] $CpuMode = 'x64',

        [Parameter(Position=4, ParameterSetName='Username')]
        [Parameter(Position=4, ParameterSetName='Credential')]
        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService', 'SpecificUser', 'ApplicationPoolIdentity')]
        [string] $IdentityType = 'ApplicationPoolIdentity',

        [Parameter(ParameterSetName='Username')]
        [string] $Username = [string]::Empty,

        [Parameter(ParameterSetName='Credential')]
        [System.Management.Automation.PSCredential]$Credential,

        [switch] $Interactive
    )

    [System.Management.Automation.PSCredential] $AppPoolCredential

    if ($IdentityType.ToLowerInvariant() -eq 'SpecificUser'.ToLowerInvariant())
    {
        if ($PSCmdlet.ParameterSetName -imatch 'Credential')
        {
            $AppPoolCredential = $Credential
        }
        else
        {
            if ([string]::IsNullOrWhiteSpace($Username))
            {
                if ($Interactive)
                {
                    $AppPoolCredential = $Host.UI.PromptForCredential('Application Pool Identity Credentials', 'Please specify the username and password to be used for the Application Pool Identity.', $Username, '', [System.Management.Automation.PSCredentialTypes]::Domain, [System.Management.Automation.PSCredentialUIOptions]::ValidateUserNameSyntax)
                }
                else
                {
                    $AppPoolCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $(Read-Host -Prompt 'Application Pool Identity Username'), $(Read-Host -Prompt 'Application Pool Identity Password' -AsSecureString)   
                }
            }

            if ($Interactive)
            {
                $AppPoolCredential = $Host.UI.PromptForCredential('Application Pool Identity Password', 'Please enter the password for the specified user to be used for the Application Pool Identity.', $Username, '', [System.Management.Automation.PSCredentialTypes]::Domain, [System.Management.Automation.PSCredentialUIOptions]::ValidateUserNameSyntax)
            }
            else
            {
                $AppPoolCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $(Read-Host -Prompt "Application Pool Identity Password for '$Username'" -AsSecureString)
            }
        }
    }

    Write-Verbose -Message 'The following IIS Application Pool will be created:'
    Write-Verbose -Message "    Application Pool Name:                    $Name"
    Write-Verbose -Message "    Application Pool Managed Runtime Version: $ManagedRuntimeVersion"
    Write-Verbose -Message "    Application Pool CPU Mode:                $CpuMode"
    Write-Verbose -Message "    Application Pool Pipeline Mode:           $PipelineMode"
    Write-Verbose -Message "    Application Pool Identity Type:           $IdentityType"
    if ($IdentityType -imatch 'SpecificUser')
    {
        Write-Verbose -Message "    Application Pool Identity Username:       $Username"
    }

    New-WebAppPool -Name $Name

    Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name managedRuntimeVersion -Value $ManagedRuntimeVersion

    if ($PipelineMode -imatch 'Classic')
    {
        Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name managedPipelineMode -Value 1
    }
    
    if ($CpuMode -imatch 'x86')
    {
        Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name enable32BitAppOnWin64 -Value $true
    }

    switch ($IdentityType.ToLowerInvariant())
    {
        'localsystem'    { Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.identityType -Value 0 }
        'localservice'   { Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.identityType -Value 1 }
        'networkservice' { Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.identityType -Value 2 }
        'specificuser'
        {
            Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.identityType -Value 3
            Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.userName -Value $AppPoolCredential.UserName
            Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.password -Value $(Get-Password -Password $AppPoolCredential.Password)
        }
        default          { Set-ItemProperty -Path "IIS:\AppPools\$Name" -Name processModel.identityType -Value 4 }
    }

    Write-Verbose -Message "Application Pool '$Name' was successfully created."
}

function Setup-Websites() {
    
    foreach($key in $settings.Keys) {
        $node = $settings[$key]
    
        Write-Host "running '$key' setup..."

        # check AppPool settings
        $appPool = Get-Item -Path "IIS:\AppPools\$($node.AppPoolName)" -ErrorAction SilentlyContinue
        $createAppPool = $true;

        if($appPool -ne $null) {
            $validAppPoolSettings = ($appPool.managedPipelineMode -match $node.PipelineMode) -and
                                    ($appPool.managedRuntimeVersion -match $node.ManagedRuntimeVersion) -and
                                    ($appPool.enable32BitAppOnWin64 -eq ($node.CpuMode -eq 'x86'))

            if($validAppPoolSettings -eq $false) {
                Remove-WebAppPool -Name $node.AppPoolName
            } else {
                $createAppPool = $false;
            }
        }

        if($createAppPool) {
            New-IISAppPool -Name $node.AppPoolName -PipelineMode $node.PipelineMode -IdentityType $node.IdentityType -CpuMode $node.CpuMode -ManagedRuntimeVersion $node.ManagedRuntimeVersion | Out-Null
        }

        # check website settings
        $website = Get-Website | Where-Object {$_.Name -cmatch $($node.WebSiteName)}

        if($website -ne $null) {
            $correctBinding = Get-WebBinding -Name $node.WebSiteName | Where-Object { $_.protocol -eq 'http' -and $_.bindingInformation -eq "*:80:$($node.WebBinding)"}

            if($correctBinding -eq $null) {
                New-WebBinding -Name $node.WebSiteName -Protocol 'http' -Port 80 -HostHeader $node.WebBinding -IPAddress '*'
            }
        } else {
            if(-not(Test-Path -Path $node.PhysicalPath)) {
                New-Item -ItemType Directory -Path $node.PhysicalPath | Out-Null
            }
            New-Website -Name $node.WebSiteName -ApplicationPool $node.AppPoolName -Port 80 -PhysicalPath $node.PhysicalPath -HostHeader $node.WebBinding -IPAddress '*' | Out-Null
        }

        # check 'Api' settings (virutal application)
        foreach($virtualAppConf in $node.VirtualApplications) {
            Write-Host "    checking '$($virtualAppConf.Name)' virtual application..."
        
            $api = Get-WebApplication -Site $node.WebSiteName -Name $virtualAppConf.Name

            if($api -eq $null) {
                if(-not(Test-Path -Path $virtualAppConf.PhysicalPath)) {
                    New-Item -ItemType Directory -Path $virtualAppConf.PhysicalPath | Out-Null
                }
                New-WebApplication -Site $node.WebSiteName -Name $virtualAppConf.Name -PhysicalPath $virtualAppConf.PhysicalPath -ApplicationPool $virtualAppConf.Name | Out-Null
            }
        }
    }
}


#-------------------------------------
#      Script begins here
#-------------------------------------


Write-Host 'About to check required software for CompanyName main applications!'
$userAggrement = Read-Host -Prompt 'Operation may change your current settings, do you want to proceed [Y]es/[N]o?'
Write-Host "`r`n"

if(-not($userAggrement -match 'y')) {
    return;
}


# Check Windows version (7/2008 or above) 
Check-Windows

# Check SQL Server version (2008 R2 or above) (Developer or Enterprise edition)
Check-SqlServer

# Check IIS version installed (7.5 or above)
Check-IIS

# Check .Net Framework version (4.5 or above)
Check-DotNetFramework

# Check Microsoft Web Services Extensions (2.0 SP3)
Check-WebServicesExtensions

# Check Visual J# 2.0 is installed
Check-VisualJSharp

# Check if WebDeploy 3.5 is installed
Check-WebDeploy

# Check if Report Viewer 2012 is installed 
Check-ReportViewer


# Setup all the websites defined in the settings variable
Setup-Websites


Write-Host "WARNING: Please check your IIS for inconsistencies!`r`n" -ForegroundColor Yellow