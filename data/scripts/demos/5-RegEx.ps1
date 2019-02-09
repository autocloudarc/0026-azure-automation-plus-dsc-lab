###############################################################################

'Get the keyword out of here.' -match 'keyword'

$Matches

'Get the keyword out of here.' -split 'keyword'
'Get the keyword out of here.' -replace 'keyword','otherword'

###############################################################################

$text = 'Now it the time for all good 614-555-1212men to come 123-45-6789to the aid of their country.'

$text -match '(?<SSN>\d{3}-\d{2}-\d{4})'

$Matches
$Matches[0]       # Overall regex match
$Matches['SSN']   # Named group

$text -match '(?<Phone>\d{3}-\d{3}-\d{4})'

$Matches
$Matches[0]       # Overall regex match
$Matches['Phone']   # Named group

###############################################################################

notepad .\NetSetup.LOG

Select-String -Path .\NetSetup.LOG -Pattern "error"                 # Regular expression
Select-String -Path .\NetSetup.LOG -Pattern "error" -SimpleMatch    # String only

Select-String -Path .\NetSetup.LOG -Pattern "$':"                 # Regular expression (invalid)
Select-String -Path .\NetSetup.LOG -Pattern "$':" -SimpleMatch    # String only

Select-String -Path .\NetSetup.LOG -Pattern "(?<Server>'\\\\\S+')"
Select-String -Path .\NetSetup.LOG -Pattern "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
Select-String -Path .\NetSetup.LOG -Pattern "0x\d{2,8}"

###############################################################################

(ipconfig) -match "(?<IPv4>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
(ipconfig) -match "(?<IPv6>\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4})"
(ipconfig) -match "(?<IPv4>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|(?<IPv6>\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4}\:\S{0,4})"
(ping 2012r2-ms -n 1) -match "(?<IPv4>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"

###############################################################################

[regex] | gm -Static -Name matches | select definition | ft -wrap
[System.Text.RegularExpressions.RegexOptions] | gm -Static

###############################################################################

