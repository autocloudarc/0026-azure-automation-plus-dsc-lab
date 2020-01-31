Configuration applyAzrPullPkiConfig
{
    param (
		[string]$targetNode = "azrpki1001.dev.adatum.com",
		[string]$role = 'pki',
		[string]$eca = 'EnterpriseRootCA',
		[string]$singleInstance = 'Yes',
		[string]$ensure = 'Present',
		[string]$CACommonName = 'pki01',
		[string]$CADistinguishedNameSuffix = 'DC=dev,DC=adatum,DC=com',
		[string]$cryptoProvider = 'RSA#Microsoft Software Key Storage Provider',
		[string]$dbPath = 'F:\OneDrive\02.00.00.GENERAL\devServer\data\pki\db',
		[string]$hashAlgorithm = 'SHA256',
		[string]$keyLength = 4096,
		[string]$logPath = 'F:\OneDrive\02.00.00.GENERAL\devServer\data\pki\logs',
		[string]$exportPath = 'F:\OneDrive\02.00.00.GENERAL\devServer\data\pki\cert\export',
		[bool]$overwrite = $true,
		[string]$periodUnits = 'Years',
		[string]$periodValue = 5,
		[string]$fqdn = 'dev.adatum.com',
		[string]$DomainName = 'dev',
		[bool]$PSDscAllowPlainTextPassword=$true,
		[bool]$PsDscAllowDomainUser = $true
    ) # end param
    
    Import-DscResource -ModuleName ActiveDirectoryCSDsc
    Import-DscResource -ModuleName CertificateDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPendingReboot
	[pscredential]$domainAdminCred = Get-AutomationPSCredential 'domainAdminCred'

    Node $TargetNode
    { 
		# Install the ADCS Certificate Authority
		WindowsFeature ADCSCA
		{
			Name = 'ADCS-Cert-Authority'
			Ensure = $ensure
		} # end resource
		WindowsFeature RSAT-ADCS
		{
			Ensure = $Ensure 
			Name = 'RSAT-ADCS'
			DependsOn = '[WindowsFeature]ADCSCA'
		} # end resource
		WindowsFeature RSAT-ADCS-Mgmt
		{
			Ensure = $Ensure 
			Name = 'RSAT-ADCS-Mgmt'
			DependsOn = '[WindowsFeature]ADCSCA'
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
			DependsOn = '[WindowsFeature]ADCSCA'
		} # end resource    	  
		xPendingReboot Reboot1
		{ 
			Name = "RebootServer"
			DependsOn = '[WindowsFeature]RSAT-ADCS-Mgmt'
		} # end resource  
    } # end node
} # end configuration