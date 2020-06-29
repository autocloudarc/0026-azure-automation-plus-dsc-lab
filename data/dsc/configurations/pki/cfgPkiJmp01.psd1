@{
    AllNodes = @(
        # Configure the azrpki..01 dev server as an enterprise CA
        @{
            NodeName = "localhost"
            role = 'pki'
            diskId = '2'
            diskDriveLetter = 'f'
            fslabel = 'data'
            fileType = 'Directory'
            pkiPath = 'f:\pki'
            CertificateFile = "F:\nodeCert\hubdevjmp01-nodeCert.cer"
            Thumbprint = "7E3E6985C82F57BAC1C5CC8ADB3C09B66CA0DDE0"
            eca = 'EnterpriseRootCA'
            singleInstance = 'Yes'
            ensure = 'Present'
            CACommonName = 'pki01'
            CADistinguishedNameSuffix = 'DC=autocloudarc,DC=ddns,DC=net'
            cryptoProvider = 'RSA#Microsoft Software Key Storage Provider'
            dbPath = 'f:\pki\db'
            hashAlgorithm = 'SHA256'
            keyLength = 4096
            logPath = 'f:\pki\log'
            exportPath = 'f:\pki\export'
            overwrite = $true
            periodUnits = 'Years'
            periodValue = 2
            fqdn = 'autocloudarc.ddns.net'
            DomainName = 'autocloudarc'
            PSDscAllowPlainTextPassword=$false
            PsDscAllowDomainUser = $true
        } # end hashtable
    ) # end array
} # end hashtable