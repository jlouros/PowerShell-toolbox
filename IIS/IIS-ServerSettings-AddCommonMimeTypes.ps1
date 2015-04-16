Function Set-MimeTypeIfNotPresent
{
    param(
        [Parameter(Mandatory=$true)]
        $fileExtension,
        [Parameter(Mandatory=$true)]
        $mimeType
    )

    $config = Get-WebConfiguration system.webServer/staticContent/mimeMap | Where-Object { $_.fileExtension -eq $fileExtension }

    if($config -eq $null)
    {
        Write-Output "'$fileExtension' file extension configuration not found. Adding with MIME type '$mimeType'"
        Add-WebConfiguration system.webServer/staticContent -atIndex 0 -Value @{fileExtension=$fileExtension; mimeType=$mimeType}
    } 
    else 
    {
        Write-Output "Configuration for '$fileExtension' found. No changes will be performed"
    }
}


Import-Module -Name WebAdministration -ErrorAction Stop


Set-MimeTypeIfNotPresent '.webm' 'video/webm'
Set-MimeTypeIfNotPresent '.ogg' 'video/ogg'
Set-MimeTypeIfNotPresent '.mov' 'video/quicktime'
Set-MimeTypeIfNotPresent '.mp4' 'video/mp4'
Set-MimeTypeIfNotPresent '.svg' 'image/svg+xml'
Set-MimeTypeIfNotPresent '.woff' 'font/x-woff'
Set-MimeTypeIfNotPresent '.otf' 'font/otf'
Set-MimeTypeIfNotPresent '.eot' 'application/vnd.ms-fontobject'
Set-MimeTypeIfNotPresent '.ttf' 'application/octet-stream'