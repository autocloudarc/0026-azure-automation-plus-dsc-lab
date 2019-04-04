Configuration SetClientTLSProtocolValues
{        
    Import-Module -Name PSDesiredStateConfiguration

    Node SetClientTLSProtocolValues
    {
        Registry TLS1_2ClientEnabled
        {
            Ensure = 'Absent'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'Enabled'
            ValueData = 1
            ValueType = 'Dword'
        } # end resource
        
        Registry TLS1_2ClientDisabledByDefault
        {
            Ensure = 'Absent'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'DisabledByDefault'
            ValueData = 0
            ValueType = 'Dword'
        } # end resource
    } # end node
} # end configuration

$webMofPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\PullClientsLCM\mof"
SetClientTLSProtocolValues -OutputPath $webMofPath -Verbose
# Start-DscConfiguration -Path $webMofPath -ComputerName "cltweb1001.dev.adatum.com", "cltweb1002.dev.adatum.com" -Wait -Verbose -Force