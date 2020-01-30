@{
    AllNodes = @(
        # Configure the ...01 DC only
        @{
            NodeName = 'azrads1001.dev.adatum.com'
            <#
                Although the thumbprint value, when viewed directly from the certificate store in the certificates mmc console shows lowercase,
                the value below must be in upper case to avoid the following error:
                The Certificate ID is not valid: '‎47a6934f0a7a894aef988c5708c4554e1c4a5a28'
                + CategoryInfo          : InvalidArgument: (root/Microsoft/...gurationManager:String) [], CimException
                + FullyQualifiedErrorId : MI RESULT 4
                + PSComputerName        : AZRADS1001.dev.adatum.com
                The Certificate ID is not valid: '‎47a6934f0a7a894aef988c5708c4554e1c4a5a28'
                + CategoryInfo          : InvalidArgument: (root/Microsoft/...gurationManager:String) [], CimException
                + FullyQualifiedErrorId : MI RESULT 4
                + PSComputerName        : AZRADS1001.dev.adatum.com
            #>
            dscNodeCertThumbprint = "47A6934F0A7A894AEF988C5708C4554E1C4A5A28"
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