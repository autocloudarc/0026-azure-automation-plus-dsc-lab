Import-Module SQLPS
$ServerName = "Pansatywin7"      #"PankajWin7"
$InstanceName = "Default"  #"Default"


$ConnectionString = "SQLSERVER:\SQL\"+$ServerName+"\"+$InstanceName+"\Databases"

dir $ConnectionString | %{$_.EnumBackupSets()} 
#dir $ConnectionString | %{$_.EnumBackupSets()} |Get-Member