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
# $thumbprint = '<>'
# $serverUrl = "...:8080/PSDSCPullServer.svc"
# $registrationKey = '<>'
# $configNames = @("httpsPullClientWeb")
$webMofPath = "...\mof"

PullClient -ID '<>' -Server '<>' -Output $webMofPath
Set-DscLocalConfigurationManager -ComputerName $clients -Path $webMofPath -Force -Verbose