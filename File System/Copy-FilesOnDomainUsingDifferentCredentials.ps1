$srcDir = 'C:\code\myWebApp\src\bin\'
$desDir = 'P:\inetpub\myWebApp\'

$remoteMachineRootFolder = '\\web-app-001.local.domain\C$'

# network credentials, use this only for generic unsecure accounts.
$networkDomainUser = 'local\administrator'
$networkDomainPass = 'Password123'

# user credentials for the remote machine
$pass = $networkDomainPass | ConvertTo-SecureString -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PsCredential($networkDomainUser, $pass)

# create new network drive and assign it to 'P'
New-PSDrive -Name P -Credential $Cred -PSProvider FileSystem -Root $remoteMachineRootFolder 

# copy folder to remove destination
Write-Output 'Starting file copy to remote directory...'
Copy-Item $srcDir $desDir -Force -Recurse


# remove network drive 'P'
Remove-PSDrive -Name P