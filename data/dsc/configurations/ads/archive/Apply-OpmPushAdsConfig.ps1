#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

using Namespace System.Security.Cryptography.X509Certificates

<#
.SYNOPSIS
Configure a domain controller using push DSC and an external configuration data file

.DESCRIPTION
This script includes a DSC configuration to build an additional domain controller for an existing domain. 

.PARAMETER domainAdminCred
Domain administrator username and password.

.PARAMETER Reset
Demotes the DC to a member server.

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
3. https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-
4. https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-desired-state-configuration-lcm-and-push-management-model/

.COMPONENT
Windows PowerShell Desired State Configuration, ActiveDirectory

.ROLE
Systems Engineer
DevOps Engineer
Active Directory Engineer

.FUNCTIONALITY
Configures a member server as a new domain controler in an existing domain.
#>

#region Configuration
Configuration applyOpmPushAdsConfig
{
	Param
	(
		[Parameter(Mandatory=$true)]
		[pscredential]$domainAdminCred,
		[string]$Ensure = "Present"
        #>
	) # end param
    
    # Convert domainAdminCreds to netbios domainAdminCred format [NETBIOSdomainname\username]
    $domainUserUpn = $credenital.UserName

    Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xStorage, xPendingReboot

	$dcFeaturesToAdd = @(
		$rsatDns = @{
			Ensure = $Ensure;
			Name = "DNS"
		} # end hastable
		$rsatDnsServer = @{
			Ensure = $Ensure;
			Name = "RSAT-DNS-Server"
		} # end hashtable
		$rsatAdCenter = @{
			Ensure = $Ensure;
			Name = "RSAT-AD-AdminCenter"
		} # end hashtable
		$rsatADDS = @{
			Ensure = $Ensure;
			Name = "RSAT-ADDS"
		} # end hashatable
		$rsatAdPowerShell = @{
			Ensure = $Ensure;
			Name = "RSAT-AD-PowerShell"
		} # end hashtable
		$rsatAdTools = @{
			Ensure = $Ensure;
			Name = "RSAT-AD-Tools"
		} # end hashatale
		$rsatGPMC = @{
			Ensure = $Ensure;
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
			CertificateID = $node.dscNodeCertThumbprint
		} # end LCM

		ForEach ($dcFeature in $dcFeaturesToAdd)
		{
			WindowsFeature "$($dcFeature.Name)"
				{
					Ensure = "$($dcFeature.Ensure)"
					Name = "$($dcFeature.Name)"
				} # end resource
		} # end foreach

		WindowsFeature "AD-Domain-Services"
		{
			Ensure = $Ensure;
			Name = "AD-Domain-Services"
		} # end hashtable

		WindowsFeature "RSAT-Role-Tools"
		{
			Ensure = $Ensure;
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
            DomainUserCredential = $domainAdminCred
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
			SiteName = "AZR"
			IsGlobalCatalog = $true
			PsDscRunAsCredential = $domainAdminCred
		} # end resource

        xPendingReboot Reboot1
        { 
           Name = "RebootServer"
           DependsOn = "[xADDomainController]NewReplicaDC"
        } # end resource
	} # end node
} # end configuration
#endregion

#region Configuration Data
$ConfigData = @{
    AllNodes = @(
        # Configure the ...01 DC only
        @{
            NodeName = 'azrads1001.dev.adatum.com'
            <#
                Although the thumbprint value, when viewed directly from the certificate store in the certificates mmc console shows lowercase,
                the value below must be in upper case to avoid the following error:
                The Certificate ID is not valid: '‎47a6934f0a7a894aef988c5708c4554e1c4a5a28'
                + CategoryInfo          : InvalidArgument: (root/Microsoft/...gurationManager:String) [], CimException
                + FullyQualifiedErrorId : MI RESULT 4
                + PSComputerName        : AZRADS1001.dev.adatum.com
                The Certificate ID is not valid: '‎47a6934f0a7a894aef988c5708c4554e1c4a5a28'
                + CategoryInfo          : InvalidArgument: (root/Microsoft/...gurationManager:String) [], CimException
                + FullyQualifiedErrorId : MI RESULT 4
                + PSComputerName        : AZRADS1001.dev.adatum.com
            #>
            dscNodeCertThumbprint = "47A6934F0A7A894AEF988C5708C4554E1C4A5A28"
	        CertificateFile = "c:\dscNodeCert\AZRADS1001-dscNodeCert.cer"
            role = "ads"
            fqdn = 'dev.adatum.com'
            DomainName = 'dev'
            dataDiskNumber = '2'
            retryCount = 3
            retryIntervalSec = 10
            dataDiskDriveLetter = 'F'
            FSFormat = 'NTFS'
            FSLabel = 'DATA'
            PSDscAllowPlainTextPassword=$true
            PsDscAllowDomainUser = $true
            ntdsPathSuffix = ":\NTDS"
            logsPathSuffix = ":\LOGS"
            sysvPathSuffix = ":\SYSV"
         } # end hashtable
    ) # end array
} # end hashtable

