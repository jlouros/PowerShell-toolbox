<#
.SYNOPSIS
	Downloads and starts standalone Wiremock
.NOTES
    Java Runtime environment must be installed and added to your PATH
#> 

param(
    [string] $version = '2.16.0',
    [int] $port = 19257
)

if ((Get-Command 'java' -ErrorAction SilentlyContinue) -eq $null)
{ 
   Throw "Unable to find Java in your PATH"
}

$file = "wiremock-standalone-$version.jar"

if(-not(Test-Path $file)) {
    $url = "http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/$version/$file"
    Write-Output "downloading WireMock $version from $url"
    if ((Invoke-WebRequest -Method Head $url -ErrorAction SilentlyContinue) -eq $null) {
        Throw "unable to download wiremock from $url"
    }
    
    Invoke-WebRequest $url -OutFile $file
}
$ps = Start-Process java -ArgumentList "-jar $file --port $port" -PassThru

Start-Sleep -Seconds 1

if ((Get-Process -Id $ps.Id -ErrorAction SilentlyContinue) -eq $null) {
    Write-Error -Message "wiremock did not start successfully, please ensure port $port is not being used" -Category OperationStopped -CategoryReason 'port already in use'
} else {
    Write-Output "wiremock running on 'http://localhost:$port'"
}
