Configuration adsCnfgInstall
{
	Param
	(
		[string]$domainName,
		[string]$dataDiskNumber,
		[string]$dataDiskDriveLetter,
		[System.Management.Automation.PSCredential]$domainAdminCredentials
	) # end param

	Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xStorage

	[string]$netbiosDomainName = $domainName.Split(".")[0]
	[System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${netbiosDomainName}\$($domainAdminCredentials.UserName)", $domainAdminCredentials.Password)

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

	Node azrads1004.dev.adatum.com
	{
  		LocalConfigurationManager
		{
			ConfigurationMode = 'ApplyAndAutoCorrect'
			RebootNodeIfNeeded = $true
			ActionAfterReboot = 'ContinueConfiguration'
			AllowModuleOverwrite = $true
		} # end LCM

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
		} # end hashtable

		WindowsFeature "RSAT-Role-Tools"
		{
			Ensure = "Present";
			Name = "RSAT-Role-Tools"
		} # end hashtable

		xWaitForDisk WaitForDataDiskProvisioning
		{
			DiskId = $dataDiskNumber
			RetryCount = $Node.RetryCount
			RetryIntervalSec = $Node.RetryIntervalSec
			DependsOn = "[WindowsFeature]RSAT-Role-Tools"
		} # end resource

		xDisk ConfigureDataDisk
		{
			DiskId = $dataDiskNumber
			DriveLetter = $dataDiskDriveLetter
			DependsOn = "[xWaitforDisk]WaitForDataDiskProvisioning"
		} # end resource

		xADDomain CreateForest
		{
			DomainName = $domainName
			DomainAdministratorCredential = [System.Management.Automation.PSCredential]$DomainCreds
			SafemodeAdministratorPassword = [System.Management.Automation.PSCredential]$DomainCreds
			DomainNetbiosName = $netbiosDomainName
			DatabasePath = $dataDiskDriveLetter + ":\NTDS"
			LogPath = $dataDiskDriveLetter + ":\LOGS"
			SysvolPath = $dataDiskDriveLetter + ":\SYSV"
			DependsOn = "[xDisk]ConfigureDataDisk", "[WindowsFeature]AD-Domain-Services"
		} # end resource
	} # end node
} # end configuration

$domainAdminCredentials = Get-Credential -Message "Enter domain admin username and password" 

adsCnfgInstall -domainName dev.adatum.com -dataDiskNumber 2 -dataDriveLetter F -domainAdminCredentials

$SecondDomainControllerName = "azrads1004.dev.adatum.com"

# Prepare the session
$session = New-CimSession -Credential $DomainAdministratorCredentials -ComputerName $SecondDomainControllerName -Verbose

# Apply the configuration using the session
Start-DscConfiguration -Path $configPath -CimSession $session -Verbose -Wait -WhatIf