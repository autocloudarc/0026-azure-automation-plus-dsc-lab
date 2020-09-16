#requires -version 5.1
#requires -RunAsAdministrator

using Namespace System
using Namespace System.Net # for IP addresses
Using Namespace System.Runtime.InteropServices # # For Azure AD service principals marshal clas
Using Namespace Microsoft.Azure.Commands.Management.Storage.Models # for Azure storage
Using Namespace Microsoft.Azure.Commands.Network.Models # for Azure network resources
<#
.SYNOPSIS
Creates a lab infrastructure to practice Azure Automation, administration, governance, DSC, PowerShell and PowerShell core topics.

.DESCRIPTION
This script will create a lab infrastructure to practice Azure automation, administration, governance, automation, DSC, PowerShell and PowerShell core topics. The capabilities are limited only by your imagination!

PRE-REQUISITES:
1. Before executing this script, ensure that you change the directory to the directory where the script is located. For example, if the script is in: c:\scripts\Deploy-AzureResourceGroup.ps1 then
    change to this directory using the following command:
    Set-Location -Path c:\scripts

.PARAMETER excludeWeb
Exclude web servers from deployment to reduce total deployment cost and deployment time.

.PARAMETER excludeSql
Exclude SQL servers from deployment to reduce total deployment cost and deployment time.

.PARAMETER excludeAds
Exclude the two additional domain controllers that will just be provisioned initially as member servers to reduce total deployment cost and deployment time.

.PARAMETER excludePki
Exclude the PKI server from this deployment.

.PARAMETER includeCentos
Include a CentOS server for this deployment.

.PARAMETER includeUbuntu
Inclue an Ubuntu server for this deployment.

.PARAMETER addBastion
Add the bastion service to this solution

.EXAMPLE
.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -excludePki yes -includeUbuntu yes -Verbose

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers and the PKI server, but ADDS
an additional Linux server with the latest Ubuntu Server distribution.

.EXAMPLE
.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -Verbose

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers, but WILL implicitly deploy the PKI server.
This is due to the default parameter value that is set in the paramater block as [string]$excludePki = "no".

.EXAMPLE
.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -includeCentOS yes -includeUbuntu no -Verbose

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers and the Ubuntu server, but WILL implicitly deploy the PKI server and
explicity provision the CentOS server as well. The PKI server will not be deployed due to the default parameter value that is set in the paramater block as [string]$excludePki = "no".

.EXAMPLE
. .\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -excludePki yes -includeCentOS no -includeUbuntu no -artifactsLocation 'https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/dev/' -Verbose

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers and the Linux servers, and also excludes the PKI server. In addition, the artifacts location for the dev branch will be used. The default is to use the master branch.

.INPUTS
None

.OUTPUTS
The outputs generated from this script includes:
1. A transcript log file to provide the full details of script execution. It will use the name format: Deploy-AzureResourceGroup-TRANSCRIPT-<Date-Time>.log

.NOTES
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
1: https://millerb.co.uk/2019/02/28/My-Vscode-Setup.html#visual-studio-code
2. https://www.softwaretestinghelp.com/what-is-software-testing-life-cycle-stlc/
3. https://www.testingexcellence.com/software-testing-glossary/
4. https://www.red-gate.com/simple-talk/cloud/infrastructure-as-a-service/azure-resource-manager-arm-templates/
5. https://azure.microsoft.com/en-us/blog/create-flexible-arm-templates-using-conditions-and-logical-functions/
6. https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm
7. https://github.com/Azure/azure-quickstart-templates/tree/master/101-azure-bastion
8. https://github.com/ans-rfroggatt/Imperial-POC/blob/master/Networking/Networking-NSG.json
9. http://sql.pawlikowski.pro/2020/01/22/azure-bastion-creating-proper-nsg-rules/

.COMPONENT
Azure Infrastructure, PowerShell, ARM, JSON

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Deploys an Azure automation lab infrastructure

#>

