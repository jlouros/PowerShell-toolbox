# finds all '.zip' files located in the current directory (where this script is located)
# extracts each archive to '\unzipped\'

# requires .Net Framework 4.5
if(-not ($PSVersionTable.CLRVersion.Major -eq 4 -and $PSVersionTable.CLRVersion.Revision -gt 17000)) 
{
	Write-Error -Message 'This script requires .Net Framework 4.5. Unable to proceed.' -ErrorAction Stop
}

$zipFiles = Get-ChildItem -Path . | Where-Object { $_.Name.EndsWith('.zip') }

foreach($zipFile in $zipFiles) 
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

    $extractLocation = Join-Path -Path $zipFile.Directory -ChildPath 'unzipped'

    Write-Output -InputObject "Extracting '$($zipFile.Name)' to '$extractLocation'"

    [IO.Compression.ZipFile]::ExtractToDirectory($zipFile.FullName, $extractLocation)
}



####################
# PowerShell 5.0
####################

Import-Module -Name Microsoft.PowerShell.Archive

$srcFile = '.\myZipFile.zip'
$destFolder = '.\ExtractedContents\'
Expand-Archive -Path $srcFile -DestinationPath $destFolder