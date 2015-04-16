#Requires -Version 4.0
#Requires -RunAsAdministrator
#Requires -Modules WebAdministration

function Get-Password()
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [System.Security.SecureString] $Password
    )

    process
    {
        $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $ptPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($passwordPointer)

        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer);

        $ptPassword
    }
}

filter Invoke-Ternary 
{
    param
    (
        [Parameter(Mandatory=$True, Position=1)]
        [scriptblock]$Predicate,
        [Parameter(Mandatory=$True, Position=2)]
        [scriptblock]$TrueExpr,
        [Parameter(Mandatory=$True, Position=3)]
        [scriptblock]$FalseExpr
    )

    if (&$Predicate)
    {
        &$TrueExpr
    }
    else
    {
        &$FalseExpr
    }
}
Set-Alias ?: Invoke-Ternary

<#
.SYNOPSIS
    Adds a custom HTTP Header to the IIS Server or specified web site on every response.

.DESCRIPTION
    This function adds a custom HTTP response header to each outgoing response for
    the specified website or for any response eminating from the server.

.PARAMETER WebSiteName
    The name of the website that should return the specified HTTP response header.

    If this parameter is not specified, the HTTP response header will be output on each
    outgoing response from the server for all websites.

.PARAMETER HttpHeader
    The HTTP response header to be output with each response; e.g. X-Custom-Http-Header

.PARAMETER HttpHeaderValue
    The optional value to be sent with the HTTP response header.

.EXAMPLE
    PS C:> Add-CustomHttpResponseHeader -WebSiteName "Default Web Site" -HttpHeader "X-Custom-Http-Header" -HttpHeaderValue "The value"

    On each response for the 'Default Web Site' the 'X-Custom-Http-Header' will be output with a value of 'The value'.

.EXAMPLE
    PS C:> Add-CustomHttpResponseHeader -HttpHeader "X-Custom-Server-Header" -HttpHeaderValue "My server header"

    On each response from the web server for all hosted web sites, the 'X-Custom-Server-Header' will be output with the value
    'My server header'.


#>
function Add-CustomHttpResponseHeader()
{
    Param
	(
		[Alias('WEBSITE', 'WEB', 'W')]
		[string] $WebSiteName,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[Alias('HEADER', 'H')]
	    [string] $HttpHeader,

		[Alias('VALUE', 'V')]
		[string] $HttpHeaderValue
	)

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.Web.Administration') | Out-Null
	$serverManager = New-Object Microsoft.Web.Administration.ServerManager

    if ([string]::IsNullOrWhiteSpace($WebSiteName))
	{
		$config = $serverManager.GetApplicationHostConfiguration()
	}
	else
	{
		$config= $serverManager.GetWebConfiguration($WebSiteName)
	}

	$httpProtocolSection = $config.GetSection('system.webServer/httpProtocol')
	$customHeadersCollection = $httpProtocolSection.GetCollection('customHeaders')

	$newHeader = $customHeadersCollection.CreateElement('add')
	$newHeader['name'] = $HttpHeader
	$newHeader['value'] = ?: { [string]::IsNullOrEmpty($HttpHeaderValue) } { [string]::Empty } { $HttpHeaderValue }

    $customHeadersCollection.Add($newHeader)

	$serverManager.CommitChanges()
}

<#
.SYNOPSIS
    Sets up an Internet Information Services (IIS) Application Pool

.DESCRIPTION
    This command allows you to setup an IIS Application Pool using the specified
    parameters.

.PARAMETER Name
    The name of the IIS Application Pool to create.

.PARAMETER PipelineMode
    The ASP.Net pipeline mode for the new IIS Application Pool.
    Valid values are one of Classic and Integrated.

.PARAMETER ManagedRuntimeVersion
    The .Net Framework Runtime version to use for the new IIS Application Pool.
    Valid values are one of v2.0 and v4.0. The default is v2.0.

.PARAMETER CpuMode
    Determines whether or not the IIS Application Pool will allow 32-bit web
    applications to be run under it even on a 64-bit machine.
    Valid values are one of x86 and x64. The default is x64.

.PARAMETER IdentityType
    The type of identity under which the new IIS Application Pool will run.
    Valid values are one of LocalSystem, LocalService, NetworkService,
    SpecificUser, and ApplicationPoolIdentity. The default is ApplicationPoolIdentity.

