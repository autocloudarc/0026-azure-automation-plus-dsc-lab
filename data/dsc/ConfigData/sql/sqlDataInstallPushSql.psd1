@{
    AllNodes = @(
        @{
            NodeName = '*'
            fqdn = 'dev.adatum.com'
            DomainName = 'dev'
            retryCount = 3
            retryIntervalSec = 10
            PSDscAllowPlainTextPassword=$true
            PsDscAllowDomainUser = $true
            FSFormat = 'NTFS'
            dataDiskNumber = '2'
            logsDiskNumber = '3'
            tempDiskNumber = '4'
            mstrDiskNumber = '5'
            dataFsLabel = "data"
            logsFsLabel = "logs"
            tempFsLabel = "temp"
            mstrFsLabel = "mstr"
            dataPathSuffix = ":\data"
            logsPathSuffix = ":\logs"
            tempPathSuffix = ":\temp"
            mstrPathSuffix = ":\mstr"
            dataDiskDriveLetter = 's'
            logsDiskDriveLetter = 'l'
            tempDiskDriveLetter = 't'
            mstrDiskDriveLetter = 'm'
            SqlSvcStartupType = "Automatic"
            SQLUserDBDir = "s:\data"
            SQLUserDBLogDir = "l:\logs"
            SQLTempDBDir = "t:\temp"
            SQLTempDBLogDir = "l:\logs"
            InstallSQLDataDir = "m:\mstr"
            SQLBackupDir = "c:\bckp"
            role = "sql"
            installFromPath = "C:\sql2016"
            instanceName = "MSSQLSERVER"
            sqlFeatures = "SQLENGINE"
            sqlSysAdminAccounts = "Administrators"
         } # end node
        @{
            NodeName = 'cltsql1003.dev.adatum.com'
         } # end hashtable
    ) # end array
} # end hashtable