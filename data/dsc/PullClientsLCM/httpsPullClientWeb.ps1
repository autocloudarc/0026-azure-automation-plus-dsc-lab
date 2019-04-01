[DscLocalConfigurationManager()]
Configuration httpsPullClientWeb
{
    param 
    (
        [string[]] $clients,
        [string] $thumbprint,
        [string] $serverUrl,
        [string] $RegistrationKey,
        [string[]] $configNames 
    ) # end param

    Node $clients
    {
        Settings
        {
            RefreshMode =  'Pull'
            ActionAfterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
            RebootNodeIfNeeded = $true 
            CertificateID = $node.Thumbprint
        } # end settings

        ConfigurationRepositoryWeb httpsPullSvcConfig 
        {
            ServerURL = $serverUrl
            RegistrationKey = $RegistrationKey
            ConfigurationNames = $configNames
        } # end resource
        ResourceRepositoryWeb httpsPullSvcResource
        {
            ServerURL = $serverUrl
            RegistrationKey = $RegistrationKey
        } # end resource
    } # end node
} # end configuration

$clients = @("cltweb1001.dev.adatum.com","cltweb1002.dev.adatum.com")
$thumbprint = '37D4A4FF049E2E5CC24D7C4170F1F92306739AA1'
$serverUrl = "https://cltdev1001.dev.adatum.com:8080/PSDSCPullServer.svc"
$registrationKey = "2a5de1da-82c6-491f-80ec-7a64829a965a"

$webMofPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\PullClientsLCM\mof"
# $ConfigDataPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\PullClientsLCM\httpsPullClientWebData.psd1"
httpsPullClientWeb -OutputPath $webMofPath -clients $clients -thumbprint $thumbprint -serverUrl $serverUrl -RegistrationKey $registrationKey -Verbose
Set-DscLocalConfigurationManager -Path $webMofPath -ComputerName $clients -Force -Verbose