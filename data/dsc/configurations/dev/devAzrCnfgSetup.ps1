# Configure prerequisites
Configuration devServerSetup
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xStorage

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