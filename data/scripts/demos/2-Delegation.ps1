# These are some second hop credential test lines.

$cred = Get-Credential Contoso\Administrator

# This works with Kerberos General Delegation
Invoke-Command -ComputerName 2012R2-MS -Credential $cred -ScriptBlock {
    Test-Path \\2012R2-DC\C$
    Get-Process lsass -ComputerName 2012R2-DC
    Get-EventLog -LogName System -Newest 3 -ComputerName 2012R2-DC
}


# This works without delegation, passing fresh creds
Invoke-Command -ComputerName 2012R2-MS -Credential $cred -ScriptBlock {
    Invoke-Command -ComputerName 2012R2-DC -Credential $Using:cred -ScriptBlock {hostname}
}


# This works with general delegation
Invoke-Command -ComputerName 2012R2-MS -Credential $cred -ScriptBlock {
    Invoke-Command -ComputerName 2012R2-DC -ScriptBlock {hostname}
}


# This works without delegation
Invoke-Command -ComputerName 2012R2-MS -Credential $cred -ScriptBlock {
    $cim = New-CimSession -ComputerName 2012R2-DC -Credential $Using:cred
    Get-NetFirewallRule -CimSession $cim
    Remove-CimSession $cim
}





# These lines are from unsuccessful constrained delegation attempts

Get-ADComputer 2012R2-MS -Properties msDS-AllowedToDelegateTo | Select-Object -ExpandProperty msDS-AllowedToDelegateTo
Get-ADComputer 2012R2-DC -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName

Set-ADComputer 2012R2-DC -Add @{'ServicePrincipalName'=@('cifs/2012R2-DC.contoso.com/contoso.com','cifs/2012R2-DC.contoso.com','cifs/2012R2-DC','cifs/2012R2-DC.contoso.com/CONTOSO','cifs/2012R2-DC/CONTOSO')}
Set-ADComputer 2012R2-DC -Remove @{'ServicePrincipalName'=@('cifs/2012R2-DC.contoso.com/contoso.com','cifs/2012R2-DC.contoso.com','cifs/2012R2-DC','cifs/2012R2-DC.contoso.com/CONTOSO','cifs/2012R2-DC/CONTOSO')}
Set-ADComputer 2012R2-DC -Add @{'ServicePrincipalName'=@('WSMAN/2012R2-DC.contoso.com/contoso.com','WSMAN/2012R2-DC.contoso.com','WSMAN/2012R2-DC','WSMAN/2012R2-DC.contoso.com/CONTOSO','WSMAN/2012R2-DC/CONTOSO')}

Set-ADComputer 2012R2-MS -Add @{'msDS-AllowedToDelegateTo'=@('WSMAN/2012R2-DC.contoso.com/contoso.com','WSMAN/2012R2-DC.contoso.com','WSMAN/2012R2-DC','WSMAN/2012R2-DC.contoso.com/CONTOSO','WSMAN/2012R2-DC/CONTOSO')}
Set-ADComputer 2012R2-MS -Remove @{'msDS-AllowedToDelegateTo'=@('WSMAN/2012R2-DC.contoso.com/contoso.com','WSMAN/2012R2-DC.contoso.com','WSMAN/2012R2-DC','WSMAN/2012R2-DC.contoso.com/CONTOSO','WSMAN/2012R2-DC/CONTOSO')}
Set-ADComputer 2012R2-MS -Add @{'msDS-AllowedToDelegateTo'=@('cifs/2012R2-DC.contoso.com/contoso.com','cifs/2012R2-DC.contoso.com','cifs/2012R2-DC','cifs/2012R2-DC.contoso.com/CONTOSO','cifs/2012R2-DC/CONTOSO')}

Invoke-Command -ComputerName 2012R2-DC -ScriptBlock {klist purge}
Invoke-Command -ComputerName 2012R2-DC -ScriptBlock {klist}
Invoke-Command -ComputerName 2012R2-MS -ScriptBlock {klist purge}
Invoke-Command -ComputerName 2012R2-MS -ScriptBlock {klist}
