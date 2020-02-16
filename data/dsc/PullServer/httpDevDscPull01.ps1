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
			ConfigurationMode  = 'ApplyAndAutoCorrect'
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

Configuration CreateDscPullServerHTTP
{
	# http://en.community.dell.com/techcenter/b/techcenter/archive/2016/12/30/setting-up-a-dsc-desired-state-configuration-http-pull-server-to-deploy-hyper-v-and-failover-cluster
<<<<<<< HEAD
	# C:\Program Files\WindowsPowerShell\Modules\xPSDesiredStateConfiguration\8.4.0.0\DSCResources\MSFT_xDSCWebService\MSFT_xDSCWebService.psm1
	# C:\inetpub\PSDSCPullServer\web.config
=======
>>>>>>> master
	param
    (
        [string[]]$NodeName = $env:COMPUTERNAME,

        [Parameter(HelpMessage='This should be a string with enough entropy (randomness) to protect the registration of clients to the pull server.  We will use new GUID by default.')]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey   # A guid that clients use to initiate conversation with pull server
    ) #end param
	
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xPSDesiredStateConfiguration

<<<<<<< HEAD
	$dscPath = "F:\data\dsc"
=======
	$dscPath = "<>"
>>>>>>> master
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
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$dscPath\modules"
            ConfigurationPath       = "$dscPath\configurations"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
            RegistrationKeyPath     = "$dscPath\key"
            AcceptSelfSignedCertificates = $true
			UseSecurityBestPractices = $false
        } #end resource

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$dscPath\key\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        } #end resource
	} #end node
} #end configuration

function Verify-DSCPullServer
{
	param ([string]$PullServerFqdn)
   ([xml](invoke-webrequest "http://$($PullServerFqdn):8080/psdscpullserver.svc" | % Content)).service.workspace.collection.href
} # end function

[DSCLocalConfigurationManager()]
Configuration MetaConfigPullClients
{
   param
       (
           [parameter(Mandatory=$true)]
           [String[]]$ComputerName,
 
           [parameter(Mandatory=$true)]
           [String]$guid
       ) # end param

   Node $ComputerName
   {
       settings 
	   {
           AllowModuleOverwrite = $true
           ConfigurationMode = 'ApplyandAutoCorrect'
           RefreshMode = 'Pull'        
           ConfigurationID = $guid        
           RebootNodeIfNeeded = $true          
       } # end settings
       
	   ConfigurationRepositoryWeb DSCHTTP 
		{
			   ServerURL = "http://$ComputerName:8080/PSDSCPullServer.svc"
               AllowUnsecureConnection = $true    
		} # end resource     
   } # end node
} # end configuration

# Computer list
$ClientNodes = $null
 
# Create Guid for the computers (Either you can create a new GUID or use existing one.In the example below I am using the existing GUID)
$guid = ([guid]::NewGuid()).guid
 
# Create the computer Meta.Mof in folder

<<<<<<< HEAD
$pullClientLCMPath = "F:\data\dsc\PullServer"
=======
$pullClientLCMPath = "<>"
>>>>>>> master

# Compile the meta configuration
# MetaConfigPUllClients -ComputerName $CientNode -guid $guid -OutputPath $pullClientLCMPath
# Set the LCM for client machines
# Set-DscLocalConfigurationManager -ComputerName $ClientNode -Path $pullClientLCMPath -Verbose

<<<<<<< HEAD
$fqdn = $env:COMPUTERNAME + ".dev.adatum.com"

$PullServerConfigPath = "F:\data\dsc\PullServer"
=======
$fqdn = $env:COMPUTERNAME + "fqdn"

$PullServerConfigPath = "...\PullServer"
>>>>>>> master

# Compile the configuration
CreateDscPullServerHTTP -RegistrationKey $guid -OutputPath $PullServerConfigPath
# Run the compile configuration to make the target node a DSC Pull Server
Start-DscConfiguration -Path $PullServerConfigPath -Wait -Verbose -Force
# Show configuration results
Test-DscConfiguration
Get-DscConfigurationStatus
Get-DscConfiguration
# Check that the pull server application / site is accessible
Verify-DscPullServer -PullServerFqdn $fqdn
# Start-Sleep -Seconds 60
# Reboot to apply changes
# Restart-Computer -Force