<#
.SYNOPSIS
	Transfers files to the defined FTP server location

.NOTES    
	authors:
		https://github.com/jlouros
	version:
		0.1
	missing features:
		add capability to pass Username and Password (instead of NetworkCredentials)
		Check if target FTP destination is a valid folder
		Accept FTP destination as a string (instead of Url)
        Use SecureString for password
#>  

Param(
    [parameter(Mandatory=$true)]
	[System.String]$directory,
	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[System.String]$ftpAddressUrl,
	[parameter(Mandatory=$true)]
	[System.String]$ftpUsername,
    [parameter(Mandatory=$true)]
	[System.String]$ftpPassword
)

Function Check-If-Ftp-Directory-Exists {
	[OutputType('System.Boolean')]
	Param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Uri]$ftpAddress,
		[parameter(Mandatory=$true)]
		[System.Net.NetworkCredential]$ftpCredentials
	)
	
	$ftpDirectoryExisits = $true;
	Try
	{
		[System.Net.FtpWebRequest]$checkdirRequest = [System.Net.WebRequest]::Create($ftpAddress)
		$checkdirRequest.Credentials = $ftpCredentials
		$checkdirRequest.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
		#$checkdirRequest.UsePassive = $true
		#$checkdirRequest.KeepAlive = $false

		$resp = $checkdirRequest.GetResponse()
		$resp.Close()
	} 
	Catch 
	{
		# process error
		if($_.Exception.Message -match "File unavailable") {
			# expected expection, proceed with return False
			$ftpDirectoryExisits = $false
		} else {
			# unexpected error, cancel script execution
			Write-Host "Unexcepected error found. Terminating script execution"
			Write-Error $_.Exception.Message -ErrorAction Stop
		}
	}

	return $ftpDirectoryExisits
}

Function Create-FTP-Directory-Recursively {
	Param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Uri]$ftpTargetPath,
		[parameter(Mandatory=$true)]
		[System.Net.NetworkCredential]$ftpCredentials
	)

    [System.String[]]$ftpSegments = $ftpTargetPath.Segments;
    $ftpUrl = [string]::Format("{0}://{1}", $ftpTargetPath.Scheme, $ftpTargetPath.Host);

    # create necessary FTP folders
    for($i = 0; $i -lt $ftpSegments.Length; $i++) 
    {            
	    $ftpUrl += $ftpSegments[$i];

	    Write-Host "Checking is '$ftpUrl' exists"

	    if((Check-If-Ftp-Directory-Exists $ftpUrl $ftpCredentials) -eq $false) 
	    {
		    Write-Host "Couldn't find specified location. Creating '$ftpUrl' folder" -ForegroundColor Gray

		    [System.Net.FtpWebRequest]$mkdRequest = [System.Net.WebRequest]::Create($ftpUrl)
	        $mkdRequest.Credentials = $ftpCredentials
	        $mkdRequest.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory

	        $mkdResponse = $mkdRequest.GetResponse();
	        $mkdResponse.Close();
	    }
    }	
}

Function Transfer-Contents-To-FTP {
    Param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Array]$filesToTransfer,
        [parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Uri]$ftpTargetPath,
		[parameter(Mandatory=$true)]
		[System.Net.NetworkCredential]$ftpCredentials
	)

    # transfer files
    foreach($srcFile in $filesToTransfer) 
    {            
	    $fileDesitnation = New-Object System.Uri($ftpTargetPath, $srcFile.Name)

	    Write-Host "Uploading file '$fileDesitnation'"

	    # Upload file to FTP server
	    [System.Net.FtpWebRequest]$ufRequest = [System.Net.WebRequest]::Create($fileDesitnation)
	    $ufRequest.Credentials = $ftpCredentials
	    $ufRequest.Method = [System.Net.WebRequestMethods+FTP]::UploadFile

	    # Read file contents
	    $content = [System.IO.File]::ReadAllBytes($srcFile.FullName)
	    $ufRequest.ContentLength = $content.Length

	    $requestStream = $ufRequest.GetRequestStream();
	    $requestStream.Write($content, 0, $content.Length);
	    $requestStream.Close();

	    $ufResponse = $ufRequest.GetResponse();
	    $ufResponse.Close();
    }

}

Function Transfer-DirectoryContents {
    Param(
	    [parameter(Mandatory=$true)]
	    [ValidateNotNullOrEmpty()]
	    [System.String]$sourceDirectory,
	    [parameter(Mandatory=$true)]
	    [ValidateNotNullOrEmpty()]
	    [System.Uri]$ftpTargetPath,
	    [parameter(Mandatory=$true)]
	    [System.Net.NetworkCredential]$ftpCredentials
    )

    $directories = (Get-Item $sourceDirectory).GetDirectories()

    foreach($currDir in $directories) 
    {
        $newFtpDir = New-Object System.Uri($ftpTargetPath, "$($currDir.Name)/".Replace("//", "/"))
        $files = (Get-Item $currDir.FullName).GetFiles()

        Create-FTP-Directory-Recursively $newFtpDir $ftpCredentials

        if($files.Count -gt 0) {
            Transfer-Contents-To-FTP $files $newFtpDir $ftpCredentials
        }

        Transfer-DirectoryContents $currDir.FullName $newFtpDir $ftpCredentials
    }
}


Function Process-UploadContents {
    Param(
	    [parameter(Mandatory=$true)]
	    [ValidateNotNullOrEmpty()]
	    [System.String]$sourceDirectory,
	    [parameter(Mandatory=$true)]
	    [ValidateNotNullOrEmpty()]
	    [System.Uri]$ftpTargetPath,
	    [parameter(Mandatory=$true)]
	    [System.Net.NetworkCredential]$ftpCredentials
    )

    if($ftpTargetPath.AbsolutePath.EndsWith("/") -eq $false) { Write-Error "Passed FTP target directory is not valid: '$ftpTargetPath'." -ErrorAction Stop }

    if((Test-Path $sourceDirectory) -eq $false) { Write-Error "Invalid or unexisting source directory: '$sourceDirectory'." -ErrorAction Stop }


    $sourceDirItems = (Get-Item $sourceDirectory).GetFiles()

    if(($sourceDirItems -eq $null)-or ($sourceDirItems.Count -lt 1)) { Write-Error "Source directory is empty: '$sourceDirectory'. Terminating script, since no files will be copied" -ErrorAction Stop }

    Create-FTP-Directory-Recursively $ftpTargetPath $ftpCredentials

    Transfer-Contents-To-FTP $sourceDirItems $ftpTargetPath $ftpCredentials

    Transfer-DirectoryContents $sourceDirectory $ftpTargetPath $ftpCredentials
}


# script execution

$ftpUrl = New-Object System.Uri($ftpAddressUrl)
$ftpCredentials = New-Object System.Net.NetworkCredential($ftpUsername,$ftpPassword)

Process-UploadContents $directory $ftpUrl $ftpCredentials