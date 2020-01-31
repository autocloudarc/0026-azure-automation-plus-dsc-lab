# https://stackoverflow.com/questions/41262835/powershell-dsc-client-cant-register-with-pull-server
# https://www.jfe.cloud/
# https://www.jfe.cloud/be-aware-of-dsc-pull-server-compatibility-issues-with-wmf-5-0-and-5-1/
# https://blogs.technet.microsoft.com/cmpfekevin/2016/09/18/schannel-ssl-and-tls-registry-keys-reporting/
[DscLocalConfigurationManager()]
Configuration httpsPullClientWeb
{
    Node '<>'
    {
        Settings
        {
            ConfigurationID = ''
            RefreshMode =  'Pull'
            ActionAfterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
            RebootNodeIfNeeded = $true 
            # CertificateID = '<>'
        } # end settings

        ConfigurationRepositoryWeb httpsPullSvcConfig 
        {
            ServerURL = "<>"
            RegistrationKey = "<>"
            ConfigurationNames = @('SetCilentTLSProtocolValues')
            # AllowUnsecureConnection = $false
        } # end resource
        ResourceRepositoryWeb httpsPullSvcResource
        {
            ServerURL = "<>"
            RegistrationKey = "<>"
        } # end resource
    } # end node
} # end configuration

# $clients = @('cltweb1001.dev.adatum.com','cltweb1002.dev.adatum.com')
$webMofPath = "<...\mof>"
$ConfigDataPath = "<...\*.psd1>"
# httpsPullClientWeb  -OutputPath $webMofPath -ConfigurationData $ConfigDataPath -Verbose
httpsPullClientWeb  -OutputPath $webMofPath -Verbose
Set-DscLocalConfigurationManager -Path $webMofPath -Force -Verbose