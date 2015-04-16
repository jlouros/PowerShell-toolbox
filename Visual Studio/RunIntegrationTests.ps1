Set-Location C:\Deploy

Write-Host 'Run on Test Server!'

$trxName = 'C:\Deploy\LatestTestResult.trx'
if(Test-Path $trxName) 
{
    Remove-Item $trxName
}

& 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\mstest.exe' /testcontainer:"C:\Deploy\Library.Integration.Tests.dll" /testsettings:"C:\Deploy\build.testsettings" /resultsfile:"C:\Deploy\LatestTestResult.trx"