break

cd C:\PShell\Demos\

<#

* * * Constrained Endpoint * * *
Connect as DanPark
Run as Administrator
Use modules Storage, SMBShare
Limit to Get-* cmdlets/functions
Filesystem provider needed for SMBShare module
* * * * * * * * * * * * * * * * *
#>


# Create the configuration file
New-PSSessionConfigurationFile `
    -Path .\ViewDisksAndShares.pssc `
    -ModulesToImport Storage,SMBShare,Microsoft.PowerShell.Management `
    -SessionType RestrictedRemoteServer `
    -VisibleCmdlets 'Sort-Object','Where-Object','ForEach-Object','Get-ChildItem','Get-Item','Set-Location' `
    -VisibleFunctions 'Get-*Disk*','Get-*Volume*','Get-*Partition*','Get-SMB*' `
    -VisibleProviders 'FileSystem'

# Edit the file
ise .\ViewDisksAndShares.pssc

# Test for syntax errors
Test-PSSessionConfigurationFile .\ViewDisksAndShares.pssc

# Register the session configuration
Register-PSSessionConfiguration `
    -Name ViewDisksAndShares `
    -Path .\ViewDisksAndShares.pssc `
    -ShowSecurityDescriptorUI `
    -RunAsCredential (Get-Credential -Credential Contoso\Administrator) `
    -Force -Confirm:$false

# Test the session configuration
Enter-PSSession -ComputerName . -ConfigurationName ViewDisksAndShares -Credential contoso\danpark

Get-Command
Get-Disk
Get-Volume
Get-SmbShare

Exit-PSSession

Unregister-PSSessionConfiguration -Name ViewDisksAndShares -Force
Remove-Item -Path .\ViewDisksAndShares.pssc -Force
