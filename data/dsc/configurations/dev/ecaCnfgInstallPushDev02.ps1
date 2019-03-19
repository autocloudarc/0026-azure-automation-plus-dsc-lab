#requires -PSEdition Desktop
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
adsCnfgInstallPushAds01 -OutputPath $devMofPath -domainAdminCred $domainAdminCred -ConfigurationData $ConfigDataPath

# Configure target LCM
Set-DscLocalConfigurationManager -Path $devMofPath -ComputerName $targetNode -Verbose -Force

# Apply configuration to target
Start-DscConfiguration -Path $devMofPath -ComputerName $targetNode -Wait -Verbose -Force

.NOTES
The MIT License (MIT)
Copyright (c) 2018 Preston K. Parsard
Author: Russel Smith (See Link 1. for attribution and reference)
Editor: Preston K. Parsard

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

#region configuration
Configuration ecaCnfgInstallPushDev01
{
 param
 (
    [Parameter(Mandatory)]
    [PSCredential]$domainAdminCred
 ) # end param
 
  Import-DscResource -ModuleName ActiveDirectoryCSDsc, CertificateDsc, PSDesiredStateConfiguration
    
  # Get list of CA management features to add
  $caMgmtFeatures = @('RSAT-ADCS','RSAT-ADCS-Mgmt')
    
  Node localhost {
     # Install the ADCS Certificate Authority
     WindowsFeature $node.feature
     {
         Name = $node.feature #'ADCS-Cert-Authority'
         Ensure = $node.ensure
     } # end resource
     # Configure the CA as Standalone Root CA
     AdcsCertificationAuthority ConfigureCA
     {
         IsSingleInstance = $node.singleInstance # 'Yes'
         CAType = $node.eca # 'EnterpriseRootCA'
         Credential = $domainAdminCred 
         Ensure = $node.ensure # 'Present'
         CACommonName = $Node.CACommonName # 'eca01'
         CADistinguishedNameSuffix = $Node.CADistinguishedNameSuffix # 'DC=dev,DC=adatum,DC=com'
         CryptoProviderName = $node.cryptoProvider #'RSA#Microsoft Software Key Storage Provider'
         DatabaseDirectory = $node.dbPath # 'f:\ca\db'
         HashAlgorithmName = $node.hashAlgorithm # 'SHA256'
         KeyLength = $node.keyLength # 4096
         LogDirectory = $node.logPath # 'f:\ca\logs'
         OutputCertRequestFile = $node.exportPath # 'f:\ca\cert\export'
         OverwriteExistingDatabase = $node.overwrite # $true
         ValidityPeriod = $node.periodUnits # 'Years'
         ValidityPeriodUnits = $node.periodValue # 20
         DependsOn = '[WindowsFeature]ADCSCA' 
     } # end resource     
     ForEach ($caMgmtFeature in $caMgmtFeatures)
     {
      WindowsFeature $caMgmtFeature
      { 
          Ensure = $node.ensure
          Name = $caMgmtFeature
          DependsOn = '[WindowsFeature]ADCSCA' 
      } # end resource 
     } # end foreach
   } # end node
} # end configuration
#endregion
 
#region Intialize values
# List required DSC resource modules
$resourceList = @("ActiveDirectoryCSDsc", "CertificateDsc")
# Set MOF path
$devMofPath = "f:\dsc\mof"
# Set ConfigData path
$ConfigDataPath = "f:\dsc\configdata\ecaDataInstallPushDev01.psd1"
# Set node target
$nodeTarget = "$env:COMPUTERNAME.dev.adatum.com".ToLower()

#endregion

#region main
# Update DSC Modules
Install-PackageProvider -Name NuGet -Force -Verbose
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose
Install-Module -Name $resourceList -Verbose

# Complile configuration
ecaCnfgInstallPushDev01 -OutputPath $devMofPath -domainAdminCred (Get-Credential) -ConfigurationData $ConfigDataPath -Verbose

# Apply configuration to local target node
Start-DscConfiguration -Path $devMofPath -ComputerName localhost -Wait -Verbose -Force
#endregion