.PARAMETER Username
    An optional parameter that specifies the username under which to run the new
    IIS Application Pool.

    If the parameter IdentityType is set to SpecificUser, this parameter can be
    used to specify the user account under which the new IIS applaciton pool will
    run.

    If IdentityType is set to SpecificUser and a value for this parameter is not
    specified, you will be prompted for both a username and password. Otherwise,
    you will only be prompted for a password.

.PARAMETER Interactive
    When this parameter is specified, this script will be run interactively. The
    username and password will be prompted for using the standard Windows
    credential dialog.

    Otherwise, you will be prompted for any necessary credentials at the command
    line.

.EXAMPLE
  PS C:\> New-IISAppPool -Name "My Application Pool"

  # This example shows how to create a new IIS Application Pool with the default
  # settings.

.EXAMPLE
  PS C:\> New-IISAppPool -Name "My Application Pool" -ManagedRuntimeVersion v4.0

  # This example shows how to create a new IIS Application Pool using the 
  # .Net Framework 4.0.

.EXAMPLE
  PS C:\> New-IISAppPool -Name "My Application Pool" -PipelineMode Classic

  # This example shows how to create a new IIS Application Pool using the 
  # Classic Managed Pipeline Mode

.EXAMPLE
  PS C:\> New-IISAppPool -Name "My Application Pool" -IdentityType SpecificUser

  # This example shows how to create a new IIS Application Pool running under a
  # specific user account. Using this version of the command, you will be
  # prompted for both a username and password.

.EXAMPLE
  PS C:\> New-IISAppPool -Name "My Application Pool" -IdentityType SpecificUser -Username "MyDomain\MyUser"

  # This example shows how to create a new IIS Application Pool running under a
  # specific user account. Using this version of the command, you will be 
  # prompted for only a password.

.EXAMPLE
  PS C:\> New-IISAppPool -Name "My Application Pool" -IdentityType SpecificUser -Interactive

  # This example shows how to create a new IIS Application Pool using the 
  # Windows Credential dialog to prompt for user credentials.


#>
function New-IISAppPool()
{
    [CmdletBinding(DefaultParameterSetName='Username')]
    Param
    (
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline=$true)]
        [ValidateScript({
            if (Test-Path "IIS:\AppPools\$_")
            {
                Throw New-Object -TypeName System.ArgumentException -ArgumentList "The IIS Application Pool '$_' already exists.", 'Name'
            }
            else
            {
                $true
            }
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
                    $AppPoolCredential = New-Object System.Management.Automation.PSCredential $(Read-Host -Prompt 'Application Pool Identity Username'), $(Read-Host -Prompt 'Application Pool Identity Password' -AsSecureString)   
                }
            }

            if ($Interactive)
            {
                $AppPoolCredential = $Host.UI.PromptForCredential('Application Pool Identity Password', 'Please enter the password for the specified user to be used for the Application Pool Identity.', $Username, '', [System.Management.Automation.PSCredentialTypes]::Domain, [System.Management.Automation.PSCredentialUIOptions]::ValidateUserNameSyntax)
            }
            else
            {
                $AppPoolCredential = New-Object System.Management.Automation.PSCredential $Username, $(Read-Host -Prompt "Application Pool Identity Password for '$Username'" -AsSecureString)
            }
        }
    }

    Write-Verbose 'The following IIS Application Pool will be created:'
    Write-Verbose "    Application Pool Name:                    $Name"
    Write-Verbose "    Application Pool Managed Runtime Version: $ManagedRuntimeVersion"
    Write-Verbose "    Application Pool CPU Mode:                $CpuMode"
    Write-Verbose "    Application Pool Pipeline Mode:           $PipelineMode"
    Write-Verbose "    Application Pool Identity Type:           $IdentityType"
    if ($IdentityType -imatch 'SpecificUser')
    {
        Write-Verbose "    Application Pool Identity Username:       $Username"
    }

    New-WebAppPool $Name

    if ($ManagedRuntimeVersion -eq 'v4.0')
    {
        Set-ItemProperty "IIS:\AppPools\$Name" managedRuntimeVersion $ManagedRuntimeVersion
    }

    if ($PipelineMode -imatch 'Classic')
    {
        Set-ItemProperty "IIS:\AppPools\$Name" managedPipelineMode 1
    }

    if ($CpuMode -imatch 'x86')
    {
        Set-ItemProperty "IIS:\AppPools\$Name" enable32BitAppOnWin64 $true
    }

    switch ($IdentityType.ToLowerInvariant())
    {
        'localsystem'    { Set-ItemProperty "IIS:\AppPools\$Name" processModel.identityType 0 }
        'localservice'   { Set-ItemProperty "IIS:\AppPools\$Name" processModel.identityType 1 }
        'networkservice' { Set-ItemProperty "IIS:\AppPools\$Name" processModel.identityType 2 }
        'specificuser'
        {
            Set-ItemProperty "IIS:\AppPools\$Name" processModel.identityType 3
            Set-ItemProperty "IIS:\AppPools\$Name" processModel.userName $AppPoolCredential.UserName
            Set-ItemProperty "IIS:\AppPools\$Name" processModel.password $(Get-Password -Password $AppPoolCredential.Password)
        }
        default          { Set-ItemProperty "IIS:\AppPools\$Name" processModel.identityType 4 }
    }

    Write-Verbose "Application Pool '$Name' was successfully created."
}

