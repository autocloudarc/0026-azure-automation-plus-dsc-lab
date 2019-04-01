Configuration CreateHTTPSPullServer
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xPSDesiredStateConfiguration, xWebAdministration
    
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            ConfigurationMode = "ApplyAndAutoCorrect"
            RebootNodeIfNeeded = $true
            ActionAfterReboot =  "ContinueConfiguration"
            AllowModuleOverwrite = $true
            CertificateID = $node.Thumbprint 
        } # end lcm
        
        # https://docs.microsoft.com/en-us/powershell/dsc/pull-server/secureserver
        # The next series of settings disable SSL and enable TLS, for environments where that is required by policy.
        Registry TLS1_2ServerEnabled
        {
            Ensure = 'Present'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'Enabled'
            ValueData = 1
            ValueType = 'Dword'
        } # end resource
        
        Registry TLS1_2ServerDisabledByDefault
        {
            Ensure = 'Present'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'DisabledByDefault'
            ValueData = 0
            ValueType = 'Dword'
        } # end resource

        Registry TLS1_2ClientEnabled
        {
            Ensure = 'Present'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'Enabled'
            ValueData = 1
            ValueType = 'Dword'
        } # end resource
        
        Registry TLS1_2ClientDisabledByDefault
        {
            Ensure = 'Present'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'DisabledByDefault'
            ValueData = 0
            ValueType = 'Dword'
        } # end resource
        
        Registry SSL2ServerDisabled
        {
            Ensure = 'Present'
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server'
            ValueName = 'Enabled'
            ValueData = 0
            ValueType = 'Dword'
        } # end resource

        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name = "DSC-Service"
        } # end resource

        xDSCWebService PSDSCPullServer
        {
            Ensure = "Present"
            EndpointName = "PSDSCPullServer"
            Port = 8080
            PhysicalPath = "c:\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint = 'B4BDD04D427DAA880FE1950A5CE9F83C93567E8D'
            ModulePath = "$($node.SMBShareModules)"
            ConfigurationPath = "$($node.SMBShareConfig)"
            State = "Started"
            UseSecurityBestPractices = $true 
            DisableSecurityBestPractices = "SecureTLSProtocols"
            DependsOn = "[WindowsFeature]DSCServiceFeature"
        } # end resource

        File RegistrationKeyFile
        {
            Ensure = "Present"
            Type = "File"
            DestinationPath = "C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents = "$($node.RegistrationKey)"
        } # end resource

        # Validate web config file contains current DB settings
        xWebConfigKeyValue CorrectDBProvider
        {
            ConfigSection = 'AppSettings'
            Key = 'dbprovider'
            Value = 'System.Data.OleDb'
            WebsitePath = 'IIS:\sites\PSDSCPullServer'
            DependsOn = '[xDSCWebService]PSDSCPullServer'
        } # end resource 

        xWebConfigKeyValue CorrectDBConnectionStr
        {
            ConfigSection = 'AppSettings'
            Key = 'dbconnectionstr'
            Value = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\Program Files\WindowsPowerShell\DscService\Devices.mdb;'
            WebsitePath = 'IIS:\sites\PSDSCPullServer'
            DependsOn = '[xDSCWebService]PSDSCPullServer'
        } # end resource

        # Stop the default website
        xWebsite StopDefaultSite
        {
            Ensure = 'Present'
            Name = 'Default Web Site'
            State = 'Stopped'
            PhysicalPath = 'C:\inetpub\wwwroot'
            DependsOn = '[WindowsFeature]DSCServiceFeature'
        } # end resource

        WindowsFeature IISMgmtGui 
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Console"
            DependsOn = "[xDscWebService]PSDSCPullServer"
        } # end resource

        WindowsFeature IISScripting
        {
            Ensure = "Present"
            Name = "Web-Scripting-Tools"
            DependsOn = "[xDSCWebService]PSDSCPullServer"
        } # end resource
    } # end node
} # end configuration

$ConfigDataPathPullSvr = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\PullServer\CreateHTTPSPullServerConfigData.psd1"
$mofPathPullSvr = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\mof"

CreateHTTPSPullServer -OutputPath $mofPathPullSvr -ConfigurationData $ConfigDataPathPullSvr
Start-DscConfiguration -Path $mofPathPullSvr -ComputerName localhost -Wait -Verbose -Force