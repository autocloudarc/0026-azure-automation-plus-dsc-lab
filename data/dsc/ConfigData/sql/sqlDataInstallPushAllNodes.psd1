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
            dataDiskNumber = '1'
            logsDiskNumber = '2'
            tempDiskNumber = '3'
            mstrDiskNumber = '4'
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
            installFromPath = "C:\SqlServer2017x64trial"
            installFromPathRemote = "\\<server>\SqlServer2017x64trial"
            instanceName = "MSSQLSERVER"
            sqlFeatures = @("SQLENGINE","MDS")
            sqlSysAdminAccounts = "Administrators"
            sqlServiceAccount = "dev\svc.sql.user"
            loginType = "WindowsUser"
         } # end node
        @{
            NodeName = '<>.dev.adatum.com'
            hostname = '<>'
            CertificateFile = "..\*.cer"
            Thumbprint = "<>"
         } # end node
         @{
            NodeName = '<>.dev.adatum.com'
            hostname = '<>'
            CertificateFile = "*\.cer"
            Thumbprint = "<>"
         } # end node
         @{
            NodeName = '<>.dev.adatum.com'
            hostname = '<>'
            CertificateFile = "...\.cer"
            Thumbprint = "<>"
         } # end node
    ) # end array
} # end hashtable