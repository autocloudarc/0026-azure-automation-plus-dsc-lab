### Put a Start-Transcript in the PSSC file to "audit" remote activity.
### Disable the cmdlet Stop-Transcript.

### Run from 2012R2-MS

# Create Session Configuration File
New-PSSessionConfigurationFile -Path .\restricted.pssc -SessionType RestrictedRemoteServer

# Manipulate/View Configuration File
notepad .\restricted.pssc

# Associate Configuration File with Remote Endpoint
Register-PSSessionConfiguration -Path .\restricted.pssc -Name myRestrictedConfig

# Set Account Access Permissions
Set-PSSessionConfiguration -Name myRestrictedConfig -ShowSecurityDescriptorUI

# List the session configurations
Get-PSSessionConfiguration | ogv


# Clean up afterward
Unregister-PSSessionConfiguration myRestrictedConfig
Remove-Item .\restricted.pssc



### Run from WIN8-WS as DanPark

whoami

# No access to default session configuration
Enter-PSSession -ComputerName 2012R2-MS

# Restricted access to custom session configuration
Enter-PSSession -ComputerName 2012R2-MS -ConfigurationName myRestrictedConfig

# Get-Command
# Exit-PSSession

