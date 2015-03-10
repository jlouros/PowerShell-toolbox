# This script will be run as a pre-build event for database projects.
# powershell -NoProfile -ExecutionPolicy RemoteSigned -file $(ProjectDir)Post Deployment Scripts\BuildPostDeploymentScript.ps1

Write-Output "BEGIN generating post-deployment script references . . .";
Write-Output "`r`n";

$dataFolderPath = "..\..\Post Deployment Scripts"; 
$postDeploymentScriptFileName = "PostDeploymentScript.sql";
$postDeploymentScriptPath = "..\..\Post Deployment Scripts\$postDeploymentScriptFileName";


Write-Output "Looping through folder: " $dataFolderPath;

# Use 'here string' to write comment header to file.
$postDeploymentScript_HeaderComments =@"
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
			   SELECT * FROM [`$(TableName)]					
--------------------------------------------------------------------------------------
*/`r`n
"@;

# Output comment header to target file.
$postDeploymentScript_HeaderComments |  Out-File -filePath $postDeploymentScriptPath -encoding utf8;

# Get only sql files in data folder.
$sqlScripts = @(Get-ChildItem $dataFolderPath -Recurse -Include *.sql -Exclude PostDeploymentScript.sql) | Sort-Object;

# Output number of files found.
Write-Output "Found " $sqlScripts.Count " files."

# Add each data script file to the post-deployment script.
foreach ($script in $sqlScripts)
{
	# Output file name.
	Write-Output "Adding reference for: " $script "`r`n to " $postDeploymentScriptPath;
	
	$sqlScriptPath = "PRINT N'Executing post deploymenty script: ";
	$sqlScriptPath += $script.Name;
	$sqlScriptPath += "';`r`n";

	# Add carriage-return/new-line and 'r:'.
	$sqlScriptPath += ':r "';
	$sqlScriptPath += $script;
	$sqlScriptPath += '"';

	$sqlScriptPath += "`r`nPRINT N'Done execution of: ";
	$sqlScriptPath += $script.Name;
	$sqlScriptPath += "';`r`n";
	
	$sqlScriptPath |  Out-File -filePath $postDeploymentScriptPath -append -encoding utf8;    
}

#Write-Output (Get-ChildItem $dataFolderPath -Recurse).Count;

# Done.
Write-Output "`r`n";
Write-Output "DONE generating sql script references for " $postDeploymentScriptPath "`r`n";
