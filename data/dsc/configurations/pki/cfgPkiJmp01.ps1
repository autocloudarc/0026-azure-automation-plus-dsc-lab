#requires -Version 5.1
#requires -RunAsAdministrator

# using namespace System.Net
<#
.SYNOPSIS
Install and configure a new certificate authority server role.

.DESCRIPTION
This configuration script installs and configures the Active Directory certificate services role locally using the desired state configuration push delivery mode.

.PARAMETER domainAdminCred
Domain administrator credentials

.EXAMPLE
Complile configuration
pkiCnfgInstallPushJmp01 -OutputPath $devMofPath -domainAdminCred $domainAdminCred -ConfigurationData $ConfigDataPath

# Configure target LCM
Set-DscLocalConfigurationManager -Path $devMofPath -ComputerName $targetNode -Verbose -Force

# Apply configuration to target
Start-DscConfiguration -Path $devMofPath -ComputerName $targetNode -Wait -Verbose -Force

.NOTES
The MIT License (MIT)
Copyright (c) 2020 Preston K. Parsard
Author: Russel Smith (See Link 1. for attribution and reference)
Editor: Preston K. Parsard

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
1. Deploy Active Directory and Certificate Services in Azure Using Infrastructure-as-Code --Part 2: https://www.petri.com/deploy-active-directory-certificate-services-azure-using-infrastructure-code-part-2
2. CertificateDsc: https://github.com/PowerShell/CertificateDsc
3. ActiveDirectoryCSDsc: https://github.com/PowerShell/ActiveDirectoryCSDsc

.COMPONENT
PKI, CA

.ROLE
Security Engineer
DevOps Engineer
Infrastructure Engineer

.FUNCTIONALITY
Install and configure an enterprise CA server
#>

#region ENVIRONMENT SETUP
Set-Location -Path $PSScriptRoot -Verbose 
#endregion

#region DOCUMENT ENCRYPTION CERTIFICATE
<#
# note: These steps need to be performed in an Administrator PowerShell session
$nodeCertSuffix = "-nodeCert"
$dnsName = $env:ComputerName + $nodeCertSuffix
$cspType = "DocumentEncryptionCertLegacyCsp"
$algorithm = "SHA256"
$nodeCertDir = 'f:\nodeCert'
$nodeCertFileName = "$dnsName.cer"
$nodeCertFile = Join-Path -Path $nodeCertDir -ChildPath $nodeCertFileName

$cert = New-SelfSignedCertificate -Type $cspType -DnsName $dnsName -HashAlgorithm $algorithm -Verbose
# export the public key certificate
$cert | Export-Certificate -FilePath $nodeCertFile -Force -Verbose 

$thumbprint = (Get-ChildItem -Path cert:\localmachine\my | Where-Object {$_.Subject -match 'nodeCert'}).Thumbprint
#>
#endregion

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

# List required DSC resource modules
$resourceList = @("ActiveDirectoryCSDsc", "CertificateDsc","xStorage","xPendingReboot","AzureAutomation")
Get-ARMDeployPSModule -ModulesToInstall $resourceList -PSRepository $PSModuleRepository -Verbose
#endregion MODULES

Set-StrictMode -Off -Verbose
#region configuration
Configuration cfgPkiJmp01
{
    param
    (
        [Parameter(Mandatory)]
        [PSCredential]$domainAdminCred
    ) # end param

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryCSDsc
    Import-DscResource -ModuleName CertificateDsc
    Import-DscResource -ModuleName xPendingReboot
    Import-DscResource -ModuleName xStorage

    # Get list of CA management features to add
    $caMgmtFeatures = @('RSAT-ADCS','RSAT-ADCS-Mgmt')
    $pkiDirs = @($node.pkiPath,$node.dbPath,$node.logPath,$node.exportPath)

    Node localhost {
        xDisk ConfigureDataDisk
        {
            DiskId = $node.diskId
            DriveLetter = $node.diskDriveLetter
            FSLabel = $node.fslabel
        } # end resource

        # Configure the PKI directory
        foreach ($dir in $pkiDirs) 
        {
            File $dir
            {
                Ensure = $node.ensure
                Type = $node.fileType
                DestinationPath = $dir
                DependsOn = "[xDisk]ConfigureDataDisk"
            } # end resource
        } # end foreach

        # Install the ADCS Certificate Authority
        WindowsFeature ADCSCA
        {
            Name = 'ADCS-Cert-Authority'
            Ensure = $node.ensure
            DependsOn = "[File]$dir"
        } # end resource

        # Configure the CA as Standalone Root CA
        AdcsCertificationAuthority ConfigureCA
        {
            IsSingleInstance = $node.singleInstance
            CAType = $node.eca
            Credential = $domainAdminCred
            Ensure = $node.ensure
            CACommonName = $Node.CACommonName
            CADistinguishedNameSuffix = $Node.CADistinguishedNameSuffix
            CryptoProviderName = $node.cryptoProvider
            DatabaseDirectory = $node.dbPath
            HashAlgorithmName = $node.hashAlgorithm
            KeyLength = $node.keyLength
            LogDirectory = $node.logPath
            OutputCertRequestFile = $node.exportPath
            OverwriteExistingDatabase = $node.overwrite
            ValidityPeriod = $node.periodUnits
            ValidityPeriodUnits = $node.periodValue
            PsDscRunAsCredential = $domainAdminCred
            DependsOn = @("[WindowsFeature]ADCSCA","[File]$dir")
        } # end resource

        ForEach ($caMgmtFeature in $caMgmtFeatures)
        {
            WindowsFeature $caMgmtFeature
            {
                Ensure = $node.ensure
                Name = $caMgmtFeature
                DependsOn = @('[WindowsFeature]ADCSCA','[AdcsCertificationAuthority]ConfigureCA')
            } # end resource
        } # end foreach

        xPendingReboot Reboot1
        {
            Name = "RebootServer"
            DependsOn = "[WindowsFeature]$caMgmtFeature"
        } # end resource
    } # end node
} # end configuration
#endregion configuration

#region Intialize values
# Set ConfigData path
$ConfigDataPath = ".\cfgPkiJmp01.psd1"
$mofPath = ".\cfgPkiJmp01"
#endregion

#region main

# Complile configuration
$currentUserName = ($env:username + '@' + $env:userdnsdomain).ToLower()
$domainAdminCred = Get-Credential -message "Enter domain administrator password" -UserName $currentUserName

cfgPkiJmp01 -ConfigurationData $ConfigDataPath -OutputPath $mofPath -domainAdminCred $domainAdminCred -Verbose
Set-DscLocalConfigurationManager -path $mofPath -Verbose
# Apply configuration to local target node
Start-DscConfiguration -Path $mofPath -Wait -Verbose -WhatIf
#endregion
