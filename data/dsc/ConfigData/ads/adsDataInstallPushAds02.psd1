@{
    AllNodes = @(
        # Configure the ...01 DC only
        @{
            NodeName = 'azrads1002.dev.adatum.com'
            dscNodeCertThumbprint = "‎47a6934f0a7a894aef988c5708c4554e1c4a5a28"
	        CertificateFile = "c:\dscNodeCert\AZRADS1001-dscNodeCert.cer"
            role = "ads"
            fqdn = 'dev.adatum.com'
            DomainName = 'dev'
            dataDiskNumber = '2'
            retryCount = 3
            retryIntervalSec = 10
            dataDiskDriveLetter = 'F'
            FSFormat = 'NTFS'
            FSLabel = 'DATA'
            PSDscAllowPlainTextPassword=$true
            PsDscAllowDomainUser = $true
            ntdsPathSuffix = ":\NTDS"
            logsPathSuffix = ":\LOGS"
            sysvPathSuffix = ":\SYSV"
         } # end hashtable
    ) # end array
} # end hashtable