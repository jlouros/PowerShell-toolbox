$srcDir = "$env:HOMEDRIVE\code\myWebApp\src\bin\"
$desDir = 'P:\inetpub\myWebApp\'

$remoteMachineRootFolder = '\\web-app-001.local.domain\C$'

# network credentials, use this only for generic unsecure accounts.
$networkDomainUser = 'local\administrator'
$networkDomainPass = 'Password123'

# user credentials for the remote machine
$pass = $networkDomainPass | ConvertTo-SecureString -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList ($networkDomainUser, $pass)

# create new network drive and assign it to 'P'
New-PSDrive -Name P -Credential $Cred -PSProvider FileSystem -Root $remoteMachineRootFolder 

# copy folder to remove destination
Write-Output -InputObject 'Starting file copy to remote directory...'
Copy-Item -Path $srcDir -Destination $desDir -Force -Recurse


# remove network drive 'P'
Remove-PSDrive -Name P