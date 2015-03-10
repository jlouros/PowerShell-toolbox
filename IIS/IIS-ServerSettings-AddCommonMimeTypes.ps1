Function SetMimeTypeIfNotPresent
{
    param(
        [Parameter(Mandatory=$true)]
        $fileExtension,
        [Parameter(Mandatory=$true)]
        $mimeType
    )

    $config = Get-WebConfiguration system.webServer/staticContent/mimeMap | where { $_.fileExtension -eq $fileExtension }

    if($config -eq $null)
    {
        Write-Host "'$fileExtension' file extension configuration not found. Adding with MIME type '$mimeType'"
        Add-WebConfiguration system.webServer/staticContent -atIndex 0 -Value @{fileExtension=$fileExtension; mimeType=$mimeType}
    } 
    else 
    {
        Write-Host "Configuration for '$fileExtension' found. No changes will be performed"
    }
}


Import-Module -Name WebAdministration -ErrorAction Stop


SetMimeTypeIfNotPresent ".webm" "video/webm"
SetMimeTypeIfNotPresent ".ogg" "video/ogg"
SetMimeTypeIfNotPresent ".mov" "video/quicktime"
SetMimeTypeIfNotPresent ".mp4" "video/mp4"
SetMimeTypeIfNotPresent ".svg" "image/svg+xml"
SetMimeTypeIfNotPresent ".woff" "font/x-woff"
SetMimeTypeIfNotPresent ".otf" "font/otf"
SetMimeTypeIfNotPresent ".eot" "application/vnd.ms-fontobject"
SetMimeTypeIfNotPresent ".ttf" "application/octet-stream"