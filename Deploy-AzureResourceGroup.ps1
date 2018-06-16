#requires -version 5.0
#requires -RunAsAdministrator
<#
.SYNOPSIS
   	Creates an automation lab to practice Azure automation, DSC, PowerShell and PowerShell core.

    The MIT License (MIT)
    Copyright (c) 2018 Preston K. Parsard

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

    Copyright (c) 2015, Carlos Perez All rights reserved.
    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Posh-SSH nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
    PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
    TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
#>

# Connect to Azure
Connect-AzureRmAccount

Do
{
    # Subscription name
	(Get-AzureRmSubscription).SubscriptionName
	[string]$Subscription = Read-Host "Please enter your subscription name, i.e. [MySubscriptionName] "
	$Subscription = $Subscription.ToUpper()
} #end Do
Until (Select-AzureRmSubscription -SubscriptionName $Subscription)

Do
{
 # Resource Group name
 [string]$rg = Read-Host "Please enter a NEW resource group name. NOTE: To avoid resource conflicts and facilitate better segregation/managment do NOT use an existing resource group [rg##] "
} #end Do
Until (($rg) -match '^rg\d{2}$')

Do
{
 # The location refers to a geographic region of an Azure data center
 $regions = Get-AzureRmLocation | Select-Object -ExpandProperty Location
 Write-Output "The list of available regions are :"
 Write-Output ""
 Write-Output $regions
 Write-Output ""
 $enterRegionMessage = "Please enter the geographic location (Azure Data Center Region) for resources, i.e. [eastus2 | westus2]"
 [string]$Region = Read-Host $enterRegionMessage
 $region = $region.ToUpper()
 Write-Output "`$Region selected: $Region "
 Write-Output ""
} #end Do
Until ($region -in $regions)

New-AzureRmResourceGroup -Name $rg -Location $region -Verbose

$templateUri = "https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/master/azuredeploy.json"
$adminUserName = "adm.infra.user"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName"
$adminPassword = $adminCred.GetNetworkCredential().password
$studentRandomInfix = (New-Guid).Guid.Replace("-","").Substring(0,8)

$parameters = @{}
$parameters.Add(“adminUserName”, $adminUserName)
$parameters.Add(“adminPassword”, $adminPassword)
$parameters.Add(“studentRandomInfix”, $studentRandomInfix)

New-AzureRmResourceGroupDeployment -Name 'azuredeploy-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
-ResourceGroupName $rg `
-TemplateFile $templateUri `
-TemplateParameterObject $parameters `
-Force -Verbose `
-ErrorVariable ErrorMessages
if ($ErrorMessages)
{
    Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
}