[CmdletBinding()]
param
(
    # Parameter help description
    [ValidateSet("yes","no")]
    [string]$excludeWeb = "no",
    [ValidateSet("yes","no")]
    [string]$excludeSql = "no",
    [ValidateSet("yes","no")]
    [string]$excludeAds = "no",
    [ValidateSet("yes","no")]
    [string]$excludePki = "no",
    [ValidateSet("yes","no")]
    [string]$includeCentOS = "yes",
    [ValidateSet("yes","no")]
    [string]$includeUbuntu = "no",
    [string]$templateFile = "azuredeploy.json",
    [string]$bastionFile = "nested/08.00.00.createBastion.json",
    [ValidateSet('https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/master/','https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/dev/')]
    [string]$artifactsLocation = 'https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/master/',
    [string]$templateUri = ($artifactsLocation + $templateFile),
    [string]$bastionUri = ($artifactsLocation + $bastionFile),
    [switch]$addBastion
    #>
) # end param

# TASK-ITEM: Implement addBastion switch parameter

$BeginTimer = Get-Date -Verbose

#region MODULES
# Module repository setup and configuration
$PSModuleRepository = "PSGallery"
Set-PSRepository -Name $PSModuleRepository -InstallationPolicy Trusted -Verbose
Install-PackageProvider -Name Nuget -ForceBootstrap -Force

# Bootstrap dependent modules
$ARMDeployModule = "ARMDeploy"
if (Get-InstalledModule -Name $ARMDeployModule -ErrorAction SilentlyContinue)
{
    # If module exists, update it
    [string]$currentVersionADM = (Find-Module -Name $ARMDeployModule -Repository $PSModuleRepository).Version
    [string]$installedVersionADM = (Get-InstalledModule -Name $ARMDeployModule).Version
    If ($currentVersionADM -ne $installedVersionADM)
    {
            # Update modules if required
            Update-Module -Name $ARMDeployModule -Force -ErrorAction SilentlyContinue -Verbose
    } # end if
} # end if
# If the modules aren't already loaded, install and import it.
else
{
    Install-Module -Name $ARMDeployModule -Repository $PSModuleRepository -Force -Verbose
} #end If
Import-Module -Name $ARMDeployModule -Verbose
#endregion MODULES

#region Environment setup
# Use TLS 1.2 to support Nuget provider
Write-Output "Configuring security protocol to use TLS 1.2 for Nuget support when installing modules." -Verbose
[ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
#endregion

#region FUNCTIONS

function New-ARMDeployTranscript
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogDirectory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPrefix
    ) # end param

    # Get curent date and time
    $TimeStamp = (get-date -format u).Substring(0, 16)
    $TimeStamp = $TimeStamp.Replace(" ", "-")
    $TimeStamp = $TimeStamp.Replace(":", "")

    # Construct transcript file full path
    $TranscriptFile = "$LogPrefix-TRANSCRIPT" + "-" + $TimeStamp + ".log"
    $script:Transcript = Join-Path -Path $LogDirectory -ChildPath $TranscriptFile

    # Create log and transcript files
    New-Item -Path $Transcript -ItemType File -ErrorAction SilentlyContinue
} # end function

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
        If (Get-InstalledModule -Name $Module -ErrorAction SilentlyContinue)
        {
            # To avoid multiple versions of a module is installed on the same system, first uninstall any previously installed and loaded versions if they exist
            Update-Module -Name $Module -Force -ErrorAction SilentlyContinue -Verbose
        } #end if
		    # If the modules aren't already loaded, install and import it
		else
		{
			# https://www.powershellgallery.com/packages/WriteToLogs
			Install-Module -Name $Module -Repository $Repository -Force -ErrorAction SilentlyContinue -AllowClobber -Verbose
			Import-Module -Name $Module -ErrorAction SilentlyContinue -Verbose
		} #end If
	} #end foreach
} #end function

#endregion FUNCTIONS

#region TRANSCRIPT
[string]$Transcript = $null
$scriptName = $MyInvocation.MyCommand.name
# Use script filename without exension as a log prefix
$LogPrefix = $scriptName.Split(".")[0]
$modulePath = "$env:systemdrive\Program Files\WindowsPowerShell\Modules"

