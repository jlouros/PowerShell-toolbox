$downloadFolder = "C:\Downloaded Images\"
$searchFor = "funny pictures"
$nrOfImages = 12


Add-Type -AssemblyName System.Web

$webClient = New-Object System.Net.WebClient

$searchQuery = [System.Web.HttpUtility]::UrlEncode($searchFor)

$url = "http://www.bing.com/images/search?q=$searchQuery&first=0&count=$nrOfImages&qft=+filterui%3alicense-L2_L3_L4"

$webpage = $webclient.DownloadString($url)

$regex = "[(http(s)?):\/\/(www\.)?a-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-z0-9@:%_\+.~#?&//=]*)((.jpg(\/)?)|(.png(\/)?)){1}(?!([\w\/]+))"

$listImgUrls = $webpage | Select-String -pattern $regex -Allmatches | ForEach-Object {$_.Matches} | Select-Object $_.Value -Unique


if((Test-Path $downloadFolder) -eq $false) 
{
    Write-Output "Creating '$downloadFolder'..."

    New-Item -ItemType Directory -Path $downloadFolder | Out-Null
}

foreach($imgUrlString in $listImgUrls) 
{
    [Uri]$imgUri = New-Object System.Uri -ArgumentList $imgUrlString

    $imgFile = [System.IO.Path]::GetFileName($imgUri.LocalPath)

    $imgSaveDestination = Join-Path $downloadFolder $imgFile

    Write-Output "Downloading '$imgUrlString' to '$imgSaveDestination'..."

    $webClient.DownloadFile($imgUri, $imgSaveDestination)    
}