#requires -version 5.1
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
#>

$BeginTimer = Get-Date -Verbose
function Get-PSGalleryModule
{
	[CmdletBinding(PositionalBinding = $false)]
	Param
	(
		# Required modules
		[Parameter(Mandatory = $true,
				   HelpMessage = "Please enter the PowerShellGallery.com modules required for this script",
				   ValueFromPipeline = $true,
				   Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string[]]$ModulesToInstall
	) #end param

    # NOTE: The newest version of the PowerShellGet module can be found at: https://github.com/PowerShell/PowerShellGet/releases
    # 1. Always ensure that you have the latest version

	$Repository = "PSGallery"
	Set-PSRepository -Name $Repository -InstallationPolicy Trusted
	Install-PackageProvider -Name Nuget -ForceBootstrap -Force
	foreach ($Module in $ModulesToInstall)
	{
        # If module exists, update it
        If (Get-Module -Name $Module)
        {
            # To avoid multiple versions of a module is installed on the same system, first uninstall any previously installed and loaded versions if they exist
            Update-Module -Name $Module -Force -ErrorAction SilentlyContinue -Verbose
        } #end if
		    # If the modules aren't already loaded, install and import it
		else
		{
			# https://www.powershellgallery.com/packages/WriteToLogs
			Install-Module -Name $Module -Repository $Repository -Force -Verbose
			Import-Module -Name $Module -Verbose
		} #end If
	} #end foreach
} #end function

[string]$proceed = $null

# Verify parameter values
Do {
    $proceed = read-host "The PSGallery repository at www.powershellgallery.com will be configured as a trusted repository to download required modules for this script. Ok to proceed? [Y] [YES] [N] [NO]"
    $proceed = $proceed.ToUpper()
    }
Until ($proceed -eq "Y" -OR $proceed -eq "YES" -OR $proceed -eq "N" -OR $proceed -eq "NO")

if ($proceed -eq "N" -OR $proceed -eq "NO")
{
    Write-Output "Deployment terminated by user. Exiting..."
    PAUSE
    EXIT
} #end if ne Y
# Get required PowerShellGallery.com modules.
Get-PSGalleryModule -ModulesToInstall "AzureRM"

Write-Output "Please see the open dialogue box in your browser to authenticate to your Azure subscription..."

# Connect to Azure
Connect-AzureRmAccount

# Allowable student numbers
[int[]]$studentNumEnum = 0..16

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
    # Student number
    [int]$studentNumber = Read-Host "Please enter your student number, which must be a number from [0-16], or hit RETURN to select [0]. NOTE: Your resource group name will be rg##, where ## represents the number you entered."
} #end Do
Until (([int]$studentNumber) -in [int[]]$studentNumEnum)

# Resource Group name
[string]$rg = "rg" + [int]$studentNumber

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

# Ensure that the storage account name is glbally unique in DNS
Do
{
    $studentRandomInfix = (New-Guid).Guid.Replace("-","").Substring(0,8)
} #end while
While (-not((Get-AzureRmStorageAccountNameAvailability -Name $studentRandomInfix).NameAvailable))

$parameters = @{}
$parameters.Add("studentNumber", $studentNumber)
$parameters.Add(“adminUserName”, $adminUserName)
$parameters.Add(“adminPassword”, $adminPassword)
$parameters.Add(“studentRandomInfix”, $studentRandomInfix)

$rgDeployment = 'azuredeploy-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
New-AzureRmResourceGroupDeployment -Name $rgDeployment `
-ResourceGroupName $rg `
-TemplateFile $templateUri `
-TemplateParameterObject $parameters `
-Force -Verbose `
-ErrorVariable ErrorMessages
if ($ErrorMessages)
{
    Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
}
else
{
    $jumpDevMachine = "AZRDEV" + $studentNumber + "01"
    $fqdnDev = (Get-AzureRmPublicIpAddress -ResourceGroupName $rg | Where-Object { $_.Name -like 'azrdev*pip*'}).DnsSettings.fqdn

    $StopTimer = Get-Date -Verbose
    Write-Output "Calculating elapsed time..." -Log $Log
    $ExecutionTime = New-TimeSpan -Start $BeginTimer -End $StopTimer
    $Footer = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTime"
    Write-Output ""
    Wite-Output $Footer
$connectionMessage = @"
Your RDP connection prompt will open auotmatically after you read this message and press Enter to continue...

To log into your new automation lab jump server $jumpDevMachine, you must change your login name to: .\$adminUserName and specify the corresponding password you entered at the begining of this script.
You can now use this lab to practice Windows PowerShell, Windows Desired State Configuration (push/pull), PowerShell core, Linux Desired State Configuration, Azure Automation and Azure Automation DSC tasks to develop these skills.
For more details on what types of excercises you can practice, see the readme.md file in this GitHub repository at: https://github.com/autocloudarc/0026-azure-automation-plus-dsc-lab.
If you like this script, follow me on GitHub at https://github.com/autocloudarc, send feedback or submit issues so we can build a better experience for everyone.
Happy scripting...
"@
    Write-Output $connectionMessage
    # Allow engineer to pause and read connection message before continuing
    pause
    # Open RDP prompt automatically
    mstsc /v:$fqdnDev
}