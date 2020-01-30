#Show Help on all cmdlets with alias in the cmdlet name
Get-Help *alias*
#List all the current Alias
Get-Alias
#Create a new alias gh for Get-Help
New-Alias gh Get-Help
#Confirm that gh is present
Get-Alias gh
#Remove the alias
Remove-Item alias:gh
#confirm it’s gone
Get-Alias gh
