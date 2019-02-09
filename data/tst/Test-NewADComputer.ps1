$instanceCount = 10
$ou = "OU=servers,DC=dev,DC=adatum,DC=com"
for ($i=1;$i -le $instanceCount;$i++)
{
    [string]$s = $i.ToString()
    if ($s.Length -lt 2)
    {
        $computerPrefix = "azrsvr100"
    } # end if
    else
    {
        $computerPrefix = "azrsvr10"
    } # end else
    $computerName = $computerPrefix + $s
    New-ADComputer -Name $computerName -SAMAccountName $computerName -Path $ou -WhatIf -Verbose
} # end for

