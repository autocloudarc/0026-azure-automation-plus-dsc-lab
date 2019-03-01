#requires -PSEdition Desktop
#requires -Version 5.1
#requires -RunAsAdministrator

<#
.SYNOPSIS
Install and configure a new development server.

.DESCRIPTION
This script prepares a new development server for the Desired State Configuration Push/Pull roles, as well as the CA role.
The configuratin are accomplished using Desired State Configuration in push mode by installing the pre-requisite roles, features, directories and DSC resources locally.

.PARAMETER domainAdminCred
Domain administrator credentials

.EXAMPLE
# Dot source script
. .\New-DevServerPreReqs.ps1

# Compile configuration
ServerPrereq -OutputPath $devMofPath

# Apply configuration
Start-DscConfiguration -Path $devMofPath -Wait -Verbose -Force

.NOTES
The MIT License (MIT)
Copyright (c) 2018 Preston K. Parsard

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.Â 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.Â 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.LINK
1. Prepare Data Drive: https://blogs.msdn.microsoft.com/timomta/2016/04/23/how-to-use-powershell-dsc-to-prepare-a-data-drive-on-an-azure-vm/

.COMPONENT
ActiveDirectory,PKI, CA

.ROLE
Systems Engineer
Security Engineer
DevOps Engineer
Infrastructure Engineer

.FUNCTIONALITY
Configure prerequistes on a dev server for DSC pull/push and CA roles
#>

# Get modules to install
$moduleList = @("xStorage","ActiveDirectoryCSDsc","CertificateDsc","xActiveDirectory","xComputerManagement","xPendingReboot","SqlServerDSC","SqlServer","dbatools")

# Set installation policy for PSGallery to trusted. This will avoid prompts to proceed and install package managers
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose
# Install pre-requiste modules to configure hard drive, and setup certificate services
Install-Module -Name $moduleList -Force -Verbose
# Install the DSC feature to compile and apply DSC configurations
Install-WindowsFeature -Name "Dsc-Service"

# Configure prerequisites
Configuration devServerSetup
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xStorage

    $ensure = "Present"

    $dcFeaturesToAdd = @(
		$rsatDnsServer = @{
			Ensure = $ensure
			Name = "RSAT-DNS-Server"
		} # end hashtable
		$rsatAdCenter = @{
			Ensure = $ensure
			Name = "RSAT-AD-AdminCenter"
		} # end hashtable
		$rsatADDS = @{
			Ensure = $ensure
			Name = "RSAT-ADDS"
		} # end hashatable
		$rsatAdPowerShell = @{
			Ensure = $ensure
			Name = "RSAT-AD-PowerShell"
		} # end hashtable
		$rsatAdTools = @{
			Ensure = $ensure
			Name = "RSAT-AD-Tools"
		} # end hashatale
		$rsatGPMC = @{
			Ensure = $ensure
			Name = "GPMC"
        } # end hashtable
        $rsatCertAuth = @{
            Ensure = $ensure
            Name = "ADCS-Cert-Authority"
        } # end hashtable
        $rsatADCS = @{
            Ensure = $ensure
            Name = "RSAT-ADCS"
        } # end hashtable
        $rsatADCSMGT = @{
            Ensure = $ensure
            Name = "RSAT-ADCS-Mgmt"
        } # end hashtable
	) # end array

    Node localhost
    {
        # Check for disk
        xWaitForDisk Disk2
        {
            DiskId = '2'
            RetryIntervalSec = 10
            RetryCount = 3
        } # end resource

        # Create F Volume
        xDisk FVolume
        {
            DiskId = '2'
            DriveLetter = 'F'
            FSLabel = 'data'
            DependsOn = '[xWaitForDisk]Disk2'
        } # end resource

        ForEach ($dcFeature in $dcFeaturesToAdd)
		{
			WindowsFeature "$($dcFeature.Name)"
				{
					Ensure = "$($dcFeature.Present)"
					Name = "$($dcFeature.Name)"
				} # end resource
		} # end foreach

    } # end node
} # end configuration

#region Initalize values
$devServerTopLevelFolder = "c:\devServer"
$targetDrive = "f:\"
$targetDriveTopLevelFolder = "f:\devServer"
$devMofPathInitial = "c:\devServer\data\dsc\mof"
$singleSeparator = ("-"*200)

<#
if ((Test-Path -Path $devServerTopLevelFolder) -and (-not(Test-Path $devMofPathPerm)))
{
    $devMofPath = $devMofPathInitial
} # end if
elseif ((Test-Path -Path $devMofPathPerm) -and (-not(Test-Path -Path $devMofPath)))
{
    $devMofPath = $devMofPathPerm
} # end elseif
#>

Write-Output $singleSeparator
#endregion main

#region main
# Compile configuration
DevServerPrereq -OutputPath $devMofPathInitial -Verbose
# Apply configuration
Start-DscConfiguration -Path $devMofPathInitial -Wait -Verbose -Force
#endregion main
Copy-Item -Path $devServerTopLevelFolder -Destination $targetDrive -Recurse -Verbose
If ($?)
{
    Remove-Item -Path $devServerTopLevelFolder -Force
} # end if
else
{
    Write-Ouput "An error occured while attempting to copy the contents of $devServerTopLevelFolder to $targetDrive" -Verbose
    Remove-Item -Path $targetDriveTopLevelFolder -Force -Verbose
} # end else



