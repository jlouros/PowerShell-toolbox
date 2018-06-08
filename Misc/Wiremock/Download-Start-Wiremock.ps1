<#
.SYNOPSIS
automatically downloads and starts Wiremock

.PARAMETER Version 
version of Wiremock of use

.PARAMETER Port
port where wiremock will be running on

.NOTES
    Java Runtime environment must be installed and added to your PATH
#>
param(
    [ValidateNotNullorEmpty()]
    [string] $Version = '2.18.0',
    [ValidateNotNullorEmpty()]
    [int] $Port = 19257
)

if ((Get-Command 'java' -ErrorAction SilentlyContinue) -eq $null)
{ 
   Throw "Unable to find Java in your PATH"
}

$downloadLocation = Join-Path $env:USERPROFILE 'AppData\Local\Wiremock'

if (-not(Test-Path $downloadLocation)) {
    mkdir $downloadLocation
}

Push-Location $downloadLocation

$fileName = "wiremock-standalone-$Version.jar"
$filePath = (Join-Path $downloadLocation $fileName)

if(-not(Test-Path $filePath)) {
    $url = "http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/$Version/$fileName"
    Write-Output "downloading WireMock $Version from $url"
    if ((Invoke-WebRequest -Method Head $url -ErrorAction SilentlyContinue) -eq $null) {
        Throw "unable to download wiremock from $url"
    }
    
    Invoke-WebRequest $url -OutFile $filePath
}
$ps = Start-Process java -ArgumentList "-jar $filePath --port $Port" -PassThru

Start-Sleep -Seconds 1

$wiremockProcessId = Get-Process -Id $ps.Id -ErrorAction SilentlyContinue

if ($wiremockProcessId -eq $null) {
    Write-Error -Message "wiremock did not start successfully, please ensure port $Port is not being used" -Category OperationStopped -CategoryReason 'port already in use'
} else {
    Write-Output "wiremock running on 'http://localhost:$Port'"
}

Pop-Location