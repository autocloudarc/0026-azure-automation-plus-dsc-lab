#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Configure a domain controller using push DSC and an external configuration data file

.DESCRIPTION
This script includes a DSC configuration to build an additional domain controller for an existing domain. 

.PARAMETER domainAdminCred
Domain administrator username and password.

.EXAMPLE
Complile configuration
adsCnfgInstallPushAds01 -OutputPath $devMofPath -domainAdminCred $domainAdminCred -ConfigurationData $ConfigDataPath

# Configure target LCM
Set-DscLocalConfigurationManager -Path $devMofPath -ComputerName $targetNode -Verbose -Force

# Apply configuration to target
Start-DscConfiguration -Path $devMofPath -ComputerName $targetNode -Wait -Verbose -Force

.NOTES
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

.LINK
1. Create a replica DC using DSC: https://blog.kloud.com.au/2016/09/20/create-a-replica-domain-controller-using-desired-state-configuration/
2. Getting Started with PowerShell DSC: Securing domainAdminCreds in MOF Files | packtpub.com: https://youtu.be/2nsCQ32Ufx0 

.COMPONENT
Windows PowerShell Desired State Configuration, ActiveDirectory

.ROLE
Systems Engineer
DevOps Engineer
Active Directory Engineer

.FUNCTIONALITY
Configures a member server as a new domain controler in an existing domain.
#>

# https://blog.kloud.com.au/2016/09/20/create-a-replica-domain-controller-using-desired-state-configuration/
#region Configuration
Configuration adsCnfgInstallPushAds
{
	Param
	(
		[Parameter(Mandatory=$true)]
        [PSCredential]$domainAdminCred
        #>
	) # end param
    
    # Convert domainAdminCreds to netbios domainAdminCred format [NETBIOSdomainname\username]
    $domainUserUpn = $credenital.UserName

    Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xStorage, xPendingReboot

	$dcFeaturesToAdd = @(
		$rsatDnsServer = @{
			Ensure = "Present";
			Name = "RSAT-DNS-Server"
		} # end hashtable
		$rsatAdCenter = @{
			Ensure = "Present";
			Name = "RSAT-AD-AdminCenter"
		} # end hashtable
		$rsatADDS = @{
			Ensure = "Present";
			Name = "RSAT-ADDS"
		} # end hashatable
		$rsatAdPowerShell = @{
			Ensure = "Present";
			Name = "RSAT-AD-PowerShell"
		} # end hashtable
		$rsatAdTools = @{
			Ensure = "Present";
			Name = "RSAT-AD-Tools"
		} # end hashatale
		$rsatGPMC = @{
			Ensure = "Present";
			Name = "GPMC"
		} # end hashtable
	) # end array

	Node $AllNodes.NodeName
	{
  		LocalConfigurationManager
		{
			ConfigurationMode = 'ApplyAndAutoCorrect'
			RebootNodeIfNeeded = $true
			ActionAfterReboot = 'ContinueConfiguration'
			AllowModuleOverwrite = $true
		} # end LCM

		ForEach ($dcFeature in $dcFeaturesToAdd)
		{
			WindowsFeature "$($dcFeature.Name)"
				{
					Ensure = "$($dcFeature.Present)"
					Name = "$($dcFeature.Name)"
				} # end resource
		} # end foreach

		WindowsFeature "AD-Domain-Services"
		{
			Ensure = "Present";
			Name = "AD-Domain-Services"
		} # end hashtable

		WindowsFeature "RSAT-Role-Tools"
		{
			Ensure = "Present";
			Name = "RSAT-Role-Tools"
		} # end hashtable

		xWaitForDisk Disk2
		{
			DiskId = $node.dataDiskNumber
			RetryCount = $Node.RetryCount
			RetryIntervalSec = $Node.RetryIntervalSec
			DependsOn = "[WindowsFeature]RSAT-Role-Tools"
		} # end resource

		xDisk ConfigureDataDisk
		{
			DiskId = $node.dataDiskNumber
			DriveLetter = $node.dataDiskDriveLetter
            FSFormat = $node.FSFormat
            FSLabel = $node.FSLabel
			DependsOn = "[xWaitforDisk]Disk2"
		} # end resource

		
        xWaitForADDomain ForestWait
        {
            DomainName = $node.fqdn
            domainUserCredential = $domainAdminCred
            RetryCount = $node.RetryCount
            RetryIntervalSec = 300
        } # end resource

        xADDomainController NewReplicaDC
		{
			DomainName = $node.fqdn
			DomainAdministratorCredential = $domainAdminCred
			SafemodeAdministratorPassword = $domainAdminCred
			DatabasePath = $node.dataDiskDriveLetter + $node.ntdsPathSuffix
			LogPath = $node.dataDiskDriveLetter + $node.logsPathSuffix
			SysvolPath = $node.dataDiskDriveLetter + $node.sysvPathSuffix
			DependsOn = "[xWaitForADDomain]ForestWait"
		} # end resource

        xPendingReboot Reboot1
        { 
           Name = "RebootServer"
           DependsOn = "[xADDomainController]NewReplicaDC"
        } # end resource
	} # end node
} # end configuration
#endregion

