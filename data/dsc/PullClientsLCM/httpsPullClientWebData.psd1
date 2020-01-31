@{
    AllNodes = @(
        @{
            NodeName = '*'
            RegistrationKey = "<>"
            PullServerEndpoint = "...:8080/PSDSCPullServer.svc"
            ConfigNames = @('SetCilentTLSProtocolValues')
        } # end node
        @{
            NodeName = "<>"
            # CertificateFile = '...\*.cer'
            # (Get-ChildItem -Path cert:\LocalMachine\My | Where-Object {$_.EnhancedKeyUsageList.FriendlyName -contains 'Document Encryption'} | Select-Object -Property Thumbprint).Thumbprint
            Thumbprint = '<>'
        } # end node
        <#
        @{
            NodeName = "<>"
            # CertificateFile = '..\*.cer'
            # (Get-ChildItem -Path cert:\LocalMachine\My | Where-Object {$_.EnhancedKeyUsageList.FriendlyName -contains 'Document Encryption'} | Select-Object -Property Thumbprint).Thumbprint
            Thumbprint = '<>'
        } # end node
        #>
        )
    }