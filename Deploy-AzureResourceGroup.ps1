#requires -version 5.0
#requires -RunAsAdministrator
<#
.SYNOPSIS
   	Creates up to 6 VMs for an Azure Linux Windows PowerShell Lab consisting of 1-3 Windows VMs, and 3 Linux VMs (Ubuntu, CentOS and openSUSE).
.DESCRIPTION
	This script will create a set of Azure VMs to demonstrate Windows PowerShell and Azure Automation DSC functionality on Linux VMs. The set of VMs that will be created are listed below in the .OUTPUTS help tag.
    however the number of Windows VMs is user specified from 1-3, since the deployment of Windows VMs are not essential for a basic demonstration of PowerShell on Linux, but will be required if Windows Push or Pull
    servers will be used in the lab. This project will be enhaced to eventually include those features also, but initially, the focus will be on configuring the Linux distros to support Azure Automation DSC and
    PowerShell.
    The VM resources deployed are:
    1) 3 x Windows Server 2016
2) 1 x UbuntuServer LTS 16.04
3) 1 x CentOS 7.3
4) 1 x openSUSE-Leap 42.2

.EXAMPLE
   	.\New-PowerShellOnLinuxLab -WindowsInstanceCount 2
.PARAMETERS
    WindowsInstanceCount: The number of Windows Server 2016 Datacenter VMs that will be deployed.
.OUTPUTS
    1) 1-4 x Windows Server 2016
    2) 1 x UbuntuServer LTS 16.04
    3) 1 x CentOS 7.3
    4) 1 x openSUSE-Leap 42.2
.NOTES
   	CURRENT STATUS: Released
    REQUIREMENTS:
    1. A Windows Azure subscription
    2. Windows OS (Windows 7/Windows Server 2008 R2 or greater)
    2. Windows Management Foundation (WMF 5.0 or greater installed to support PowerShell 5.0 or higher version)
    3. SSH key pair to authenticate to the Linux VMs. When the script executes, a prompt will appear asking for the public key path.

   	LIMITATIONS	: Windows VM configurations and integration as Push/Pull servers.
   	AUTHOR(S)  	: Preston K. Parsard; https://github.com/autocloudarc
   	EDITOR(S)  	: Preston K. Parsard; https://github.com/autocloudarc
   	KEYWORDS   	: Linux, Azure, PowerShell, DSC

	REFERENCES :
    1. https://gallery.technet.microsoft.com/scriptcenter/Build-AD-Forest-in-Windows-3118c100
    2. http://blogs.technet.com/b/heyscriptingguy/archive/2013/06/22/weekend-scripter-getting-started-with-windows-azure-and-powershell.aspx
    3. http://michaelwasham.com/windows-azure-powershell-reference-guide/configuring-disks-endpoints-vms-powershell/
    4. http://blog.powershell.no/2010/03/04/enable-and-configure-windows-powershell-remoting-using-group-policy/
    5. http://azure.microsoft.com/blog/2014/05/13/deploying-antimalware-solutions-on-azure-virtual-machines/
    6. http://blogs.msdn.com/b/powershell/archive/2014/08/07/introducing-the-azure-powershell-dsc-desired-state-configuration-extension.aspx
    7. http://trevorsullivan.net/2014/08/21/use-powershell-dsc-to-install-dsc-resources/
    8. http://blogs.msdn.com/b/powershell/archive/2014/07/21/creating-a-secure-environment-using-powershell-desired-state-configuration.aspx
    9. http://blogs.technet.com/b/ashleymcglone/archive/2015/03/20/deploy-active-directory-with-powershell-dsc-a-k-a-dsc-promo.aspx
    10.http://blogs.technet.com/b/heyscriptingguy/archive/2013/03/26/decrypt-powershell-secure-string-password.aspx
    11.http://blogs.msdn.com/b/powershell/archive/2014/09/10/secure-credentials-in-the-azure-powershell-desired-state-configuration-dsc-extension.aspx
    12.http://blogs.technet.com/b/keithmayer/archive/2014/10/24/end-to-end-iaas-workload-provisioning-in-the-cloud-with-azure-automation-and-powershell-dsc-part-1.aspx
    13.http://blogs.technet.com/b/keithmayer/archive/2014/07/24/step-by-step-auto-provision-a-new-active-directory-domain-in-the-azure-cloud-using-the-vm-agent-custom-script-extension.aspx
    14.https://blogs.msdn.microsoft.com/cloud_solution_architect/2015/05/05/creating-azure-vms-with-arm-powershell-cmdlets/
    15.https://msdn.microsoft.com/en-us/powershell/gallery/psget/script/psget_new-scriptfileinfo
    16.https://msdn.microsoft.com/en-us/powershell/gallery/psget/script/psget_publish-script
    17.https://www.powershellgallery.com/packages/WriteToLogs
    18.https://chocolatey.org
    19.https://desktop.github.com
    20.https://www.ostechnix.com/how-to-install-windows-powershell-in-linux/
    21.https://blogs.technet.microsoft.com/heyscriptingguy/2016/10/05/part-2-install-net-core-and-powershell-on-linux-using-dsc/
    22.https://blogs.technet.microsoft.com/heyscriptingguy/2016/09/28/part-1-install-bash-on-windows-10-omi-cim-server-and-dsc-for-linux/
    23.https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-vm
    24.https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md
    25.https://www.ostechnix.com/how-to-install-windows-powershell-in-linux/
    26.https://blogs.technet.microsoft.com/heyscriptingguy/2016/09/28/part-1-install-bash-on-windows-10-omi-cim-server-and-dsc-for-linux/
    27.https://blogs.technet.microsoft.com/heyscriptingguy/2016/10/05/part-2-install-net-core-and-powershell-on-linux-using-dsc/
    28.https://blogs.msdn.microsoft.com/linuxonazure/2017/02/12/extensions-custom-script-for-linux/
    29.https://azure.microsoft.com/en-us/blog/automate-linux-vm-customization-tasks-using-customscript-extension/
    30.https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows
    31.https://docs.microsoft.com/en-us/powershell/wmf/readme

    The MIT License (MIT)
    Copyright (c) 2017 Preston K. Parsard

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

    Posh-SSH
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

.COMPONENT
    Azure IaaS
.ROLE
    Azure IaaS Windows/Linux Administrators/Engineers
.FUNCTIONALITY
    Deploys Azure Linux VMs with PowerShell and DSC functionality.
.LINK
    https://github.com/autocloudarc/0008-New-PowerShellOnLinuxLab
    https://www.powershellgallery.com/packages/WriteToLogs
    https://www.powershellgallery.com/packages/nx
    https://www.powershellgallery.com/packages/Posh-SSH
    https://raw.githubusercontent.com/MSAdministrator/GetGithubRepository/master/Get-GithubRepository.ps1
    http://technodrone.blogspot.com/2010/04/those-annoying-thing-in-powershell.html
    https://www.ostechnix.com/how-to-install-windows-powershell-in-linux/
#>

# Connect to Azure
# Connect-AzureRmAccount
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