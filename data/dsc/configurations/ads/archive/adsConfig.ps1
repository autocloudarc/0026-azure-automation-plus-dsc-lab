    #Requires -Version 5.1
	#Requires -RunAsAdministrator

	<#
    .SYNOPSIS

    .DESCRIPTION
		
    .EXAMPLE
		.\adsConfig.ps1
		
    .OUTPUTS

    .NOTES
        The MIT License (MIT)
		Copyright (c) 2018 Preston K. Parsard

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
		to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

		LEGAL DISCLAIMER:
		This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.�
		THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
		INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.�
		We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
		(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
		(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
		(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
		This posting is provided "AS IS" with no warranties, and confers no rights.

    .LINK
		Creating a new forest and multiple domain controllers with PowerShell DSC: https://www.gigatrust.com/creating-new-forest-multiple-domain-controllers-powershell-dsc/

    .COMPONENT

    .ROLE
		Active Directory Administrator

    .FUNCTIONALITY

#>
Configuration adsConfig
{
	Param
	(
		[Parameter(Mandatory = $true)]
		[string]$domainDnsName,
		[Parameter(Mandatory = $true)]
		[string]$DomainName,
		[Parameter(Mandatory = $true)]
		[PSCredential]$DomainAdministratorCredential,
		[Parameter(Mandatory = $true)]
		[PSCredential]$SafeModeCredential,
		[Parameter(Mandatory = $true)]
		[string]$DomainControllerFQDN,
		[Parameter(Mandatory = $true)]
		[string]$DiskId,
		[Parameter(Mandatory = $true)]
		[string]$dataDiskDriveLetter
	) # end param

	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xStorage

	# [string]$netbiosDomainName = $domainName.Split(".")[0]
	# [PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($DomainAdministratorCredentials.UserName), $($DomainAdministratorCredentials.Password)")

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

	Node $SecondDomainControllerName
	{

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
		} # end resource

		WindowsFeature "RSAT-Role-Tools"
		{
			Ensure = "Present";
			Name = "RSAT-Role-Tools"
		} # end resource

		xWaitForDisk WaitForDataDiskProvisioning
		{
			DiskId = "2"
			DiskIdType = "Number"
			RetryCount = 5
			RetryIntervalSec = 10
			DependsOn = "[WindowsFeature]RSAT-Role-Tools"
		} # end resource

		xDisk ConfigureDataDisk
		{
			DiskId = "2"
			DriveLetter = $dataDiskDriveLetter
			DependsOn = "[xWaitforDisk]WaitForDataDiskProvisioning"
		} # end resource

		<#
		# Ceate an alternate administrator account
		xADUser AlternateAdminUser
		{
			DomainName = $DomainDnsName
			UserName = $AdministratorAccount
			# The credentials only uses the password
			Password = $DomainAdministratorCredentials
			DisplayName = $AdministratorAccount
			PasswordAuthentication = 'Negotiate'
			DomainAdministratorCredential = $DomainAdministratorCredentials
			Ensure = 'Present'
			DependsOn = "[xDisk]ConfigureDataDisk"
		} # end resource

		xADGroup AddAdminToDomainAdminsGroup
		{
			GroupName = "Domain Admins"
			GroupScope = 'Global'
			Category = 'Security'
			MembersToInclude = @($AdministratorAccount, "Administrator")
			Ensure = 'Present'
			Credential = $DomainAdministratorCredentials
			DependsOn = "[xADUser]AlternateAdminUser"
		} # end resource

		xADGroup AddAdminToEnterpriseAdminsGroup
		{
			GroupName = "Enterprise Admins"
			GroupScope = 'Universal'
			Category = 'Security'
			MembersToInclude = @($AdministratorAccount, "Administrator")
			Ensure = 'Present'
			Credential = $DomainAdministratorCredentials
			DependsOn = "[xADUser]AlternateAdminUser"
		} # end resource
		#>

		xADDomainController AdditionalDC
		{
			DomainName = $domainDnsName
			DomainAdministratorCredential = $DomainAdministratorCredential
			SafemodeAdministratorPassword = $SafemodeCredential.password
			DatabasePath = $dataDiskDriveLetter + ":\NTDS"
			LogPath = $dataDiskDriveLetter + ":\LOGS"
			SysvolPath = $dataDiskDriveLetter + ":\SYSV"
			SiteName = "AZR"
			DependsOn = @("[xDisk]ConfigureDataDisk", "[WindowsFeature]AD-Domain-Services")
		} # end resource
	} # end node
} # end configuration

$modulesToInstall = @("xActiveDirectory","xComputerManagement","xStorage")
Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
ForEach ($module in $modulesToInstall)
{
	Install-Module -Name $module -Verbose
} # end foreach

[string]$DomainDnsName = "dev.adatum.com"
[string]$DomainName = ($DomainDnsName).Split(".")[0]
[PSCredential]$SafeModeCredential = $null
[string]$AdministratorAccount = "adm.infa.user"
[string]$adminUserName = $AdministratorAccount + "@" + $DomainDnsName
# [PSCredential]$DomainAdministratorCredential = Get-Credential -Message "Enter the domain administrator credentials" -UserName ($DomainName + "\" + $AdministratorAccount)
[PSCredential]$DomainAdministratorCredential = Get-Credential -Message "Enter the domain administrator credentials" -UserName $adminUserName
[PSCredential]$SafeModeCredential = Get-Credential -Message "Enter the new domain's Safe Mode administrator password" -UserName '(Password Only)'
[string]$DomainControllerFQDN = "azrads1001" + "." + $DomainDnsName

# [string]$GatewayAddress = $null
# [string]$SubnetMask = $null
[string]$DiskId = "2"
[string]$dataDiskDriveLetter = "F"
[string]$configPath = $PSScriptRoot
[string]$mofPath = Join-Path -Path $PSScriptRoot -ChildPath "mof"
If (-not(Test-Path -path $mofPath -ErrorAction SilentlyContinue))
{
	New-Item -Path $mofPath -ItemType Directory -Verbose
} # end if

adsConfig -DomainDnsName $DomainDnsName `
-DomainName $DomainName `
-DomainAdministratorCredential $DomainAdministratorCredential `
-SafeModeCredential $SafeModeCredential `
-DomainControllerFQDN $DomainControllerFQDN `
-DiskId $DiskId `
-dataDiskDriveLetter $dataDiskDriveLetter

# Prepare the session
# $session = New-CimSession -Credential $DomainAdministratorCredential -ComputerName $DomainControllerFQDN -Verbose

# Apply the configuration using the session
# Start-DscConfiguration -Path $configPath -CimSession $session -Verbose -Wait -Force -WhatIf
Start-DscConfiguration -Path $mofPath -Verbose -Wait -Force