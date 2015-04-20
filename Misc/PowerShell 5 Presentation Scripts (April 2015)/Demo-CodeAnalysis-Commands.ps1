#Requires -Version 5.0

# also requires "Windows Management Framework 5.0 Preview February 2015" check out the link below
# http://blogs.msdn.com/b/powershell/archive/2015/02/18/windows-management-framework-5-0-preview-february-2015-is-now-available.aspx

# get a list of static code analysis rules
Get-ScriptAnalyzerRule| Out-GridView 

# run code analysis on script 'ClassScript.ps1' located in the current folder
Invoke-ScriptAnalyzer -Path .\ClassScript.ps1


# define what rules to include/exclude
Invoke-ScriptAnalyzer -Path .\ClassScript.ps1 -IncludeRule ('AvoidUnitializedVariable', 'UseApprovedVerbs') -ExcludeRule 'UseSingularNouns'