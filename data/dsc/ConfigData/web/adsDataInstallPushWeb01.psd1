@{
    AllNodes = @(
        # Configure the ...01 DC only
        @{
            NodeName = '<>'
            role = "ads"
            fqdn = '<>'
            DomainName = '<>'
            dataDiskNumber = '2'
            retryCount = 3
            retryIntervalSec = 10
            dataDiskDriveLetter = 'F'
            FSFormat = 'NTFS'
            FSLabel = 'DATA'
            certificateFile = ""
            thumbprint = "<>"
            PsDscAllowDomainUser = $true
            ntdsPathSuffix = ":\NTDS"
            logsPathSuffix = ":\LOGS"
            sysvPathSuffix = ":\SYSV"
         } # end hashtable
    ) # end array
} # end hashtable