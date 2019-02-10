<#
.SYNOPSIS
    Silently Download and Install SQL Server Management Studio (SSMS).
.DESCRIPTION
    This script will download and install the latest available SSMS from Microsoft.
	https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
.PARAMETER WriteLog
    You want to log to a file. It will generate more than a few files :)
.EXAMPLE
    .\Install-Applications.ps1 -WriteLog 1
.NOTES
.LINK
 SSDT Visual Studio Data Tools 2017
 https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-2017
#>
 
#Requires -RunAsAdministrator
 
[CmdletBinding()]
param (
    [parameter(Mandatory = $false)]
    [int]$WriteLog = 0
)
 
Clear
$ErrorActionPreference="SilentlyContinue"
 
if(-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
 
$msg = ""
$args = @()
$args += "/install /passive /norestart" 
#$args += "/install /quiet /norestart" 
#${sharedPath}SSMS-Setup-ENU.exe /install /quiet /passive /norestart

if($WriteLog -eq 1) { 
    $args += "/log SSMS_$(Get-Date -Format `"yyyyMMdd_HHmm`").txt"
    $installationLog = "$PSScriptRoot\SSMS_$(Get-Date -Format `"yyyyMMdd_HHmm`").txt"
    $msg = "InstallationLog: $installationLog"
}
 
 
Write-Host "Mapping Network Drive S to Azure Files"

# Start the download
<#
$Domain = "https://msdn.microsoft.com/en-us/library/mt238290.aspx"
$url = ((Invoke-WebRequest -uri $Domain).Links | Where innerHTML -match "Download SQL Server Management Studio").href | Select -First 1
$job = Start-BitsTransfer -Source $url -DisplayName SSMS -Destination "SSMS-Setup-ENU.exe" -Asynchronous

while (($Job.JobState -eq "Transferring") -or ($Job.JobState -eq "Connecting")) { 
    Start-Sleep 5;
} # Poll for status, sleep for 5 seconds, or perform an action.
 
Switch($Job.JobState) {
    "Transferred" { Complete-BitsTransfer -BitsJob $Job; Write-Output "Download completed!" }
    "Error" { $Job | Format-List } # List the errors.
    default { Write-Output "You need to re-run the script, there is a problem with the proxy or Microsoft has changed the download link!"; Exit } # Perform corrective action.
}

# We close running SSMS processes
if (Get-Process 'Ssms') {
    Stop-Process -Name Ssms
}
#>

# Connect to Azure File share and map drive
$acctKey = ConvertTo-SecureString -String "hTWKNB8zyE8yYKxGbZVJHReX0Bkbotj+ZqdmKPTpoYEje9hTzNlRTgjz6AsHY4ogOFLwbkgKTgEubZwfhd/60g==" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\linkedarmtemplateslvolk", $acctKey
New-PSDrive -Name S -PSProvider FileSystem -Root "\\linkedarmtemplateslvolk.file.core.windows.net\software" -Credential $credential -Persist
$sourcePathSMSS = "S:\SSMS-Setup-ENU.exe"

Write-Output "Performing silent install..."
 
# Install SSMS silently
Start-Process -FilePath $sourcePathSMSS -ArgumentList $args -Wait -Verb RunAs
# Install SSDT silently
$sourcePathSSDT = "S:\ssdt\SSDT-Setup-ENU.exe"
$argSSDT="/INSTALLALL[:vsinstances] /passive"
Start-Process -FilePath $sourcePathSSDT -ArgumentList $argSSDT -Wait -Verb RunAs   
Write-Output $msg
Remove-PSDrive -Name S -Force
Write-Output "All done!"
notepad $installationLog