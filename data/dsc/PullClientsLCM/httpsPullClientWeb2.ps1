# https://docs.microsoft.com/en-us/powershell/dsc/pull-server/secureserver#verify-pull-server-functionality
Configuration PullClient 
{
    param 
    (
        [string] $ID,
        [string] $Server
    ) # end param
        LocalConfigurationManager
        {
            ConfigurationID = $ID;
            RefreshMode = 'PULL';
            DownloadManagerName = 'WebDownloadManager';
            RebootNodeIfNeeded = $true;
            RefreshFrequencyMins = 30;
            ConfigurationModeFrequencyMins = 15;
            ConfigurationMode = 'ApplyAndAutoCorrect';
            DownloadManagerCustomData = @{ServerUrl = "http://"+$Server+":8080/PSDSCPullServer.svc"; AllowUnsecureConnection = $true}
        } # end LCM
} # end configuration
$clients = @("cltweb1001.dev.adatum.com","cltweb1002.dev.adatum.com")
<<<<<<< HEAD
# $thumbprint = '37D4A4FF049E2E5CC24D7C4170F1F92306739AA1'
# $serverUrl = "https://cltdev1001.dev.adatum.com:8080/PSDSCPullServer.svc"
# $registrationKey = '2a5de1da-82c6-491f-80ec-7a64829a965a'
# $configNames = @("httpsPullClientWeb")
$webMofPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\PullClientsLCM\mof"

PullClient -ID '814b7621-d660-467d-9fec-df8d7824b348' -Server 'cltdev1001.dev.adatum.com' -Output $webMofPath
=======
# $thumbprint = '<>'
# $serverUrl = "...:8080/PSDSCPullServer.svc"
# $registrationKey = '<>'
# $configNames = @("httpsPullClientWeb")
$webMofPath = "...\mof"

PullClient -ID '<>' -Server '<>' -Output $webMofPath
>>>>>>> master
Set-DscLocalConfigurationManager -ComputerName $clients -Path $webMofPath -Force -Verbose