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
            `
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
            CertificateThumbPrint = $node.Thumbprint
            ModulePath = $node.SMBShareModules
            ConfigurationPath = $node.SMBShareConfig
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

$ConfigDataPathPullSvr = "...\*.psd1"
$mofPathPullSvr = "...\mof"

CreateHTTPSPullServer -OutputPath $mofPathPullSvr -ConfigurationData $ConfigDataPathPullSvr
Start-DscConfiguration -Path $mofPathPullSvr -ComputerName localhost -Wait -Verbose -Force
# https://www.starwindsoftware.com/blog/how-to-build-a-secure-powershell-dsc-pull-server
# https://docs.microsoft.com/en-us/powershell/dsc/pull-server/secureserver#verify-pull-server-functionality 
Start-Process -FilePath iexplore.exe https://cltdev1001.dev.adatum.com:8080/PSDSCPullServer.svc/ 
function Verify-DSCPullServer ($fqdn) {
    ([xml](Invoke-WebRequest "https://$($fqdn):8080/psdscpullserver.svc" | % Content)).service.workspace.collection.href
}

Verify-DSCPullServer '<>'