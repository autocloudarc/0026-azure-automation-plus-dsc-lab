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
# TASK-ITEM: Use actual SQL 2019 Server images

.PARAMETER excludeAds
Exclude the two additional domain controllers that will just be provisioned initially as member servers to reduce total deployment cost and deployment time.

.PARAMETER excludePki
Exclude the PKI server from this deployment.

.PARAMETER includeCentos
Include a CentOS server for this deployment.

.PARAMETER includeUbuntu
Inclue an Ubuntu server for this deployment.

.EXAMPLE
.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -excludePki yes -additionalLnx yes -Verbose

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
    [string]$includeUbuntu = "no"
    #>
) # end param

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
$modulePath = (Get-InstalledModule -Name Az).InstalledLocation | Split-Path -Parent | Split-Path -Parent

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
    [int]$studentNumber = Read-Host "Please enter your student number, which must be a number from [1-16], or hit RETURN to select [1]. NOTE: Your resource group name will be rg##, where ## represents the number you entered."
} #end Do
Until (($studentNumber -is [int]) -and ($studentNumber -match '\d{2}') -and ([int]$studentNumber -ge 1) -and ([int]$studentNumber -le 16))

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

# TASK-ITEM: master branch uir. Uncomment before release.
# $templateUri = 'https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/master/azuredeploy.json'
# TASK-ITEM: dev branch uri. Comment before release.
$templateUri = 'https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/dev/azuredeploy.json'
# TASK-ITEM: dev branch uri. Comment before release. This is for testing in the dev branch only, otherwise the default value of the parameter in the parameters file will be used.
$artifactsLocation = 'https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/dev/'
$adminUserName = "adm.infra.user"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName"
$adminPassword = $adminCred.GetNetworkCredential().password

# Ensure that the storage account name is globally unique in DNS
$studentRandomInfix = (New-Guid).Guid.Replace("-","").Substring(0,8)

# Create public IP address for bastion
Write-Output "Creating bastion public IP address resource."
$basName = "azr-dev-bas-$studentRandomInfix-01"
$basPubIpName = $basName + "-pip"
$alloc = "Static"
$basPubIp = New-AzPublicIpAddress -ResourceGroupName $rg -name $basPubIpName -location $region -AllocationMethod $alloc -Sku Standard
$basPubIpId = $basPubIp.id
$basPubIpAddress = $basPubIp.IpAddress
$basPubIpAddressCidr = $basPubIpAddress + "/32"

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
$parameters.Add("includeUbuntu",$includeUbuntu)
$parameters.Add("basPubIpId",$basPubIpId)
$parameters.Add("basName",$basName)
$parameters.Add("basPubIpAddressCidr",$basPubIpAddressCidr)

$rgDeployment = 'azuredeploy-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')
New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateUri $templateUri `
-Name $rgDeployment `
-TemplateParameterObject $parameters `
-Force -Verbose `
-ErrorVariable ErrorMessages

# TASK-ITEM: Remove jump server public IP address after Azure Bastion is fully implemented.
$jumpDevMachine = "AZRDEV" + $studentNumber + "01"
$fqdnDev = (Get-AzPublicIpAddress -ResourceGroupName $rg | Where-Object { $_.Name -like 'azrdev*pip*'}).DnsSettings.fqdn

if ($ErrorMessages)
{
    Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
}
else
{
    $StopTimer = Get-Date -Verbose
    Write-Output "Calculating elapsed time..."
    $ExecutionTime = New-TimeSpan -Start $BeginTimer -End $StopTimer
    $Footer = "TOTAL SCRIPT EXECUTION TIME: $ExecutionTime"
    Write-Output ""
    Write-Output $Footer
    $fqdnUpnSuffix = "@dev.adatum.com"
    $adminUserName = $adminUserName + $fqdnUpnSuffix

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
    <#
    TASK-ITEM: Reserved for future use.
    if ($includeBastion -eq "yes")
    {
        Write-Output "Adding bastion subnet."
        $vnetName = "AdatumDev-VNET" + $studentNumber
        $vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName
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
        $basSubnetId = $vnet.SubnetsText[2].id

        # Create NSG for bastion subnet
        # https://docs.microsoft.com/en-us/azure/bastion/bastion-nsg

        # INGRESS
        # Ingress traffic from public Internet
        $basNsgRule443FromInternet = New-AzNetworkSecurityRuleConfig -Name $nsgBasName `
        -Description  "Allow443FromInternet" `
        -Access Allow `
        -Protocol Tcp `
        -Direction Inbound `
        -Priority 100 `
        -SourceAddressPrefix Internet `
        -SourcePortRange * `
        -DestinationAddressPrefix $basPubIpAddressCidr `
        -DestinationPortRange 443
        # Ingress traffic tfrom Azure Bastion control pane
        $basNsgRule443FromGatewayManager = New-AzNetworkSecurityRuleConfig -Name $nsgBasName `
        -Description  "Allow443FromGatewayManager" `
        -Access Allow `
        -Protocol Tcp `
        -Direction Inbound `
        -Priority 110 `
        -SourceAddressPrefix GatewayManager `
        -SourcePortRange * `
        -DestinationAddressPrefix $basPubIpAddressCidr `
        -DestinationPortRange 443

        # EGRESS
        # To VirtualNetwork
        $basNsgRule443FromGatewayManager = New-AzNetworkSecurityRuleConfig -Name $nsgBasName `
        -Description  "AllowRemoteToVirtualNetwork" `
        -Access Allow `
        -Protocol Tcp `
        -Direction Outbound `
        -Priority 120 `
        -SourceAddressPrefix $basPubIpAddressCidr `
        -SourcePortRange * `
        -DestinationAddressPrefix VirtualNetwork `
        -DestinationPortRange 3389,22
        # To AzureCloud
        $basNsgRule443FromGatewayManager = New-AzNetworkSecurityRuleConfig -Name $nsgBasName `
        -Description  "AllowAzureServices" `
        -Access Allow `
        -Protocol Tcp `
        -Direction Outbound `
        -Priority 130 `
        -SourceAddressPrefix $basPubIpAddressCidr `
        -SourcePortRange * `
        -DestinationAddressPrefix AzureCloud `
        -DestinationPortRange 443

        # Create NSG
        $basNsg = New-AzNetworkSecurityGroup -Name $rg -Location $region -Verbose

        # Associate NSG to AzureBastionSubnet subnet
        $basSubnet.NetworkSecurityGroup = $basNsg
        $vnet | Set-AzVirtualNetwork -Verbose

        $basResource = New-AzBastion -ResourceGroupName $rg -Name $basName -PublicIpAddress $basPubIp -VirtualNetwork $vnet -Verbose
        <#
            TASK-ITEM:
            New-AzBastion : Cannot parse the request.
            StatusCode: 400
            ReasonPhrase: Bad Request
            ErrorCode: InvalidRequestFormat
            ErrorMessage: Cannot parse the request.
            Additional details:
                Code: MissingJsonReferenceId
                Message: Value for reference id is missing. Path properties.ipConfigurations[0].properties.subnet.
            OperationID :
            At line:1 char:16
            + ... sResource = New-AzBastion -ResourceGroupName $rg -Name $basName -Publ ...
            +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                + CategoryInfo          : CloseError: (:) [New-AzBastion], NetworkCloudException
                + FullyQualifiedErrorId : Microsoft.Azure.Commands.Network.Bastion.NewAzBastionCommand
    #>

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