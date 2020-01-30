#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

using Namespace System.Security.Cryptography.X509Certificates

<#
.SYNOPSIS
Demote a domain controller that was previously configured using DSC using an imperative PowerShell scripting.

.DESCRIPTION
This script includes a DSC configuration to remove a replica (not last) domain controller for an existing domain. 

.PARAMETER targetDcToDemote
The target domain controller that will be reset back to a member server status.

.PARAMETER Reset
Demotes the DC to a member server.

.EXAMPLE
.\Reset-PushAdsConfig.ps1 -targetDcToDemote <targetDcToDemote> -Verbose 

.NOTES
The MIT License (MIT)
Copyright (c) 2020 Preston K. Parsard

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.LINK
1. Create a replica DC using DSC: https://blog.kloud.com.au/2016/09/20/create-a-replica-domain-controller-using-desired-state-configuration/
2. Getting Started with PowerShell DSC: Securing domainAdminCreds in MOF Files | packtpub.com: https://youtu.be/2nsCQ32Ufx0 
3. https://docs.microsoft.com/en-us/powershell/module/addsdeployment/uninstall-addsdomaincontroller?view=win10-ps

.COMPONENT
Active Directory

.ROLE
DevOps Engineer
Active Directory Engineer

.FUNCTIONALITY
Demotes a replica domain controller to a member server in an existing domain. This is used for reseting a push configuration to build an additional replica DC with DSC.
#>

[CmdletBinding()]
param (
	[parameter(Mandatory)]
	[string]$targetDcToDemote
) #end param

# TASK-ITEM: PRE-REQUISITE - Execute the following commented script block interactively.
# ***IMPORTANT***: PREREQUISITE; Run the following snippet on the target DC that will be demoted
<#
Enter-PSSession -ComputerName $targetDcToDemote 
Uninstall-ADDSDomainController -credential (Get-Credential -Message "Enter domain admin credentials") -RemoveApplicationPartitions -ErrorAction SilentlyContinue -Verbose
Exit-PSSession
#>

$logPath = Join-Path $PSScriptRoot -ChildPath "log"
If (-not(Test-Path -Path $logPath -ErrorAction SilentlyContinue))
{
	New-Item -Path $logPath -ItemType Directory -Verbose
} # end if
$scriptName = $MyInvocation.MyCommand.Name.Split(".")[0]
$dateTime = (Get-Date -Format u).Replace(" ","-").Replace(":","").Substring(0,15)
$logFileName = "$scriptName-$dateTime.log"
$logFilePath = Join-Path -Path $logPath -ChildPath $logFileName
New-Item -Path $logFilePath -ItemType File -Verbose
Start-Transcript -Path $logFilePath -IncludeInvocationHeader -Verbose

# TASK-ITEM: Run this line to restart the machine
Restart-Computer -ComputerName $targetDcToDemote -Force -Verbose

# TASK-ITEM: Execute this Do-Until loop to know when it is back online.
Do
{
	Write-Output "Waiting for $targetDcToDemote to restart..."
	Start-Sleep -Seconds 3 -Verbose
} Until (Test-Connection -ComputerName $targetDcToDemote)

Stop-Transcript -Verbose
notepad.exe $logFilePath
#endregion 