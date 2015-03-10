Write-Host "Installing SQL Server 2008 R2"

\\file.server\share\AutomatedInstall\SQL\Binaries\en_sql_server_2008_r2_standard_x86_x64_ia64\setup.exe /CONFIGURATIONFILE=\\file.server\Share\AutomatedInstall\SQL\ConfigFiles\SQLServerConfigurationFile.ini /IACCEPTSQLSERVERLICENSETERMS | Write-Host



OR



Write-Host "Installing SQL Server 2008 R2"

$command = "\\file.server\Share\en_sql_server_2008_r2_standard_x86_x64_ia64\setup.exe /CONFIGURATIONFILE=\\file.server\Share\SQLServerConfigurationFileBasic.ini /IACCEPTSQLSERVERLICENSETERMS"

$process = [System.Diagnostics.Process]::Start($command)

$process.WaitForExit()
