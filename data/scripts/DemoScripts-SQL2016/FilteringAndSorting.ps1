#NOTE: If your instance name is not SQLADMIN11Clun1, you need to perform a find and replace with your instance name
Import-Module SQLPS

#Demo using the Where-Object
get-service |?{($_.displayname -like "*sql*") -and ($_.status -eq "Running")}
#Demo Select-Object
DIR 'SQLServer:\SQL\SQLAdmin11Clun1\Default\Databases\Adventureworks2012\Tables' | Select Name, RowCount
#Demo Sort-Object
DIR 'SQLServer:\SQL\SQLAdmin11Clun1\Default\Databases\Adventureworks2012\Tables' | Select Name, RowCount | sort –property rowcount-descending
