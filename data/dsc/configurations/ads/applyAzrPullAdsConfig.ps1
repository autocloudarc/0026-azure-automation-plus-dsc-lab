Configuration applyAzrPullAdsConfig
{
    param (
        [string]$targetNode = 'localhost',
        [string]$role = 'ads',
        [string]$fqdn = 'dev.adatum.com',
        [string]$DomainName = 'dev',
        [string]$dataDiskNumber = '2',
        [int]$retryCount = 3,
        [int]$retryIntervalSec = 10,
        [string]$dataDiskDriveLetter = 'F',
        [string]$FSFormat = 'NTFS',
        [string]$FSLabel = 'DATA',
        [bool]$allowPlainTextPw = $true,
        [bool]$allowDomainUser = $true,
        [string]$ntdsPathSuffix = ":\NTDS",
        [string]$logsPathSuffix = ":\LOGS",
        [string]$sysvPathSuffix = ":\SYSV",
        [string]$Ensure = 'Present',
        [string]$SiteName = 'AZR',
        [bool]$globalCatalog = $true,
        [string]$pendingRebootName = 'RebootServer'
    ) # end param
    
    # Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xStorage
    Import-DscResource -ModuleName xPendingReboot
	[pscredential]$domainAdminCred = Get-AutomationPSCredential 'domainAdminCred'

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

	Node $targetNode
	{
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
			DiskId = $dataDiskNumber
			RetryCount = $RetryCount
			RetryIntervalSec = $retryIntervalSec
			DependsOn = "[WindowsFeature]RSAT-Role-Tools"
		} # end resource

		xDisk ConfigureDataDisk
		{
			DiskId = $dataDiskNumber
			DriveLetter = $dataDiskDriveLetter
            FSFormat = $FSFormat
            FSLabel = $FSLabel
			DependsOn = "[xWaitforDisk]Disk2"
		} # end resource

        xADDomainController NewReplicaDC
		{
			DomainName = $fqdn
			DomainAdministratorCredential = $domainAdminCred
			SafemodeAdministratorPassword = $domainAdminCred
			DatabasePath = $dataDiskDriveLetter + $ntdsPathSuffix
			LogPath = $dataDiskDriveLetter + $logsPathSuffix
			SysvolPath = $dataDiskDriveLetter + $sysvPathSuffix
			DependsOn = @("[WindowsFeature]AD-Domain-Services","[WindowsFeature]RSAT-Role-Tools","[xDisk]ConfigureDataDisk")
			SiteName = $SiteName
			IsGlobalCatalog = $globalCatalog
			PsDscRunAsCredential = $domainAdminCred
		} # end resource

        xPendingReboot Reboot1
        { 
           Name = "RebootServer"
           DependsOn = "[xADDomainController]NewReplicaDC"
        } # end resource
	} # end node
} # end configuration