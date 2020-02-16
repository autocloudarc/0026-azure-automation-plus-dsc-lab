#Demo1 show the important details of Win32_Processor
$computer = "LocalHost" 
$namespace = "root\CIMV2" 
Get-WmiObject -class Win32_Processor -computername $computer -namespace $namespace |Select Name, NumberOfCores, NumberOfLogicalProcessors | FT

#Demo1 show the important details of Win32_Bios. Buildnumber will be blank for VMs
$computer = "LocalHost" 
$namespace = "root\CIMV2" 
Get-WmiObject -class Win32_BIOS -computername $computer -namespace $namespace | Select BuildNumber, Description | FT

#Demo3 show the important details of Win32_OperatingSystem
$computer = "LocalHost" 
$namespace = "root\CIMV2" 
Get-WmiObject -class Win32_OperatingSystem -computername $computer -namespace $namespace `
| Select CSName, OSArchitecture, BuildNumber, Caption, LastBootUpTime | FT

#Demo4 show the important details of the sqlservice class
# 1 Stopped. 2 Start Pending. 3 Stop Pending. 4 Running. 5 Continue Pending. 6 Pause Pending. 7 Paused. 
# http://technet.microsoft.com/en-us/library/ms182504.aspx
Get-WMIObject -class SqlService –namespace "root\Microsoft\SQLServer\ComputerManagement11" | Select-Object DisplayName, StartName, State |ft


