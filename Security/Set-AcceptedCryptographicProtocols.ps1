<#
.SYNOPSIS
	Defines the accepted cryptographic protocols at the OS level (schannel.dll)
.NOTES    
	Changes Windows registry to define the accepted cryptographic protocols.
    Warning, depending on your configuration, some websites might stop working on IE or other applications using 'schannel.dll'
    For more information please check https://support.microsoft.com/en-us/kb/245030
#>  


# set the desired configurations here
$protocols = @{
	'SSL 2.0'= @{
		'Server-Enabled' = $false
		'Client-Enabled' = $false
	}
	'SSL 3.0'= @{
		'Server-Enabled' = $false
		'Client-Enabled' = $false
	}
	'TLS 1.0'= @{
		'Server-Enabled' = $false
		'Client-Enabled' = $true
	}
	'TLS 1.1'= @{
		'Server-Enabled' = $true
		'Client-Enabled' = $true
	}
	'TLS 1.2'= @{
		'Server-Enabled' = $true
		'Client-Enabled' = $true
	}
}
	
	
$protocols.Keys | ForEach-Object {
		
	Write-Output "Configuring '$_'"
	
	# create registry entries if they don't exist
	$rootPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$_"
	if(-not (Test-Path $rootPath)) {
		New-Item $rootPath
	}
	
	$serverPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$_\Server"
	if(-not (Test-Path $serverPath)) {
		New-Item $serverPath
	
		New-ItemProperty -Path $serverPath -Name 'Enabled' -Value 4294967295 -PropertyType 'DWord'
		New-ItemProperty -Path $serverPath -Name 'DisabledByDefault' -Value 0 -PropertyType 'DWord'
	}
	
	$clientPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$_\Client"
	if(-not (Test-Path $clientPath)) {
		New-Item $clientPath
			
		New-ItemProperty -Path $clientPath -Name 'Enabled' -Value 4294967295 -PropertyType 'DWord'
		New-ItemProperty -Path $clientPath -Name 'DisabledByDefault' -Value 0 -PropertyType 'DWord'
	}
		
	# set server settings
	if($protocols[$_]['Server-Enabled']) {
		Set-ItemProperty -Path $serverPath -Name 'Enabled' -Value 4294967295
		Set-ItemProperty -Path $serverPath -Name 'DisabledByDefault' -Value 0
	} else {
		Set-ItemProperty -Path $serverPath -Name 'Enabled' -Value 0
		Set-ItemProperty -Path $serverPath -Name 'DisabledByDefault' -Value 1
	}
		
	# set client settings
	if($protocols[$_]['Client-Enabled']) {
		Set-ItemProperty -Path $clientPath -Name 'Enabled' -Value 4294967295
		Set-ItemProperty -Path $clientPath -Name 'DisabledByDefault' -Value 0
	} else {
		Set-ItemProperty -Path $clientPath -Name 'Enabled' -Value 0
		Set-ItemProperty -Path $clientPath -Name 'DisabledByDefault' -Value 1
	}
}