# finds all '.zip' files located in the current directory (where this script is located)
# extracts each archive to '\unzipped\'

# requires .Net Framework 4.5
if(-not ($PSVersionTable.CLRVersion.Major -eq 4 -and $PSVersionTable.CLRVersion.Revision -gt 17000)) 
{
	Write-Error "This script requires .Net Framework 4.5. Unable to proceed." -ErrorAction Stop
}

$zipFiles = Get-ChildItem . | ? { $_.Name.EndsWith(".zip") }

foreach($zipFile in $zipFiles) 
{
    [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

    $extractLocation = Join-Path $zipFile.Directory "unzipped"

    Write-Output "Extracting '$($zipFile.Name)' to '$extractLocation'"

    [IO.Compression.ZipFile]::ExtractToDirectory($zipFile.FullName, $extractLocation)
}