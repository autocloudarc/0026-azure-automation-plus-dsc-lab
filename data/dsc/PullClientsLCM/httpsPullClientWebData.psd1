@{
    AllNodes = @(
        @{
            NodeName = '*'
            RegistrationKey = "2a5de1da-82c6-491f-80ec-7a64829a965a"
            PullServerEndpoint = "https://cltdev1001.dev.adatum.com:8080/PSDSCPullServer.svc"
            ConfigNames = @("web")
        } # end node
        @{
            NodeName = "cltweb1001.dev.adatum.com"
            # CertificateFile = 'F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\pki\cert\export\cltweb1001-DocEnc.cer'
            # (Get-ChildItem -Path cert:\LocalMachine\My | Where-Object {$_.EnhancedKeyUsageList.FriendlyName -contains 'Document Encryption'} | Select-Object -Property Thumbprint).Thumbprint
            Thumbprint = '37D4A4FF049E2E5CC24D7C4170F1F92306739AA1'
        } # end node
        @{
            NodeName = "cltweb1002.dev.adatum.com"
            # CertificateFile = 'F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\pki\cert\export\cltweb1001-DocEnc.cer'
            # (Get-ChildItem -Path cert:\LocalMachine\My | Where-Object {$_.EnhancedKeyUsageList.FriendlyName -contains 'Document Encryption'} | Select-Object -Property Thumbprint).Thumbprint
            Thumbprint = 'E9A89257C9F528E4507F51CEED789963B9A665F0'
        } # end node
        )
    }