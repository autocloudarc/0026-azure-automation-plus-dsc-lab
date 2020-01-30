#region configuration
Configuration applyOpmPushConfig
{
    param
    (
        [Parameter(Mandatory)]
        [PSCredential]$domainAdminCred
    ) # end param

    Import-DscResource -ModuleName ActiveDirectoryCSDsc
    Import-DscResource -ModuleName CertificateDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPendingReboot
    
    # Get list of CA management features to add
    $pkiMgmtFeatures = @('RSAT-ADCS','RSAT-ADCS-Mgmt')

    Node $AllNodes.NodeName 
    {
     # Install the ADCS Certificate Authority
     WindowsFeature ADCSCA
     {
         Name = 'ADCS-Cert-Authority'
         Ensure = $node.ensure
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
         DependsOn = '[WindowsFeature]ADCSCA'
     } # end resource     
     ForEach ($pkiMgmtFeature in $pkiMgmtFeatures)
     {
      WindowsFeature $caMgmtFeature
      { 
          Ensure = $node.ensure
          Name = $caMgmtFeature
          DependsOn = '[WindowsFeature]ADCSCA' 
      } # end resource 
     } # end foreach  
     
    xPendingReboot Reboot1
    { 
        Name = "RebootServer"
        DependsOn = '[WindowsFeature]RSAT-ADCS-Mgmt'
    } # end resource  
   } # end node
} # end configuration
#endregion configuration