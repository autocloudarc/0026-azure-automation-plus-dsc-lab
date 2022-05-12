<#
.SYNOPSIS
Installs Windows Features and chocolatey

.DESCRIPTION
This script is designed to be used as an Azure custom script extension that will install the Active Directory Tools, the Active Directory PowerShell modules and Chocolatey on a Windows VM.

PRE-REQUISITES:

.EXAMPLE
[Test deployment]
.\Install-AppsAndFeatures.ps1

.INPUTS
None

.OUTPUTS
The outputs generated from this script includes:
1. The specified Windows features and Chocolatey package manager application will be installed.

.NOTES

CONTRIBUTORS
1. Preston K. Parsard

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.LINK
1. https://stackoverflow.com/questions/35773299/how-can-you-export-the-visual-studio-code-extension-list

.COMPONENT
Azure Infrastructure, PowerShell, ARM, JSON

.ROLE
Automation Engineer
DevOps Engineer
Azure Engineer
Azure Administrator
Azure Architect

.FUNCTIONALITY
Installs Windows Features and Apps

#>

<#
TASK-ITEMS:
#>

Install-WindowsFeature -Name RSAT-AD-PowerShell
Install-WindowsFeature -Name RSAT-ADDS -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature -Name GPMC
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

choco install powershell-core --yes
choco install terraform --yes
choco install git --yes
choco install vscode.install --yes
code --install-extension hashicorp.terraform
code --install-extension 4ops.terraform
code --install-extension alefragnani.numbered-bookmarks
code --install-extension hashicorp.terraform
code --install-extension ms-vscode.powershell

# Create a new directory to clone repos into
New-Item -Path $env:systemdrive\git -ItemType Directory -Force 
