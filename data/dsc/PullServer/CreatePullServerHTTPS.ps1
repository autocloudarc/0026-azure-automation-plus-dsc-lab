[DSCLocalConfigurationManager()]
configuration ConfigurePullServerLCM
{
    param
    (
        [ValidateNotNullOrEmpty()]
        [string] $NodeName = $env:COMPUTERNAME
    )

    Node $NodeName
    {
        Settings
        {
            RefreshMode        = 'Push'
			ConfigurationMode = 'ApplyAndAutoCorrect'
			RebootNodeIfNeeded = $true
			ActionAfterReboot  = 'ContinueConfiguration'
        } # end settings
    } # end node
} #  end configuration

# Set output path
<<<<<<< HEAD
$lcmConfigPath = "F:\data\dsc\PullServerLCM"
=======
$lcmConfigPath = "...\PullServerLCM"
>>>>>>> master
# Compile LCM configuration
ConfigurePullServerLCM -OutputPath $lcmConfigPath -Verbose
# Apply LCM configuration
Set-DscLocalConfigurationManager -ComputerName $env:COMPUTERNAME -Path $lcmConfigPath -Verbose
# Get LCM Configuration
Get-DscLocalConfigurationManager

Configuration CreateDscPullServerHTTPS
{
	param
    (
        [string[]]$NodeName = $env:COMPUTERNAME,

        [ValidateNotNullOrEmpty()]
        [string] $CertificateThumbPrint,

        [Parameter(HelpMessage='This should be a string to protect the registration of clients to the pull server using GUID.')]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey   # A guid that clients use to initiate conversation with pull server
    ) #end param
	
	# https://blogs.technet.microsoft.com/askpfeplat/2018/07/09/configuring-a-powershell-dsc-web-pull-server-to-use-sql-database/
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xPSDesiredStateConfiguration

	$dscPath = "F:\data\dsc"
	$Global:DSCMachineStatus = 1

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        } #end resource

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 443
            PhysicalPath            = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint   = $CertificateThumbPrint
            ModulePath              = "$dscPath\modules"
            ConfigurationPath       = "$dscPath\configurations"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
            RegistrationKeyPath     = "$dscPath\key"
            AcceptSelfSignedCertificates = $true
            Enable32BitAppOnWin64   = $false
			UseSecurityBestPractices = $false
			DisableSecurityBestPractices = 'SecureTLSProtocols'

        } #end resource

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$dscPath\key\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        } #end resource

		# Reboot if pending
	} #end node
} #end configuration

# Install required modules
$TargetRepository = "PSGallery"
$InstallationPolicy = "Trusted"
Set-PSRepository -Name $TargetRepository -InstallationPolicy $InstallationPolicy -Verbose
$requiredModules = @("DnsServer")
ForEach ($requiredModule in $requiredModules)
{
	If (-not(Get-Module -Name $requiredModule))
	{
		Install-Module -Name $requiredModule -Force
		Import-Module -Name $requiredModule -Force
	} #end if	
	
	If (-not(Get-Module -Name $requiredModule -ListAvailable))
	{
		Import-Module -Name $requiredModule -Force
	} #end if	
} # end 

# Get certificate thumbprint for pull server
# Specify certificate store location
$certStore = "Cert:\LocalMachine\My"
# Cert friendly name to search for: This requires that this server has already been configured as a domain certificate authority and a server authentication certificate has been generated and imported
$certFriendlyName = "pullserver"
$thumbprint = (Get-ChildItem -Path $certStore | Where-Object { $_.FriendlyName -match $certFriendlyName } | Select-Object -Property Thumbprint).Thumbprint
# Create a new guid for the registration key
$RegistrationKey = ([guid]::NewGuid()).guid
# Specify output path
<<<<<<< HEAD
$configPath = "F:\data\dsc\PullServer"
=======
$configPath = "<>"
>>>>>>> master

# Get certificate thumbprint of pull server certificate which has the subject name of 'dscpull'
# https://stackoverflow.com/questions/39286570/registering-a-record-in-dns-remotely-using-powershell
# Install AD and DNS features if required
$preConfigFeatures = @("RSAT-AD-Tools", "RSAT-DNS-Server")
ForEach ($preConfigFeature in $preConfigFeatures)
{
	If ((Get-WindowsFeature -Name $preConfigFeature).InstallState -eq "Available")
	{
		Install-WindowsFeature -Name $preConfigFeature -IncludeAllSubFeature -IncludeManagementTools
	} #end if
} #end foreach

$adDomain = Get-ADDomain
# Your DNS Server Name
$dns = $adDomain.ReplicaDirectoryServers[0]
# Your Forward Lookup Zone Name
$zone = $adDomain.DnsRoot
# Get IPv4 address. Use the $ip.IpAddress property for only the IP value
$ip = Get-NetIPAddress | Where-Object { $_.IPv4Address -match '10.' }
$pullServerRecord = Get-DnsServerResourceRecord -Name $certFriendlyName -ComputerName $dns -ZoneName $zone -RRType A

if (-not($pullServerRecord))
{
<<<<<<< HEAD
	Add-DnsServerResourceRecordA –ComputerName $dns -Name $certFriendlyName -IPv4Address $ip.IPAddress -ZoneName $Zone
=======
	Add-DnsServerResourceRecordA ï¿½ComputerName $dns -Name $certFriendlyName -IPv4Address $ip.IPAddress -ZoneName $Zone
>>>>>>> master
	# if Get-DnsServerResourceRecord -Name dscpull -ComputerName $dns -ZoneName $zone -RRType A { "OK" }
} #end 

# Compile the configuration
CreateDscPullServerHTTPS -CertificateThumbPrint $thumbprint -RegistrationKey $RegistrationKey -OutputPath $configPath
# Run the compile configuration to make the target node a DSC Pull Server
Start-DscConfiguration -Path $configPath -Wait -Verbose -Force
# Show configuration results
Test-DscConfiguration
Get-DscConfigurationStatus
Get-DscConfiguration
# Start-Sleep -Seconds 60
# Reboot to apply changes
# Restart-Computer -Force
