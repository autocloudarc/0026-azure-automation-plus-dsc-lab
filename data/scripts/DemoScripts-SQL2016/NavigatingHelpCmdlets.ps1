##Invoke-Sql-cmd cmdlet can be used to run SQL Scripts
#First we need to import the SQLPS module to access the SQL Server PowerShell #Cmdlets
#Demo Part 1
Import-Module SQLPS
Get-Help Invoke-Sqlcmd
##Try with the wild cards also
Get-Help Invoke-S*

#Demo Part 2
##Now let's get the full output to see the parameter attributes and examples
Get-Help Invoke-Sqlcmd -full

#Demo Part 3
##Now let's get the full output using help instead to page thru
Help Invoke-Sqlcmd -full

#Demo Part 4
invoke-sqlcmd "Select @@Version" –ServerI <ReplaceServerName> -Database '<ReplaceDBName>' 

#Demo Part 5
#SQLPS Module must be imported prior to running if ISE was closed out 
DIR ‘SQLServer:\SQL\<ReplaceServerName>\Default\Databases\<ReplaceDBName>’|Get-Member

#Demo Part 6
Get-Command | Where-Object {$_.CommandType -eq "CmdLet" -and $_.Module -like "sqlps"} | Format-Table Name, Module
