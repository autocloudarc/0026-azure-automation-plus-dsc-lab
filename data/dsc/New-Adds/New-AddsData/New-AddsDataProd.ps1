#requires -version 4.0
#requires -RunAsAdministrator
<#
****************************************************************************************************************************************************************************
PROGRAM		: New-AddsCnfg.ps1
DESCIRPTION	: This script will configure a member server in Azure using Azure Automation DSC as the first domain controller in a forest based on the user specified domain name and credentials
PARAMETERS	: $creds - This variable will hold the name of the automation account asset that will be used to create the new domain
INPUTS		: Configuration data supplied using the configuration data parameter in the Start-AzureRmAutomationDscCompilationJob cmdlet below
              Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $AutomationAcct -ConfigurationName $ConfigName -ConfigurationData $ConfigData -Parameters $parameters 
OUTPUTS		:
EXAMPLES	: New-AddsCnfg.ps1
REQUIREMENTS: PowerShell Version 4.0, Run as administrator, two 10GB data disks for the node
              This configuration must be published to the Azure automation account before remotely running the Start-AzureRmAutomationDscCompilationJob cmdlet to compile the configuration
LIMITATIONS	: NA
AUTHOR(S)	: Preston K. Parsard
EDITOR(S)	: Preston K. Parsard
REFERENCES	: 1. https://azure.microsoft.com/en-us/documentation/articles/automation-dsc-compile/
              2. https://blogs.msdn.microsoft.com/powershell/2014/01/09/separating-what-from-where-in-powershell-dsc/

KEYWORDS	: Domain Controller, DSC, xStorage, xActiveDirectory

LICENSE:

The MIT License (MIT)
Copyright (c) 2016 Preston K. Parsard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software. 

DISCLAIMER:

THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, 
royalty-free right to use and modify the Sample Code and to reproduce and distribute the Sample Code, provided that You agree: (i) to not use Our name, 
logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, 
and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, 
that arise or result from the use or distribution of the Sample Code.
****************************************************************************************************************************************************************************
#>

<# WORK ITEMS
TASK-INDEX: 
#>

#***************************************************************************************************************************************************************************
# REVISION/CHANGE RECORD	
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DATE        VERSION    NAME			    E-MAIL				   CHANGE
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 17 MAR 2016 00.01.0001 Preston K. Parsard prestopa@microsoft.com Initial release
# 16 JUN 2016 00.01.0002 Preston K. Parsard prestopa@microsoft.com Fixed cannot find automation account error by correctly specifying the resource group of the automation 
# .................................................................account instead of the node resource group in the cmdlet:
# .................................................................$CompilationJob = Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $AutomationAcct -ConfigurationName $ConfigName -ConfigurationData $ConfigData -Parameters $parameters


# Login to Azure Account
Login-AzureRmAccount

# Select subscription

$ConfigData = @{
 AllNodes = @(
 @{
   NodeName = '*'
   PSDscAllowPlainTextPassword = $true
   PSDscAllowDomainUser = $true  
   RetryCount = 20               
   RetryIntervalSec = 30
  } #end node
 
 @{
   NodeName = "Prod"
   # Role = "DomainController"
   DomainName = "prod.lab"
  } #end node
 )
} #end $ConfigData

# PowerShell requires parameters in a hashtable
$parameters = @{
		creds = "<>"
} #end $parameters

# IMPORTANT: Specify the resource group in which the AUTOMATION account is located, not the resource group where the NODE(S) reside
$rg = "<>"

$AutomationAcct = "<>"
$ConfigName = "NewAdds"

$CompilationJob = Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $AutomationAcct -ConfigurationName $ConfigName -ConfigurationData $ConfigData -Parameters $parameters
while($CompilationJob.EndTime –eq $null -and $CompilationJob.Exception –eq $null)           
{
 $CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
 Start-Sleep -Seconds 3
}
$CompilationJob | Get-AzureRmAutomationDscCompilationJobOutput –Stream Any 