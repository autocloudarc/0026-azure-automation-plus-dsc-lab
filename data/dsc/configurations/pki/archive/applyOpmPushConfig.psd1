@{
    AllNodes = @(
        # Configure the azrpki..01 dev server as an enterprise CA
        @{
            NodeName = "azrpki1001.dev.adatum.com"
            role = 'pki'
            eca = 'EnterpriseRootCA'
            singleInstance = 'Yes'
            ensure = 'Present'
            CACommonName = 'pki01'
            CADistinguishedNameSuffix = 'DC=dev,DC=adatum,DC=com'
            cryptoProvider = 'RSA#Microsoft Software Key Storage Provider'
            dbPath = 'F:\OneDrive\02.00.00.GENERAL\devServer\data\pki\db'
            hashAlgorithm = 'SHA256'
            keyLength = 4096
            logPath = 'F:\OneDrive\02.00.00.GENERAL\devServer\data\pki\logs'
            exportPath = 'F:\OneDrive\02.00.00.GENERAL\devServer\data\pki\cert\export'
            overwrite = $true
            periodUnits = 'Years'
            periodValue = 5
            fqdn = 'dev.adatum.com'
            DomainName = 'dev'
            PSDscAllowPlainTextPassword=$true
            PsDscAllowDomainUser = $true
        } # end hashtable
    ) # end array
} # end hashtable 