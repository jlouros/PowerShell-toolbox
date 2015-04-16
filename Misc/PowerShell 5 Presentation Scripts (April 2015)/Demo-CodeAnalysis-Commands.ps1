#Requires -Version 5.0


# get a list of static code analysis rules
Get-ScriptAnalyzerRule| Out-GridView 

# run code analysis on script 'ClassScript.ps1' located in the current folder
Invoke-ScriptAnalyzer -Path .\ClassScript.ps1


# define what rules to include/exclude
Invoke-ScriptAnalyzer -Path .\ClassScript.ps1 -IncludeRule ('AvoidUnitializedVariable', 'UseApprovedVerbs') -ExcludeRule 'UseSingularNouns'