#region Intialize values
# Set MOF path
$devMofPath = "f:\dsc\mof"
# Set ConfigData path
$ConfigDataPath = "F:\dsc\configdata\adsDataInstallPushAds02.psd1"
<#
TASK-ITEM: Turn on print and file sharing (SMB-in) in group policies for target nodes using GROUP POLICY advanced firewall settings
Scope: Computer node
Group: File and Print Sharing
Direction: Inbound
1. Echo Request - ICMPv4-In
2. Echo Request - ICMPv6-In
3. LLMNR-UDP-In
4. SMB-In
#>
# Select target node to configure by looking for the 01 series DC patter for dev.adatum.com the .. represents a 2 digit number that can vary by deployments
$targetNode = (Get-ADComputer -Filter *).DNSHostName | Where-Object {$_ -match 'AZRADS..02'}
# Get list of resources required for this configuration so that can be copied to the target node
$dscResourceList = @("xActiveDirectory", "xComputerManagement", "xStorage", "xPendingReboot")
# Create a session to prepare the target node, i.e Install pre-requisite features 
$targetNodeSession = New-PSSession -Name $targetNode
# Obtain local source and remote destination resource modules paths to copy resources to target node
$resourceModulePath = $env:PSModulePath -split ";" | Where-Object {$_ -match 'C:\\Program Files\\WindowsPowerShell'}
$targetModulePaths = (Get-ChildItem -Path $resourceModulePath -Directory | Where-Object {$_.Name -in $dscResourceList}).FullName
$uncTargetPath = $resourceModulePath.Replace('C:\',"\\$targetNode\C$\")
#endregion

#region main
# Copy resources to target node
ForEach ($targetModulePath in $targetModulePaths)
{
    Copy-Item -Path $targetModulePath -Destination $uncTargetPath -Recurse -Verbose -Force
} # end for

# Install Dsc-service on target node
Invoke-Command -Session $targetNodeSession -ScriptBlock {
    Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-WindowsFeature -Name Dsc-service
} # end ScriptBlock
<# 
TASK-ITEM: 
    CAUTION; domainAdminCreds will not be encrypted. To understand the requirements and see demo for how to encrypt, see:
    Getting Started with PowerShell DSC: Securing domainAdminCreds in MOF Files | packtpub.com 
    https://youtu.be/2nsCQ32Ufx0
#>

# Complile configuration
adsCnfgInstallPushAds -OutputPath $devMofPath -domainAdminCred (Get-Credential) -ConfigurationData $ConfigDataPath

# Configure target LCM
Set-DscLocalConfigurationManager -Path $devMofPath -ComputerName $targetNode -Verbose -Force

# Apply configuration to target
Start-DscConfiguration -Path $devMofPath -ComputerName $targetNode -Wait -Verbose -Force

# Remove Session
Remove-PSSession -Session $targetNodeSession
#endregion 