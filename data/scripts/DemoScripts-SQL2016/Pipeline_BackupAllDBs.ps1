Import-Module SQLPS
$ServerName = “sqladmin11clun1"
$InstanceName = “DEFAULT"
$ConnectionString = "SQLSERVER:\SQL\"+$ServerName+"\"+$InstanceName+"\Databases“

DIR $ConnectionString | ?{$_.Status -eq "Normal"} | Backup-SQLDatabase
