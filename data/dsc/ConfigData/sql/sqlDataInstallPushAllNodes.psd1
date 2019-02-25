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
            installFromPath = "C:\SqlServer2016x64"
            installFromPathRemote = "\\cltdev1001\apps\sql\SqlServer2016x64"
            instanceName = "MSSQLSERVER"
            sqlFeatures = "SQLENGINE"
            sqlSysAdminAccounts = "Administrators"
            sqlServiceAccount = "dev\svc.sql.user"
            loginType = "WindowsUser"
         } # end node
        @{
            NodeName = 'cltsql1003.dev.adatum.com'
            hostname = 'cltsql1003'
            CertificateFile = "F:\data\OneDrive\02.00.00.GENERAL\repos\0000-certs\eca\Request ID 11.cer"
            Thumbprint = "DC1E9EB7DF9D3337561A9EC907F2E8710D05B66E"
         } # end node
         @{
            NodeName = 'cltsql1001.dev.adatum.com'
            hostname = 'cltsql1001'
            CertificateFile = "F:\data\OneDrive\02.00.00.GENERAL\repos\0000-certs\eca\Request ID 15.cer"
            Thumbprint = "4807B69B4C47311A7B437E127B6EE59820B4E2B3"
         } # end node
         <#
         @{
            NodeName = 'cltsql1002.dev.adatum.com'
            hostname = 'cltsql1002'
            CertificateFile = "F:\data\OneDrive\02.00.00.GENERAL\repos\0000-certs\eca\Request ID 10.cer"
            Thumbprint = "7FE748522E299E193D8A3C641ACFBB9BC7108D05"
         } # end node
         #>
    ) # end array
} # end hashtable