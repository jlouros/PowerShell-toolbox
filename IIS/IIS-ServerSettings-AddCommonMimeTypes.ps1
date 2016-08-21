Function Set-MimeTypeIfNotPresent
{
  <#
    .SYNOPSIS
    Associates file extension with MIME type in IIS
  #>


    param(
        [Parameter(Mandatory=$true)]
        [string]$fileExtension,
        [Parameter(Mandatory=$true)]
        [string]$mimeType
    )

    $config = Get-WebConfiguration -Filter system.webServer/staticContent/mimeMap | Where-Object { $_.fileExtension -eq $fileExtension }

    if($config -eq $null)
    {
        Write-Output -InputObject "'$fileExtension' file extension configuration not found. Adding with MIME type '$mimeType'"
        Add-WebConfiguration -Filter system.webServer/staticContent -AtIndex 0 -Value @{fileExtension=$fileExtension; mimeType=$mimeType}
    } 
    else 
    {
        Write-Output -InputObject "Configuration for '$fileExtension' found. No changes will be performed"
    }
}


Import-Module -Name WebAdministration -ErrorAction Stop


Set-MimeTypeIfNotPresent -fileExtension '.webm' -mimeType 'video/webm'
Set-MimeTypeIfNotPresent -fileExtension '.ogg' -mimeType 'video/ogg'
Set-MimeTypeIfNotPresent -fileExtension '.mov' -mimeType 'video/quicktime'
Set-MimeTypeIfNotPresent -fileExtension '.mp4' -mimeType 'video/mp4'
Set-MimeTypeIfNotPresent -fileExtension '.svg' -mimeType 'image/svg+xml'
Set-MimeTypeIfNotPresent -fileExtension '.woff' -mimeType 'font/x-woff'
Set-MimeTypeIfNotPresent -fileExtension '.otf' -mimeType 'font/otf'
Set-MimeTypeIfNotPresent -fileExtension '.eot' -mimeType 'application/vnd.ms-fontobject'
Set-MimeTypeIfNotPresent -fileExtension '.ttf' -mimeType 'application/octet-stream'