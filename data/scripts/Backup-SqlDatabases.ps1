# https://blog.sqlauthority.com/2016/04/23/powershell-script-backup-every-database-sql-server/
$SQLInstance = "."
$BackupFolder = "C:\bckp"
 
$timeStamp = Get-Date -format yyyy_MM_dd_HHmmss 
 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
 
$srv = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SQLInstance
$dbs = New-Object Microsoft.SqlServer.Management.Smo.Database 
$dbs = $srv.Databases | Where-Object {$_.Name -notmatch 'tempdb'}
 
foreach ($Database in $dbs) 
{ 
 $Database.name 
 $bk = New-Object ("Microsoft.SqlServer.Management.Smo.Backup") 
 $bk.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database 
 $bk.BackupSetName = $Database.Name + "_backup_" + $timeStamp
 $bk.Database = $Database.Name 
 $bk.CompressionOption = 1 
 $bk.MediaDescription = "Disk"
 $bk.Devices.AddDevice($BackupFolder + "\" + $Database.Name + "_" + $timeStamp + ".bak", "File") 
  
TRY {
 $bk.SqlBackup($srv)
 } 
CATCH 
 {
 $Database.Name + " backup failed."
 $_.Exception.Message
 } 
} 