# Azure Automation Plus DSC lab

This template deploys a new lab environment that can be used for training, practice and demonstrations of the following technologies:

1. Azure Automation
2. Azure Automation Desired State Configuration
3. Windows PowerShell
4. Windows PowerShell Desired State Configuration
5. PowerShell Core 6.0
6. Powershell DSC for Linux.

## Prerequisites

Decscription of the prerequistes for the deployment

1. An Azure subscription
2. A web browser
3. Internet connection
4. Windows PowerShell Version 5.1
5. Member of local Windows Administrators group on the machine on which you will execute the PowerShell script.
6. During script execution, you will be asked to configure the PSGallery repository as a trusted source so that the required modules such as AzureRM can be used.

## After Deploying the Template (Usage)

Although particular scenario or specific sets of excercises are not provided as part of this project to practice these skills, listed here is the recommended outline of training objectives as a basic guide.
You may deviate, ommit, add or re-sequence these steps as necessary to meet your test/dev/training requirements.
Please NOTE that this project is primarily for training and NOT recommended for production.

1. Build the AZRDEV##01 server as a jump/dev DSC pull server using desired state configuration in local push configuration mode.
2. Build the AZRWEB##01 web server as a web server using push mode remotely from AZRDEV##01.
3. Build the AZRADS##01 domain controller as a domain controller using push mode remotely from AZRDEV##01.
4. Build the AZRSQL##01 SQL 2016 server as an SQL server using push mode remotely from AZRDEV##01.
5. Apply a configuration to AZRWEB##01 using the DSC Pull server AZRDEV##01.
6. Apply a configuration to AZRADS##01 using the DSC Pull server AZRDEV##01.
7. Apply a configuration to AZRSQL##01 using the DSC Pull server AZRDEV##01.
8. Build the AZRWEB##02 web server as a web server using Azure Automation DSC (AA DSC).
9. Build the AZRADS##02 domain controller as a domain controller using AA DSC.
10. Build the AZRSQL##02 SQL 2016 server as an SQL server using AA DSC.
11. Apply a configuration to the AZRLNX##01 Linux CentOS server using the push mode remotely from AZRDEV##01.
12. Apply a configuration to the AZRLNX##01 Linux CentOS server using AA DSC.
13. Create a runbook to convert all server private IP addresses from dynamic to static.

Here are some references for Azure Automation, PowerShell and Desired State Configuration that can be used during your learning and exploration of these topics.

LINKS

1. Azure Automation: <https://docs.microsoft.com/en-us/azure/>
2. Desired State Configuration: <https://docs.microsoft.com/en-us/powershell/dsc/overview>
3. Desired State Configuration for Linux: <https://docs.microsoft.com/en-us/powershell/dsc/lnxgettingstarted>
4. Powershell Core: <https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-core-60?view=powershell-6>
5. Example Scenario: <https://blogs.technet.microsoft.com/askpfeplat/2017/10/16/windows-powershell-and-dsc-on-linux-in-microsoft-azure/>

BOOKS

1. Windows PowerShell in Action, 3rd Edition – Bruce Payette & Richard Siddaway (There’s a chapter on DSC)
2. Windows PowerShell Desired State Configuration Revealed – Ravikanth Chaganti
3. Learning PowerShell DSC – James Pogran
4. PowerShell 5.1 and Desired State Configuration – Ron Davis

The lab infrastructure includes the following components:

1. 1 x resource group named rgAdatumDev##, where ## represents a one or two-digit number between 0 to 16.
2. 3 x Windows 2016 Data Center Core domain controllers
3. 1 x Widnows 2016 Data Center Development/Jump/DSCPull/DSCPush server w/the Visual Studio 2017 Community Edition VM image.
4. 2 x Windows 2016 Data Center Core servers, initially deployed as standalone servers but which can be configured after deployment as web servers using DSC.
5. 2 x Widnows 2016 Data Center servers, initially deployed as standalone servers but which can be configured after deployment as SQL 2016 servers using DSC.
6. 1 x CentOS 7 server, which can be used to demonstrate or practice PowerShell Core 6.0 or PowerShell DSC for Linux concepts.
7. 1 x Automation account for Azure automation topics
8. 1 x OMS Workspace for Runbook monitoring integration
9. 2 x storage accounts, 1 for automatically staging deployment artifacts and the other for user specified artifacts for DSC.
10. 1 x recovery services vault for VM backup and recovery.

## Deploying The Template

1. Download the Deploy-AzureResourceGroup.ps1 and execute.
    Example (from current directory) .\Deploy-AzureResourceGroup

## Connect

To connect to this lab after it is deployed, RDP to the development/jump server AZRDEV##01 VM using the connect icon from the VM overview blade in the portal.
The username to use is: .\adm.infra.user.

### Management

To complete the recommended training objectives after this solution is deployed, you can either RDP to the AZRDEV##01 jump VM and use the Azure portal to configure any of the Azure Automation components.

## Notes

1. *This solution does not include a hybrid connection to an on-premises environment.*
2. *All Windows VMs are domain joined during the deployment.*

## Tags

`Tags: Azure, Automation, Powershell, DSC`