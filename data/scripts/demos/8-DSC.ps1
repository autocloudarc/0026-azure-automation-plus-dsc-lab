#Requires -RunAsAdministrator 

Break

Set-Location C:\PShell\Demos2

# The module that makes DSC possible
Get-Command -Module PSDesiredStateConfiguration

# Engine status
Get-DscLocalConfigurationManager

# No configuration applied
Get-DscConfiguration

# CTRL-J and select DSC Configuration (simple)
# Use CTRL-SPACE to invoke Intellisense on the resource keywords to find out their syntax

Configuration MyFirstConfig
{
    Node localhost
    {
        Registry RegImageID {
            Key = 'HKLM:\Software\Contoso'
            ValueName = 'ImageID'
            ValueData = '42'
            ValueType = 'DWORD'
            Ensure = 'Present'
        }

        Registry RegAssetTag {
            Key = 'HKLM:\Software\Contoso'
            ValueName = 'AssetTag'
            ValueData = 'A113'
            ValueType = 'String'
            Ensure = 'Present'
        }

        Registry RegDecom {
            Key = 'HKLM:\Software\Contoso'
            ValueName = 'Decom'
            ValueType = 'String'
            Ensure = 'Absent'
        }

        Service Bits {
            Name = 'Bits'
            State = 'Running'
        }

    }
}

# Generate the MOF
MyFirstConfig

# View the MOF
Get-ChildItem .\MyFirstConfig
notepad .\MyFirstConfig\localhost.mof

# Check state manually
Get-ItemProperty HKLM:\Software\Contoso\
Get-Service BITS

# Check state with cmdlet
Test-DscConfiguration

# Sets it the first time
Start-DscConfiguration -Wait -Verbose -Path .\MyFirstConfig

# Check state manually
Get-Item HKLM:\Software\Contoso\
Get-Service BITS

# View the config of the system
Get-DscConfiguration

# Check state with cmdlet
Test-DscConfiguration

# Change the state
Set-ItemProperty HKLM:\Software\Contoso\ -Name ImageID -Value 12
New-ItemProperty HKLM:\Software\Contoso\ -Name Decom -Value True
Stop-Service Bits

# Check state manually
Get-Item HKLM:\Software\Contoso\
Get-Service BITS

# View the config of the system
Get-DscConfiguration

# Do I have the registry key? Is the value correct?
Test-DscConfiguration

# Reset the state
Start-DscConfiguration -Wait -Verbose -Path .\MyFirstConfig

# Check state manually
Get-Item HKLM:\Software\Contoso\
Get-Service BITS

# View the config of the system
Get-DscConfiguration

# Check state with cmdlet
Test-DscConfiguration




# Reset demo
Remove-Item C:\Windows\System32\Configuration\Current.mof, C:\Windows\System32\Configuration\backup.mof, C:\Windows\System32\Configuration\Previous.mof
Remove-Item HKLM:\Software\Contoso
Remove-Item .\MyFirstConfig -Recurse -Force -Confirm:$false
Stop-Service Bits
