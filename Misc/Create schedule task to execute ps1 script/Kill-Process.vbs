Dim objShell,objFSO,objFile

Set objShell=CreateObject("WScript.Shell")
Set objFSO=CreateObject("Scripting.FileSystemObject")

'enter the path for your PowerShell Script
strPath="C:\StartupScripts\Kill-Process.ps1"

'verify file exists
If objFSO.FileExists(strPath) Then
'return short path name
    set objFile=objFSO.GetFile(strPath)
    strCMD="powershell -nologo -command " & Chr(34) & "&{" & objFile.Path & "}" & Chr(34) 
    'Uncomment next line for debugging
    'WScript.Echo strCMD
    
    'use 0 to hide window
    objShell.Run strCMD,0

Else

'Display error message
    WScript.Echo "Failed to find " & strPath
    WScript.Quit
    
End If