$LogDirectory = Join-Path $modulePath -ChildPath $LogPrefix -Verbose
# Create log directory if not already present
If (-not(Test-Path -Path $LogDirectory -ErrorAction SilentlyContinue))
{
    New-Item -Path $LogDirectory -ItemType Directory -Verbose
} # end if

# funciton: Create log files for transcript
New-ARMDeployTranscript -LogDirectory $LogDirectory -LogPrefix $LogPrefix -Verbose

Start-Transcript -Path $Transcript -IncludeInvocationHeader -Verbose
#endregion TRANSCRIPT

#region HEADER
$label = "AUTOCLOUDARC PROJECT 0026: DEPLOY AZURE AUTOMATION LAB"
$headerCharCount = 200
# function: Create new header
$header = New-ARMDeployHeader -label $label -charCount $headerCharCount -Verbose

Write-Output $header.SeparatorDouble  -Verbose
Write-Output $Header.Title  -Verbose
Write-Output $header.SeparatorSingle  -Verbose
#endregion HEADER

#region PATH
# Set script path
Write-Output "Changing path to script directory..." -Verbose
Set-Location -Path $PSScriptRoot -Verbose
Write-Output "Current directory has been changed to script root: $PSScriptRoot" -Verbose
#endregion PATH

[string]$proceed = $null
Write-Output ""
$proceed = Read-Host -Prompt @"
The AzureRM modules will be removed and replaced with the Az modules.
For details and instructions why and how to upgrade to the Az modules, see https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-3.3.0.
OK to proceed ['Y' or 'YES' to continue | 'N' or 'NO' to exit]?
"@
if ($proceed -eq "N" -OR $proceed -eq "NO")
{
    Write-Output "Deployment terminated by user. Exiting..."
    PAUSE
    EXIT
} #end if ne Y
elseif ($proceed -eq "Y" -OR $proceed -eq "YES")
{
[string]$azurePreferredModule = "Az"
[string]$azureNonPreferredModule = "AzureRM"
# https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.1.0
Remove-ARMDeployPSModule -ModuleToRemove $azureNonPreferredModule -Verbose
# Get required PowerShellGallery.com modules.
Get-ARMDeployPSModule -ModulesToInstall $azurePreferredModule -PSRepository $PSModuleRepository -Verbose

#region AUTHENTICATE-TO-AZURE
Write-Output "Your browser authentication prompt for your subscription may be opened in the background. Please resize this window to see it and log in."
# Clear any possible cached credentials for other subscriptions
Clear-AzContext
Connect-AzAccount -Environment AzureCloud -Verbose
#endregion

Do
{
    (Get-AzSubscription).Name
	[string]$Subscription = Read-Host "Please enter your subscription name, i.e. [MySubscriptionName] "
	$Subscription = $Subscription.ToUpper()
} #end Do
Until ($Subscription -in (Get-AzSubscription).Name)
Select-AzSubscription -SubscriptionName $Subscription -Verbose

Do
{
    # Student number
    [int]$studentNumber = Read-Host "Please enter your student number, which must be a number from [10-26]. NOTE: Your resource group name will be rg##, where ## represents the number you entered."
} #end Do
Until (($studentNumber -is [int]) -and ($studentNumber -match '\d{2}') -and ([int]$studentNumber -ge 10) -and ([int]$studentNumber -le 26))

# Resource Group name
[string]$rg = "rg" + [int]$studentNumber

Do
{
    # The location refers to a geographic region of an Az data center
    $regions = Get-AzLocation | Select-Object -ExpandProperty Location
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

New-AzResourceGroup -Name $rg -Location $region -Verbose
$adminUserName = "adm.infra.user"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName"
$adminPassword = $adminCred.GetNetworkCredential().password

# Ensure that the storage account name is globally unique in DNS
$studentRandomInfix = (New-Guid).Guid.Replace("-","").Substring(0,8)

$parameters = @{}
$parameters.Add("_artifactsLocation",$artifactsLocation)
$parameters.Add("studentNumber",$studentNumber)
$parameters.Add("adminUserName",$adminUserName)
$parameters.Add("adminPassword",$adminPassword)
$parameters.Add("studentRandomInfix",$studentRandomInfix)
$parameters.Add("excludeWeb",$excludeWeb)
$parameters.Add("excludeSql",$excludeSql)
$parameters.Add("excludeAds",$excludeAds)
$parameters.Add("excludePki",$excludePki)
$parameters.Add("includeCentOS",$includeCentOS)

$rgDeployment = 'azuredeploy-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateUri $templateUri `
-Name $rgDeployment `
-TemplateParameterObject $parameters `
-Force -Verbose `
-ErrorVariable ErrorMessages

$jumpDevMachine = "AZRDEV" + $studentNumber + "01"
$fqdnDev = (Get-AzPublicIpAddress -ResourceGroupName $rg | Where-Object { $_.Name -like 'azrdev*pip*'}).DnsSettings.fqdn

if ($ErrorMessages)
{
    Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
}
else
{
    #region Availability Sets

    # Construct availability sets array
    Write-Output "Cleaning up unused availability sets."
    Write-Output "Retrieving list of availability sets."
    $avSets = Get-AzAvailabilitySet -ResourceGroupName $rg
    foreach ($avSet in $avSets)
    {
        if ($avSet.VirtualMachinesReferences.Id.Count -eq 0)
        {
            # Cleanup availability sets that aren't assined to any virtual machines
            Write-Output "Removing availability set that is not associated with any virtual machines."
            Remove-AzAvailabilitySet -ResourceGroupName $rg -Name $avSet.Name -Force -Verbose
        } # end if
    } # end foreach
    #endregion

    #region NetworkInterfaces
    Write-Output "Cleaning up unused NICs."
    Write-Output "Retrieving list of NICs."
    $nicList = (Get-AzNetworkInterface -ResourceGroupName $rg)
    foreach ($nic in $nicList)
    {
        # Remove NIC if it isn't attached to a virtual machine
        if ($null -eq $nic.VirtualMachine.Id)
        {
            Write-Output "Removing network interface that is not associated with a virtual machine."
            Remove-AzNetworkInterface -ResourceGroupName $rg -Name $nic.Name -Force -Verbose -PassThru
        } # end if
    } # end foreach
    #endregion

    #region Add bastion host
    Write-Output "Adding bastion subnet."
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $rg
    $vnetName = $vnet.Name
    $vnetAddrTwoOctetPrefix = "10.20."
    $nsgPrefix = "NSG-"
    $basSubName = "AzureBastionSubnet"
    $nsgBasName = $nsgPrefix + $basSubName
    $basSubSuffix = ".32/27"
    $basSubPrefix = $vnetAddrTwoOctetPrefix + $studentNumber + $basSubSuffix
    $basSubnet = New-AzVirtualNetworkSubnetConfig -Name $basSubName -AddressPrefix $basSubPrefix
    Add-AzVirtualNetworkSubnetConfig -Name $basSubName -VirtualNetwork $vnet -AddressPrefix $basSubPrefix -Verbose
    $vnet | Set-AzVirtualNetwork -Verbose
    $vnetId = $vnet.id
    # refresh VNET info
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $rg
    $basSubnetId = $vnet.Subnets.id | Where-Object {$_ -match 'AzureBastionSubnet'}

    # Create public IP address for bastion
    Write-Output "Creating bastion public IP address resource."
    $basName = "azr-dev-bas-$studentRandomInfix-01"
    $basPubIpName = $basName + "-pip"
    $alloc = "Static"
    $basPubIp = New-AzPublicIpAddress -ResourceGroupName $rg -name $basPubIpName -location $region -AllocationMethod $alloc -Sku Standard
    $basPubIpId = $basPubIp.id
    $basPubIpAddress = $basPubIp.IpAddress
    $basPubIpAddressCidr = $basPubIpAddress + "/32"

    # Create NSG for bastion subnet
    # https://docs.microsoft.com/en-us/azure/bastion/bastion-nsg

    # INGRESS
    # Ingress traffic from public Internet
    $basNsgRule443FromInternetRuleName = "Allow443FromInternet"
    $basNsgRule443FromInternet = New-AzNetworkSecurityRuleConfig -Name $basNsgRule443FromInternetRuleName `
    -Description  $basNsgRule443FromInternetRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 443
    # Ingress traffic tfrom Azure Bastion control pane
    $basNsgRule443FromGatewayManagerRuleName = "Allow443FromGatewayManager"
    $basNsgRule443FromGatewayManager = New-AzNetworkSecurityRuleConfig -Name $basNsgRule443FromGatewayManagerRuleName `
    -Description  $basNsgRule443FromGatewayManagerRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix GatewayManager `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 443,4443

    # EGRESS
    # To AzureCloud
    $allowAzureServicesRuleName = "AllowAzureServices"
    $allowAzureServices = New-AzNetworkSecurityRuleConfig -Name $allowAzureServicesRuleName `
    -Description  "AllowAzureServices" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Outbound `
    -Priority 120 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix AzureCloud `
    -DestinationPortRange 443
    # To VirtualNetwork
    $allowRemoteToVirtualNetworkRuleName = "AllowRemoteToVirtualNetwork"
    $allowRemoteToVirtualNetwork = New-AzNetworkSecurityRuleConfig -Name $allowRemoteToVirtualNetworkRuleName `
    -Description  $allowRemoteToVirtualNetworkRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Outbound `
    -Priority 130 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 3389,22

    # Create NSG
    $basNsg = New-AzNetworkSecurityGroup -Name $nsgBasName -ResourceGroupName $rg -Location $region -SecurityRules $basNsgRule443FromInternet,$basNsgRule443FromGatewayManager,$allowRemoteToVirtualNetwork,$allowAzureServices -Verbose

    # Associate NSG to AzureBastionSubnet subnet
    New-ARMDeployAssociateSubnetToNsg -resGroupName $rg -vnetName $vnet.name -nsgName $nsgBasName -subnetName $basSubName -subnetRange $basSubPrefix -Verbose

    # Add new rule NSG-ADDS
    $allowRemoteFromBastionRuleName = "AllowRemoteFromBastion"
    $nsgAddsName = "NSG-ADDS" + $studentNumber
    $subAddsName = $vnet.subnets.name | Where-Object {$_ -match 'ADDS'}
    $subAddsPrefix = $vnet.subnets.addressPrefix | Where-Object {$_ -match '.0/28'}

    Get-AzNetworkSecurityGroup -Name $nsgAddsName -ResourceGroupName $rg |
    Add-AzNetworkSecurityRuleConfig -Name $allowRemoteFromBastionRuleName `
    -Description  $allowRemoteFromBastionRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix $basSubPrefix `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 3389,22 |
    Set-AzNetworkSecurityGroup

    # Associate NSG to ADDS subnet
    New-ARMDeployAssociateSubnetToNsg -resGroupName $rg -vnetName $vnet.name -nsgName $nsgAddsName -subnetName $subAddsName -subnetRange $subAddsPrefix -Verbose

    # Add new rule to NSG-SRVS
    $nsgSrvsName = "NSG-SRVS" + $studentNumber
    $subSrvsName = $vnet.subnets.name | Where-Object {$_ -match 'SRVS'}
    $subSrvsPrefix = $vnet.subnets.addressPrefix | Where-Object {$_ -match '.16/28'}
    Get-AzNetworkSecurityGroup -Name $nsgSrvsName -ResourceGroupName $rg |
    Add-AzNetworkSecurityRuleConfig -Name $allowRemoteFromBastionRuleName `
    -Description  $allowRemoteFromBastionRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix $basSubPrefix `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 3389,22 |
    Set-AzNetworkSecurityGroup

    # Associate NSG to SRVS subnet
    New-ARMDeployAssociateSubnetToNsg -resGroupName $rg -vnetName $vnet.name -nsgName $nsgSrvsName -subnetName $subSrvsName -subnetRange $subSrvsPrefix -Verbose

    $basParams = @{}
    $basParams.Add("location",$region)
    $basParams.Add("basPubIpId",$basPubIpId)
    $basParams.Add("basSubnetId", $basSubnetId)
    $basParams.Add("basName",$basName)

    $rgBasDeployment = 'azBasDeploy-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')

    New-AzResourceGroupDeployment -ResourceGroupName $rg `
    -TemplateUri $bastionUri `
    -Name $rgBasDeployment `
    -TemplateParameterObject $basParams `
    -Force -Verbose `
    -ErrorVariable basErrorMessages

    if ($basErrorMessages)
    {
        Write-Output '', 'Template deployment returned the following errors:', @(@($basErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    } # end if

    $fqdnUpnSuffix = "@dev.adatum.com"
    $adminUserName = $adminUserName + $fqdnUpnSuffix

    # Check if bastion host deployed properly
    $isBastionNsgAssociated = (Get-AzVirtualNetwork -ResourceGroupName $rg -Verbose).Subnets.NetworkSecurityGroup.Id | Split-Path -leaf | Where-Object {$_ -match 'AzureBastionSubnet'}
    $isBastionHostProvisioned = (Get-AzResource -ResourceGroupName $rg -ResourceType 'Microsoft.Network/bastionHosts')

    if ($isBastionNsgAssociated -and $isBastionHostProvisioned)
    {
        #region REMOVE Jump/Dev server public IP
        # Disconnect jump server public IP
        # https://docs.microsoft.com/en-us/azure/virtual-network/remove-public-ip-address-vm
        # Disassociate public IP from NIC
        $azrDevNic = Get-AzNetworkInterface -Name *azrdev* -ResourceGroup $rg
        $azrDevNic.IpConfigurations.publicipaddress.id = $null
        Set-AzNetworkInterface -NetworkInterface $azrDevNic -Verbose
        # Remove Public IP
        $azrDevPipName = (Get-AzPublicIpAddress -ResourceGroupName $rg | Where-Object {$_.Name -like 'azrdev*pip*'}).Name
        Remove-AzPublicIpAddress -Name $azrDevPipName -ResourceGroupName $rg -PassThru -Force -Verbose

        # Remove RDP NSG rules
        # Get NSGs with RDP inbound from internet
        $ruleToRemove = "AllowRdpInbound"
        $allowRdpInbound = (Get-AzNetworkSecurityGroup -ResourceGroupName $rg | Where-Object {($_.SecurityRules.Name -eq $ruleToRemove) -and ($_.SecurityRules.DestinationPortRange -eq '3389')}).Name
        $allowRdpInbound | ForEach-Object {Get-AzNetworkSecurityGroup -Name $_ | Remove-AzNetworkSecurityRuleConfig -Name $ruleToRemove -Verbose}
        # Provide Bastion connection message

$connectionMessage = @"
To log into your any of your lab virtual machines, use Azure bastion by logging into the portal at https://portal.azure.com, select the virtual machine, and click connect in the overview pane, then select the 'bastion' option
and login with your credentials.

The user name is: $adminUserName and specify the corresponding password you entered at the begining of this script.
You can now use this lab to practice Windows PowerShell, Windows Desired State Configuration (push/pull), PowerShell core, Linux Desired State Configuration, Azure Automation and Azure Automation DSC tasks to develop these skills.
For more details on what types of excercises you can practice, see the readme.md file in this GitHub repository at: https://github.com/autocloudarc/0026-azure-automation-plus-dsc-lab.
If you like this script, follow me on GitHub at https://github.com/autocloudarc, send feedback or submit issues so we can build a better experience for everyone.
Happy scripting...
"@
        Write-Output $connectionMessage
        #endregion
    }
    else
    {
        $connectionMessage = @"
Your RDP connection prompt will open auotmatically after you read this message and press Enter to continue...

To log into your new automation lab jump server $jumpDevMachine, you must change your login name to: $adminUserName and specify the corresponding password you entered at the begining of this script.
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
    } # end else

<#
    $devServer = "azrdev" + $studentNumber + "01"
    $devServerNicName = $devServer + "-nic"

    Write-Output "Disassociating public IP address from jump/dev server $devServer"
    $devServerNicResource = Get-AzNetworkInterface -Name $devServerNicName -ResourceGroupName $rg
    $devServerNicResource.IpConfigurations.publicipaddress.id = $null
    Set-AzNetworkInterface -NetworkInterface $devServerNicResource -Verbose
    $devServerPipName = $devServer + "-pip" + $studentRandomInfix
    Write-Output "Now that the bastion host is provisioned, removing public IP address: $devServerPipName"
    Remove-AzPublicIpAddress -Name $devServerPipName -ResourceGroupName $rg -Force -Verbose -PassThru
#>
} # end else

# $basResource = New-AzBastion -ResourceGroupName $rg -Name $basName -PublicIpAddressId $basPubIpId -VirtualNetwork $vnet -Verbose
<#
TASK-ITEM: See: https://github.com/MicrosoftDocs/azure-docs/issues/56580
TASK-ITEM: As a workaround in the meantime, we are deploying bastion resource using ARM template.
New-AzBastion : Cannot parse the request.
StatusCode: 400
ReasonPhrase: Bad Request
ErrorCode: InvalidRequestFormat
ErrorMessage: Cannot parse the request.
Additional details:
    Code: MissingJsonReferenceId
    Message: Value for reference id is missing. Path properties.ipConfigurations[0].properties.subnet.
OperationID : 82269f80-339f-48e4-a3fa-972b977d30a1
At C:\OneDrivePersonal\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\Deploy-AzureResourceGroup.ps1:550 char:16
+ ... sResource = New-AzBastion -ResourceGroupName $rg -Name $basName -Publ ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : CloseError: (:) [New-AzBastion], NetworkCloudException
    + FullyQualifiedErrorId : Microsoft.Azure.Commands.Network.Bastion.NewAzBastionCommand
#>

$StopTimer = Get-Date -Verbose
Write-Output "Calculating elapsed time..."
$ExecutionTime = New-TimeSpan -Start $BeginTimer -End $StopTimer
$Footer = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTime"
Write-Output ""
Write-Output $Footer

} # end else if

# Resource group and log files cleanup messages
$labResourceGroupFilter = "rg??"
Write-Warning "The list of PoC resource groups are:"
Get-AzResourceGroup -Name $labResourceGroupFilter -Verbose
Write-Output ""
Write-Warning "To remove the resource groups, use the command below:"
Write-Warning 'Get-AzResourceGroup -Name <YourResourceGroupName> | ForEach-Object { Remove-AzResourceGroup -ResourceGroupName $_.ResourceGroupName -Verbose -Force }'

Write-Warning "Transcript logs are hosted in the directory: $LogDirectory to allow access for multiple users on this machine for diagnostic or auditing purposes."
Write-Warning "To examine, archive or remove old log files to recover storage space, run this command to open the log files location: Start-Process -FilePath $LogDirectory"
Write-Warning "You may change the value of the `$modulePath variable in this script, currently at: $modulePath to a common file server hosted share if you prefer, i.e. \\<server.domain.com>\<share>\<log-directory>"

Stop-Transcript -Verbose

#region OPEN-TRANSCRIPT
# Create prompt and response objects for continuing script and opening logs.
$openTranscriptPrompt = "Would you like to open the transcript log now ? [YES/NO]"
Do
{
    $openTranscriptResponse = read-host $openTranscriptPrompt
    $openTranscriptResponse = $openTranscriptResponse.ToUpper()
} # end do
Until ($openTranscriptResponse -eq "Y" -OR $openTranscriptResponse -eq "YES" -OR $openTranscriptResponse -eq "N" -OR $openTranscriptResponse -eq "NO")

# Exit if user does not want to continue
If ($openTranscriptResponse -in 'Y', 'YES')
{
    Start-Process -FilePath notepad.exe $Transcript -Verbose
} #end condition
else
{
    # Terminate script
    Write-Output "End of Script!"
    $header.SeparatorDouble
} # end else
#endregion