<#
.SYNOPSIS
    Creates a new IIS Virtual Directory with the specified name, physical path, and
    IIS site and application location using any supplied credentials.

.DESCRIPTION
    This function enhances the standand WebAdministration module's New-WebVirtualDirectory
    function by allowing you to specify the credentials that should be used by IIS when
    accessing the Virtual Directory. If no credentials are supplied, the standard
    New-WebVirtualDirectory method is used to simply create the requested virtual
    directory.

.PARAMETER Name
    The name of the virtual directory to create.

.PARAMETER PhysicalPath
    The physical path on the file system for the new virtual directory. The folder specified must already exist.

.PARAMETER Site
    The site name under which the virtual directory should be created.

.PARAMETER Application
    The application under which the virtual directory should be created.

.PARAMETER Username
    The username to impersonate when accessing the virtual directory. If you use this parameter,
    the script will prompt you to enter a password.

.PARAMETER Credential
    This parameter allows you to specify credentials that should be impersonated when
    accessing the virtual directory.

.PARAMETER Force
    Forces the virtual directory to be created. If the virtual directory already exists,
    it will be replaced with the configuration specified to this function.

.EXAMPLE
    C:\PS> New-IISVirtualDirectory -Site "Default Web Site" -Name ContosoVDir -PhysicalPath c:\inetpub\contoso

    This is the same example as shown in the New-WebVirtualDirectory cmdlet help. Using
    this syntax with this function results in identical behavior as New-WebVirtualDirectory.

.EXAMPLE
    C:\PS> New-IISVirtualDirecotry -Site "Default Web Site" -Name ContosoVDir -PhysicalPath c:\inetpub\contoso -Username myDomain\MyUsername

    This example will create the same virtual directory as above. Additionally, you 
    will be prompted for the password for the specified user and those credentials
    will be attached to the created virtual directory in order to impersonate the
    user when accessing the virtual directory.