#endregion

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
# Set MOF path
$devMofPath = "E:\data\git\JHDesiredState\data\dsc\configurations\ads\mof"
# Select target node to configure by looking for the 01 series DC patter for dev.adatum.com the .. represents a 2 digit number that can vary by deployments
$targetNode = $configData.AllNodes.NodeName
# Get list of resources required for this configuration so that can be copied to the target node
$dscResourceList = @("xActiveDirectory", "xComputerManagement", "xStorage", "xPendingReboot")
# Create a session to prepare the target node, i.e Install pre-requisite features 
$targetNodeSession = New-PSSession -Name $targetNode

# Install Dsc-service on target node
Invoke-Command -Session $targetNodeSession -ScriptBlock {
    Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Install-WindowsFeature -Name Dsc-service
	foreach ($dscResourceModule in $using:dscResourceList)
	{
		if (Get-InstalledModule -Name $dscResourceModule -ErrorAction SilentlyContinue -Verbose)
		{
			$currentVersion = (Find-Module -Name $dscResourceModule).Version
			$installedVersion = (Get-InstalledModule -Name $dscResourceModule).Version
			If ($currentVersion -ne $installedVersion)
			{
				# If this is a DSC Resource module, i.e. x, then completely uninstall the module and remove it before attempting the install...
				If ($dscResourceModule.Substring(0,1) -eq "x")
				{
					Uninstall-Module -Name $dscResourceModule -Force -ErrorAction SilentlyContinue -Verbose
					Remove-Module -Name $dscResourceModule -Force -ErrorAction SilentlyContinue -Verbose
					Install-Module -Name $dscResourceModule -Force -ErrorAction SilentlyContinue -Verbose		
				} # end if 
				else 
				# ...Otherwise, just update it.
				{
					Update-Module -Name $dscResourceModule -Force -ErrorAction SilentlyContinue -Verbose
				} # end else
			} # end if
		} # end if
		else 
		{
			Install-Module -Name $dscResourceModule -Repository PSGallery -Force -Verbose 
			Import-Module -Name $dscResourceModule -Verbose
		} # end else
	} # end foreach
} # end ScriptBlock

# Create directory for certificate exported from node(s)
$targetNetBiosName = $targetNode.Split(".")[0]
$certFileName = "$targetNetBiosName-dscNodeCert.cer"
$dirForNodeCert = "c:\dscNodeCert"
$certPath = Join-Path -Path $dirForNodeCert -ChildPath $certFileName
$localMachineStore = "Cert:\LocalMachine\My"
$nodeCertFilter = 'dscNodeCert'

# ***IMPORTANT*** TASK-ITEM: Prerequisite; Create DSC Node Certificate manually by copying and pasting the code section below
<#
Enter-PSSession -ComputerName azrads1002 -verbose
New-SelfSignedCertificate -Type DocumentEncryptionCert -DnsName "AZRADS1002-dscNodeCert" -CertStoreLocation "Cert:\LocalMachine\My" -Verbose
Exit-PSSession

#>
<# 
TASK-ITEM: 
    CAUTION; domainAdminCreds will not be encrypted. To understand the requirements and see demo for how to encrypt, see:
    Getting Started with PowerShell DSC: Securing domainAdminCreds in MOF Files | packtpub.com 
    https://youtu.be/2nsCQ32Ufx0
#>

# Complile configuration
applyOpmPushAdsConfig -OutputPath $devMofPath -domainAdminCred (Get-Credential) -ConfigurationData $ConfigData

# Configure target LCM
Set-DscLocalConfigurationManager -Path $devMofPath -ComputerName $targetNode -Verbose -Force

# Apply configuration to target
Start-DscConfiguration -Path $devMofPath -ComputerName $targetNode -Wait -Verbose -Force

# Remove Session
Remove-PSSession -Session $targetNodeSession -Verbose

Stop-Transcript -Verbose
notepad.exe $logFilePath
#endregion 