[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Push'
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
            CertificateID = '7E3E6985C82F57BAC1C5CC8ADB3C09B66CA0DDE0'
        } # end settings
    } # end noe
} # end configuration

LCMConfig -Verbose
Set-DscLocalConfigurationManager -Path .\LCMConfig -Verbose