#>
function New-IISVirtualDirectory()
{
    [CmdletBinding(DefaultParameterSetName='Username')]
    Param
    (
        [Parameter(Mandatory=$True, Position = 0, ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [Alias('Path', 'P')]
        [string] $PhysicalPath,

        [Parameter(Mandatory=$True, Position = 1, ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullOrEmpty()]
        [Alias('S')]
        [string] $Site,

        [Parameter(ParameterSetName='Username')]
        [Alias('User', 'U')]
        [string] $Username = [string]::Empty,

        [Parameter(ParameterSetName='Credential')]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(ValueFromPipelineByPropertyName=$TRue)]
        [Alias('App', 'A')]
        [string] $Application = [string]::Empty,

        [switch] $Force
    )

    Process
    {
        $local:VDirCred = $Credential

        New-WebVirtualDirectory -Name $Name -PhysicalPath $PhysicalPath -Site $Site -Application $Application -Force:$Force -ErrorAction Stop

        if (-not [string]::IsNullOrWhiteSpace($Username) -or $local:VDirCred)
        {
            $local:pathToVDir = "IIS:\Sites\$Site"
            if (-not [string]::IsNullOrWhiteSpace($Application))
            {
                $local:pathToVDir = Join-Path $local:pathToVDir $Application
            }

            $local:pathToVDir = Join-Path $local:pathToVDir $Name

            if (-not $local:VDirCred)
            {
                $local:VDirCred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $(Read-Host -Prompt "`r`nPassword for '$Username'" -AsSecureString)
            }

            Set-ItemProperty $local:pathToVDir username $local:VDirCred.UserName
            Set-ItemProperty $local:pathToVDir password $(Get-Password $local:VDirCred.Password)
        }
    }
}

<#
.SYNOPSIS
    This function will create a new IIS Application Pool and Website with the 
    specified settings.

.DESCRIPTION
    This function allows you to specify most of the common settings required for
    creating a new IIS Application Pool and Website.

    This function assumes that the website will use Pass-Through Authentication.

.PARAMETER PhysicalPath
    The path, on disk, where the website should be located. If a relative path is
    given, this function will assume it should be located on the root drive of
    %windir% in the inetpub\wwwroot folder. On most installations of Windows, this
    translates to a location under 'C:\inetpub\wwwroot'.

    If you want the site to be located elsewhere, specify an absolute path for
    this parameter value.

    If the path specified does not exist, it will be created for you.

.PARAMETER WebSiteName
    This parameter represents the name of the Website, as it will be known in the
    IIS Manager Console.

.PARAMETER AppPoolname
    This parameter represents the name of the IIS Application Pool as it will be
    known in the IIS Manager Console.

.PARAMETER AppPoolUser
    This parameter allows you to specify the username of the user under which the
    IIS Application Pool should run.

    If you don't select an IdentityType and you don't specify this parameter,
    you will be prompted for a username and password.

    If you do specify this parameter, you will still be prompted for a password.

.PARAMETER HostHeader
    This parameter allows you to specify the Host Header to be used for the
    website binding. The website will only respond to requests that are
    directed to the hostname matching the value of this parameter, addressed
    to the IP Address specified by IPAddress (if any) and arriving over the
    TCP port specified by the Port parameter.

.PARAMETER IPAddress
    This parameter allows you to specify the IP Address for the website binding.
    The website will only respond to requests directed to the host specified by
    HostHeader, addressed to the value of this parameter, and arriving on the 
    port speciied by the value of the Port parameter.

.PARAMETER UseCustomPort
    If this parameter is specified, the port specified by the Port parameter
    will be used. If the Port parameter is not specified, the default port for
    the protocol (HTTP vs. HTTPS) will be used.

.PARAMETER Port
    This parameter allows you to specify a number between 0 and 65535, inclusive.
    The website will only respond to requests directed to the host specified by
    HostHeader, addressed to IPAddress, and arriving on the port speciied by the
    value of this parameter.

.PARAMETER Ssl
    Specifying this parameter enables SSL binding for the site.

.PARAMETER PipelineMode
    The ASP.Net pipeline mode for the new IIS Application Pool.
    Valid values are one of Classic and Integrated.

.PARAMETER ManagedRuntimeVersion
    The .Net Framework Runtime version to use for the new IIS Application Pool.
    Valid values are one of v2.0 and v4.0. The default is v2.0.

.PARAMETER CpuMode
    Determines whether or not the IIS Application Pool will allow 32-bit web
    applications to be run under it even on a 64-bit machine.
    Valid values are one of x86 and x64. The default is x64.

.PARAMETER IdentityType
    The type of identity under which the new IIS Application Pool will run.
    Valid values are one of LocalSystem, LocalService, NetworkService,
    and ApplicationPoolIdentity. The default is ApplicationPoolIdentity.

    This parameter is only applicable when not explicity setting a value
    for the AppPoolUser parameter.

.PARAMETER Interactive
    Specifying this parameter indicates that you wish to run this script
    interactively. Instead of being prompted for credentials at the command line,
    you will instead be prompted using the standard Windows Credentials dialog.

.EXAMPLE
    PS C:\> New-IISWebsiteAndAppPool "WebSite" "WebSite.AppPool" -H "www.mywebsite.com"

    This example creates a new website called 'WebSite' running under the newly created
    application pool 'WebSite.AppPool' responding to requests to the host
    'www.mywebiste.com' over the default HTTP TCP port 80.

#>
function New-IISWebsiteAndAppPool()
{
    [CmdletBinding(DefaultParameterSetName='SpecialAppPoolIdentity')]
    Param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullOrEmpty()]
        [Alias('Path')]
        [string] $PhysicalPath,

        [Parameter(Mandatory=$True, Position=1, ValueFromPipelineByPropertyName=$True)]
        [Alias('SiteName', 'S', 'Web', 'W')]
        [string] $WebSiteName,

        [Parameter(Position=2, ValueFromPipelineByPropertyName=$True)]
        [Alias('AppPool', 'App', 'A')]
        [string] $AppPoolName,

        [Parameter(ParameterSetName='UserAppPoolIdentity')]
        [Alias('User', 'U')]
        [string] $AppPoolUser,

        [Parameter(ParameterSetName='CredentialAppPoolIdentity')]
        [Alias('Cred')]
        [System.Management.Automation.PSCredential]$Credential,

        [Alias('H')]
        [string] $HostHeader,

        [Alias('IP')]
        [string] $IPAddress,

        [switch] $UseCustomPort,

        [Alias('P')]
        [ValidateScript({ 
            if ($_ -and $_ -gt 65535)
            {
                $False
            }
            else
            {
                $True
            }
        })]
        [Nullable[uint32]] $Port,

        [Switch] $Ssl,

        [Alias('Pipeline')]
        [ValidateSet('Classic', 'Integrated')]
        [string] $PipelineMode = 'Classic',

        [Alias('V', 'MRV', 'Runtime')]
        [ValidateSet('v2.0', 'v4.0')]
        [string] $ManagedRuntimeVersion = 'v2.0',

        [Alias('CPU')]
        [ValidateSet('x86', 'x64')]
        [string] $CpuMode = 'x64',

        [Parameter(ParameterSetName='SpecialAppPoolIdentity')]
        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService', 'ApplicationPoolIdentity')]
        [string] $IdentityType = 'ApplicationPoolIdentity',

        [switch] $Interactive
    )

    Process
    {
        if (-not [System.IO.Path]::IsPathRooted($PhysicalPath))
        {
            $wwwroot = [System.IO.Path]::Combine([System.IO.Path]::GetPathRoot($env:SystemRoot), 'inetpub', 'wwwroot')
            Write-Verbose "The path '$PhysicalPath' is a relative path. Assuming it should be located relative to '$wwwroot'."
            $PhysicalPath = [System.IO.Path]::Combine($wwwroot, $PhysicalPath)
        }

        if (-not (Test-Path $PhysicalPath))
        {
            Write-Verbose "The location '$PhysicalPath' could not be found."
            Write-Verbose "Creating the location '$PhysicalPath'."
            New-Item $PhysicalPath -ItemType Directory | Out-Null
            Write-Verbose "Created '$PhysicalPath'."
        }

        $newAppPoolParams = @{
            'Name' = $AppPoolName;
            'PipelineMode' = $PipelineMode;
            'ManagedRuntimeVersion' = $ManagedRuntimeVersion;
            'CpuMode' = $CpuMode;
            'Interactive' = $Interactive;
        }
         
        if ($PSCmdlet.ParameterSetName -imatch 'CredentialAppPoolIdentity')
        {
            $newAppPoolParams.Add('IdentityType', 'SpecificUser')
            $newAppPoolParams.Add('Credential', $Credential)
        }
        elseif ($PSCmdlet.ParameterSetName -imatch 'UserAppPoolIdentity')
        {
            $newAppPoolParams.Add('IdentityType', 'SpecificUser')

            if (-not [string]::IsNullOrWhiteSpace($AppPoolUser))
            {
                
                $newAppPoolParams.Add('Username', $AppPoolUser)
            }
        }
        else
        {
            $newAppPoolParams.Add('IdentityType', $IdentityType)
        }

        New-IISAppPool @newAppPoolParams

        # Create the new website
        $newWebsiteParams = @{
            'Name' = $WebSiteName;
            'ApplicationPool' = $AppPoolName;
            'PhysicalPath' = $PhysicalPath;
            'Ssl' = $Ssl 
        }
        
        if ($UseCustomPort)
        {
            Write-Verbose 'The parameter -UseCustomPort was set.'

            if ($Port)
            {
                Write-Verbose "Using custom port $Port."
                $newWebsiteParams.Add('Port', $Port)
            }
            else
            {
                Write-Verbose 'Even though -UseCustomPort was set, no port was provided.'
                if ($Ssl)
                {
                    Write-Verbose 'SSL was specified, so using port 443.'
                    $newWebsiteParams.Add('Port', 443)
                }
                else
                {
                    Write-Verbose 'Using port 80.'
                    $newWebsiteParams.Add('Port', 80)
                }
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($HostHeader))
        {
            $newWebsiteParams.Add('HostHeader', $HostHeader)
        }

        if (-not [string]::IsNullOrWhiteSpace($IPAddress))
        {
            $newWebsiteParams.Add('IPAddress', $IPAddress)
        }        

        New-Website @newWebSiteParams
    }
}


Export-ModuleMember -Function Add-CustomHttpResponseHeader, Get-Password, New-IISWebsiteAndAppPool, Invoke-Ternary, New-IISAppPool, New-IISVirtualDirectory -Alias ?: