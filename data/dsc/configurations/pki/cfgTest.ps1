#requires -Version 5.1
#requires -RunAsAdministrator
Configuration cfgTest
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

    node localhost
    {
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
$mofPath = ".\cfgTest"
#endregion

#region main

# Complile configuration
$currentUserName = ($env:username + '@' + $env:userdnsdomain).ToLower()
$domainAdminCred = Get-Credential -message "Enter domain administrator password" -UserName $currentUserName
cfgTest -ConfigurationData $ConfigDataPath -OutputPath $mofPath -domainAdminCred $domainAdminCred -Verbose
# Apply configuration to local target node
Start-DscConfiguration -Path $mofPath -Wait -Verbose -WhatIf
#endregion
