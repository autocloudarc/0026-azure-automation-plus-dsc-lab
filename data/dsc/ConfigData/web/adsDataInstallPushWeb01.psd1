@{
    AllNodes = @(
        # Configure the ...01 DC only
        @{
            NodeName = 'azrweb1001.dev.adatum.com'
            role = "ads"
            fqdn = 'dev.adatum.com'
            DomainName = 'dev'
            dataDiskNumber = '2'
            retryCount = 3
            retryIntervalSec = 10
            dataDiskDriveLetter = 'F'
            FSFormat = 'NTFS'
            FSLabel = 'DATA'
            certificateFile = ""
            thumbprint = "ECEA3A754E391ED4C238A481938D5EF6A8C90CC0"
            PsDscAllowDomainUser = $true
            ntdsPathSuffix = ":\NTDS"
            logsPathSuffix = ":\LOGS"
            sysvPathSuffix = ":\SYSV"
         } # end hashtable
    ) # end array
} # end hashtable