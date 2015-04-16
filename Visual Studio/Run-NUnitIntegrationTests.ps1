[CmdletBinding()]
param(
    [Alias('NUNIT', 'N')]
    [System.String]
    [ValidateScript({
        if((Test-Path $_) -eq $false)
        {
            Throw New-Object -TypeName System.ArgumentException -ArgumentList "Unable to locate NUnit console in the provided path '$_'", 'NUnitConsolePath'
        }
    })]
    $NUnitConsolePath = 'C:\Apps\NUnit-2.6.4\bin\nunit-console.exe',
    
    [Alias('PATH', 'P')]
    [System.String]
    [ValidateScript({
        if((Test-Path $_) -eq $false)
        {
            Throw New-Object -TypeName System.ArgumentException -ArgumentList "The provided test folder location path is invalid '$_'", 'TestsPath'
        }
    })]
    $TestsPath = $(Join-Path $PSScriptRoot '\..' | Resolve-Path)
)

$testDlls = Get-ChildItem $(Join-Path $TestsPath '\*') -Include '*.Tests.Integration.dll' -Recurse | Where-Object { $_ -inotmatch '\\obj\\'} | Sort-Object Name -Unique

if($testDlls -eq $null) 
{
    Write-Output "`r`n--> Unable to locate any testable binary, for given path '$TestsPath'"
    return;
}

# Run Unit tests for each test dll found
foreach($testDll in $testDlls) 
{
    Write-Output "`r`n--> Executing '$testDll'`r`n"
    & $NUnitConsolePath $($testDll.FullName) '/nologo'
    Write-Output '--> Test run complete!'
}