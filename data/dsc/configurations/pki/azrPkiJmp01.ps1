Configuration cfgPkiJmp01
{
    $domainAdminCred = Get-AutomationPSCredential 'domainAdminCred'

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryCSDsc
    Import-DscResource -ModuleName CertificateDsc
    Import-DscResource -ModuleName xPendingReboot
    Import-DscResource -ModuleName xStorage

    $dirPki = "f:\pki"
    $dirDb = "f:\pki\db"
    $dirLog = "f:\pki\log"
    $dirExport = "f:\pki\export"
    $diskId = '2'
    $diskDriveLetter = 'f'
    $fslabel = 'data'
    $fileType = 'Directory'
    $eca = 'EnterpriseRootCA'
    $singleInstance = 'Yes'
    $ensure = 'Present'
    $CACommonName = 'pki01'
    $CADistinguishedNameSuffix = 'DC=autocloudarc,DC=ddns,DC=net'
    $cryptoProvider = 'RSA#Microsoft Software Key Storage Provider'
    $hashAlgorithm = 'SHA256'
    $keyLength = 4096
    $overwrite = $true
    $periodUnits = 'Years'
    $periodValue = 2

    Node localhost
    {
        xDisk ConfigureDataDisk
        {
            DiskId = $diskId
            DriveLetter = $diskDriveLetter
            FSLabel = $fsLabel
        } # end resource

        File dirPki
        {
            Ensure = $ensure
            Type = $fileType
            DestinationPath = $dirPki
            DependsOn = "[xDisk]ConfigureDataDisk"
        } # end resource

        File dirDb
        {
            Ensure = $ensure
            Type = $fileType
            DestinationPath = $dirDb
            DependsOn = "[File]DirPki"
        } # end resource

        File dirLog
        {
            Ensure = $ensure
            Type = $fileType
            DestinationPath = $dirLog
            DependsOn = "[File]DirPki"
        } # end resource

        File dirExport
        {
            Ensure = $ensure
            Type = $fileType
            DestinationPath = $dirExport
            DependsOn = "[File]DirPki"
        } # end resource

        # Install the ADCS Certificate Authority
        WindowsFeature ADCSCA
        {
            Name = 'ADCS-Cert-Authority'
            Ensure = $ensure
            DependsOn = @("[File]dirPki","[File]dirDb","[File]dirLog","[File]dirExport")
        } # end resource

        # Configure the CA as Standalone Root CA
        AdcsCertificationAuthority ConfigureCA
        {
            IsSingleInstance = $singleInstance
            CAType = $eca
            Credential = $domainAdminCred
            Ensure = $ensure
            CACommonName = $CACommonName
            CADistinguishedNameSuffix = $CADistinguishedNameSuffix
            CryptoProviderName = $cryptoProvider
            DatabaseDirectory = $dbPath
            HashAlgorithmName = $hashAlgorithm
            KeyLength = $keyLength
            LogDirectory = $logPath
            OutputCertRequestFile = $exportPath
            OverwriteExistingDatabase = $overwrite
            ValidityPeriod = $periodUnits
            ValidityPeriodUnits = $periodValue
            PsDscRunAsCredential = $domainAdminCred
            DependsOn = "[WindowsFeature]ADCSCA"
        } # end resource

        WindowsFeature RSAT-ADCS
        {
            Ensure = $ensure
            Name = "RSAT-ADCS"
            DependsOn = @('[WindowsFeature]ADCSCA','[AdcsCertificationAuthority]ConfigureCA')
        } # end resource

        WindowsFeature RSAT-ADCS-Mgmt
        {
            Ensure = $ensure
            Name = "RSAT-ADCS-Mgmt"
            DependsOn = @('[WindowsFeature]ADCSCA','[AdcsCertificationAuthority]ConfigureCA')
        } # end resource

        xPendingReboot Reboot1
        {
            Name = "RebootServer"
            DependsOn = @("[WindowsFeature]RSAT-ADCS","[WindowsFeature]RSAT-ADCS-Mgmt")
        } # end resource
    } # end node
} # end configuration
#endregion configuration
