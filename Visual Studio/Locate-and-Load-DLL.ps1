Function LoadStashApiDll 
{
    $dllName = "Atlassian.Stash.Api.dll"

    $dlls = Get-ChildItem .\Atlassian.Stash.Api\bin\ -Recurse | ? { $_.Name -match $dllName }

    if($dlls.Length -eq 0) 
    {
        Write-Error "Unable to find '$dllName'. Please compile the solution first." -ErrorAction Stop
    } 
    elseif($dlls.Length -gt 1) 
    {
        # if mulitple matches were found, just pick the first one
      $dlls = $dlls[0]  
    }

    Add-Type -Path $dlls.FullName -ErrorAction Stop

    Write-Output "'$dllName' successfully loaded."
}

LoadStashApiDll 
#$stashClient = New-Object Atlassian.Stash.Api.StashClient("http://ptr-cvsd/", "asdassa")