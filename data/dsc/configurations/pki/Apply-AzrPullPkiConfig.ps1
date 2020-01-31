#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

using Namespace System.Security.Cryptography.X509Certificates

<#
.SYNOPSIS
Configure a PKI server using Azure Automation pull state configuration

.DESCRIPTION
This script includes a DSC configuration to build a PKI server using the Azure Automation State Configuration pull model.

.PARAMETER ResourceGroupName
The Azure resource group in which the automation account is contained.

.PARAMETER AutomationAccountName
The name of the automation account that hosts the state configuration pull server.

.PARAMETER ConfigurationName
The name of the configuration script to apply

.PARAMETER NodeConfigurationName
The name of the compiled configuration script that will be applied to target nodes

.PARAMETER TargetNode
The name of the target node that will be built as a PKI server.

.PARAMETER ConfigurationSourcePath 
The path to the DSC configuration script file.

.EXAMPLE
.\Apply-AzrPullAdsConfig.ps1 -ResourceGroupName <ResourceGroupName> -AutomationAccountName <AutomationAccountName> -ConfiugrationName <ConfigurationName> -NodeConfigurationName <NodeConfigurationName> `
-TargetNode <TargetNode> -ConfigurationSourcePath <ConfigurationSourcePath> -Verbose

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
3. https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-
4. https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-desired-state-configuration-lcm-and-push-management-model/
5. https://docs.microsoft.com/en-us/azure/automation/automation-dsc-compile
6. https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding
7. https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding#generating-dsc-metaconfigurations

.COMPONENT
Windows PowerShell Desired State Configuration, ActiveDirectory

.ROLE
Systems Engineer
DevOps Engineer
Active Directory Engineer

.FUNCTIONALITY
Configures a member server in an existing domain.
#>

[CmdletBinding()]
param (
	# TASK-ITEM: Specify the values for these parameters from your own environment.
	[string]$ResourceGroupName,
	[string]$AutomationAccountName,
	[string]$ConfigurationName,
	[string]$NodeConfigurationName,
	[string]$TargetNode,
	[string]$ConfigurationSourcePath
) # end param

#region FUNCTIONS
#endregion FUNCTIONS

# Create a transcript
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

#region Intialize values
# Set MOF path: Relevant for PUSH configuration only.
# $devMofPath = "E:\data\git\JHDesiredState\data\dsc\configurations\pki\mof"
# Select target node to configure by looking for the 01 series DC patter for dev.adatum.com the .. represents a 2 digit number that can vary by deployments
# $targetNode = $configData.AllNodes.NodeName
<#
TASK-ITEM: IMPORTANT. If you are onboarding on-premises machines to Azure Automation DSC, please do the following.
1. Review:
a. https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding
b. https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding#generating-dsc-metaconfigurations
2. Execute:

# Define the parameters for Get-AzAutomationDscOnboardingMetaconfig using PowerShell Splatting
$Params = @{
    ResourceGroupName = 'ContosoResources'; # The name of the Resource Group that contains your Azure Automation Account
    AutomationAccountName = 'ContosoAutomation'; # The name of the Azure Automation Account where you want a node on-boarded to
    ComputerName = @('web01', 'web02', 'sql01'); # The names of the computers that the meta configuration will be generated for
    OutputFolder = "$env:UserProfile\Desktop\";
}
# Use PowerShell splatting to pass parameters to the Azure Automation cmdlet being invoked
# For more info about splatting, run: Get-Help -Name about_Splatting
Get-AzAutomationDscOnboardingMetaconfig @Params

# Get list of resources required for this configuration so that can be copied to the target node
#>

#region TASK-ITEM: run this region of code if the DSC resources have not yet been installed on this local system.
$dscResourceList = @("xComputerManagement", "xStorage", "xPendingReboot")
# Install and import required modules locally, inlculeing the AzureAutomation module on this system so that the configuration can be compiled and the DSC resource modules can be imported to the Azure Automation account
Install-Module -Name ARMDeploy -Verbose
Import-Module -Name ARMDeploy -Verbose 
$modulesToInstall = $dscResourceList + "AzureAutomation"
Get-ARMDeployPSModule -ModulesToInstall $modulesToInstall -PSRepository "PSGallery" -Verbose
#endregion TASK-ITEM:

# Authenticate to the desired Azure subscription
# Get-Subscription
# Initialize Values
$Subscription = $null

# Clear any possible cached credentials for other subscriptions
Clear-AzContext -Force -Verbose

# Prompt for subscription credentials
Connect-AzAccount

# Display current subscriptions
(Get-AzSubscription).Name

# Get valid subscription
Do
{
    [string]$Subscription = Read-Host "Please enter your subscription name, i.e. [MySubscriptionName] "
    $Subscription = $Subscription.ToUpper()
} #end Do
Until ($Subscription -in (Get-AzSubscription).Name)
Select-AzSubscription -SubscriptionName $Subscription -Verbose

Import-Module -Name AzureAutomation -Verbose
# Import the AuzreAutomation module from the PowerShell gallery so that the DSC resources can be easily imported into the specified Auzre Automation account as module assets.
New-AutomationAccountModules -ResourceGroupName $ResourceGroupName -modules $dscResourceList -AutomationAccountName $AutomationAccountName -Verbose

$targetNetBiosName = $targetNode.Split(".")[0]
$ConfigDescription = ($ConfigurationSourcePath | Split-Path -Leaf).Split(".")[0]
# Import configuration to Azure Automation Account
If (Test-Path -Path $ConfigurationSourcePath)
{
	Import-AzAutomationDscConfiguration -ResourceGroupName $ResourceGroupName `
	-AutomationAccountName $AutomationAccountName `
	-Description $ConfigDescription `
	-SourcePath $ConfigurationSourcePath `
	-Published `
	-LogVerbose $true `
	-Verbose
} # end if
else 
{
	Write-Warning "Configuration source path not found. Please specify full path to configuration script file, i.e. \\<server>\share\applyPkiPullSvrConfig.ps1"
	Write-Warning "Terminating Script"
	Exit-PSSession
} # end else

# Complile configuration
$CompilationJob = Start-AzAutomationDscCompilationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -ConfigurationName $ConfigurationName -ErrorAction SilentlyContinue -Verbose 

while (($null -eq $CompilationJob.EndTime) -and ($null -eq $CompilationJob.Exception))
{
	$CompilationJob = $CompilationJob | Get-AzAutomationDscCompilationJob
	Write-Output "Waiting for configuration to compile."
	Start-Sleep -Seconds 3
} # end while
$CompilationJob | Get-AzAutomationDscCompilationJobOutput -Stream Any

# Register Azure Virtual machine as a Azure Automation DSC node.

Register-AzAutomationDscNode -AzureVMName $targetNetBiosName `
-NodeConfigurationName $NodeConfigurationName `
-ConfigurationModeFrequencyMins 15 `
-RefreshFrequencyMins 30 `
-RebootNodeIfNeeded $true `
-ActionAfterReboot ContinueConfiguration `
-AllowModuleOverwrite $true `
-ResourceGroupName $ResourceGroupName `
-AutomationAccountName $AutomationAccountName `
-Verbose

Do  
{
	Start-Sleep -Seconds 5
	Write-Output "Waiting for node $targetNetBiosName to register in Azure Automation DSC."
} # end do 
Until ((Get-AzAutomationDscNode -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName).Name -eq $targetNetBiosName)

Stop-Transcript -Verbose
notepad.exe $logFilePath
#endregion 