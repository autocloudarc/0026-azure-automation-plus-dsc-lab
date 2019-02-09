Function Test-ComputerName {
param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript({Test-Connection $_ -Count 1})]
    [String]
    $ComputerName
)
    $ComputerName
}

Test-ComputerName -ComputerName xyz
Test-ComputerName -ComputerName ''
Test-ComputerName -ComputerName 2012R2-MS


# Variable validation outside the parameter block
[ValidateScript({Test-Connection $_ -Count 1})]$COMPUTERNAME = '2012r2-ms'
