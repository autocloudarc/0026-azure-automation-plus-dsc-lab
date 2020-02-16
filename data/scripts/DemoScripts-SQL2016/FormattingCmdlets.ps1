#NOTE if your servername is anything other that SQLADMIN11Clun1, do a find and replace for this instancename.

Import-Module SQLPS

#Demo Format-Table cmdlet. Alias ft
invoke-sqlcmd "Select * from sys.dm_exec_connections" -ServerInstance sqladmin11clun1 | ft

#Demo Format-List cmdlet. Alias fl
invoke-sqlcmd "Select * from sys.dm_exec_connections" -ServerInstance sqladmin11clun1 | fl

#Demo Out-GridView cmdlet. No Alias.... But you can define one...
DIR ‘SQLServer:\SQL\SQLAdmin11Clun1\Default\Databases\Adventureworks2012’|Get-Member|Out-Gridview


