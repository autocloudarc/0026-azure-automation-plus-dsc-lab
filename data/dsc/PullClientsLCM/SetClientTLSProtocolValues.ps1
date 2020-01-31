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

$webMofPath = "...\mof"
SetClientTLSProtocolValues -OutputPath $webMofPath -Verbose
# Start-DscConfiguration -Path $webMofPath -ComputerName "<>", "<>" -Wait -Verbose -Force