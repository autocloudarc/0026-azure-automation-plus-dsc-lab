# 1.0 Azure Automation Plus DSC lab

This template deploys a new lab environment that can be used for training, practice and demonstrations for the following topics:

1. Azure Automation
2. Azure Automation Desired State Configuration
3. Windows PowerShell (version 5.1)
4. Windows PowerShell Desired State Configuration
5. PowerShell PowerShell version 7.x
6. Powershell DSC for Linux

## Target State Diagram

![Target state diagram](https://github.com/autocloudarc/0026-azure-automation-plus-dsc-lab/blob/master/images/0026-lab-diagram.png)

## 2.0 Prerequisites

Decscription of the prerequistes for the deployment

1. An Azure subscription
2. A web browser
3. An Internet connection
4. Windows PowerShell Version 5.1
5. Membership in the local Administrators group on the machine on which you will execute the PowerShell script.
6. The password required must be at least 12 characters and meet complexity requirements, i.e. 3 out of 4 of upper case, lower case, numeric and special characters.

## 3.0 Lab Infrastructure

The lab infrastructure includes the following components:

1. 1 x resource group named rg##, where ## in this document represents a one or two-digit number between 10 t6, and reflects the student number you specify during deployment.

2. 3 x Windows 2019 Data Center Core domain controllers, where only 1 has been promoted to a domain controller: AZRADS##03.dev.adatum.com.
   Both AZRADS##01 & AZRADS##02 are optional based on the value of the -excludeAds parameter and are initially deployed only as member servers until you promote them.

3. 1 x Widnows 2019 Data Center Development/Jump/DSCPull/DSCPush server w/the Visual Studio 2019 Community Edition VM image. This will be AZRDEV##01.dev.adatum.com.

4. 2 x Windows 2019 Data Center Core servers, initially deployed as standalone servers but which can be configured after deployment as web servers using DSC. These are AZRWEB##01 and AZRWEB##02.

5. 2 x Widnows 2019 Data Center servers (without the SQL image), initially deployed as standalone servers but which can be configured after deployment as SQL 2019 servers using DSC. These are AZRSQL##01 and AZRSQL##02.

6. 1 x CentOS 7 server (optional based on the value of the -includeCentOS parameter), which can be used to demonstrate or practice PowerShell Core 6.0 or PowerShell DSC for Linux concepts. This is AZRLNX##01.

7. 1 x Ubuntu 18.04 server (optional based on the value of the -includeUbuntu parameter), that can also be used as an additional Linux workload if necessary.

8. 1 x Windows 2019 Data Center with GUI PKI server (optional based on the value of the -excludePki parameter). This is really just a base Windows VM image that you can also practice configuring as a PKI server.

9.  1 x Automation account for Azure automation topics. This resource is named aaa-{studentRandomInfix}-##.

10. 1 x OMS Workspace for Runbook monitoring integration, named oms-{studentRandomInfix}-##.

11. 1 x storage account used for boot diagnostics and diagnostics logging for each VM. The name will be globally unique in DNS if you deploy from the Powershell script

12. 1 x recovery services vault for VM backup and recovery.

## 4.0 Deploying The Template

Windows PowerShell

1. Clone or download the Deploy-AzureResourceGroup.ps1 to a directory where you want to execute the script from.

2. Open your favorite Windows PowerShell host as an administrative user. You can use Visual Studio Code, Visual Studio, PowerShell ISE, PowerShell console, or other 3rd party host.

3. Right-click and unblock the script so that your PowerShell execution policy if set to RemoteSigned will allow it to run.

4. Open and execute the script. The examples below assumes you are already in the current script directory and will install the devault workloads listed in section 3.0 above.

EXAMPLE 1
`.\Deploy-AzureResourceGroup.ps1 -Verbose`

This example deploys will deploy all the VMs outlined in section 3.0 above.

EXAMPLE 2
`.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -excludePki yes -includeCentOS yes -Verbose`

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers and the PKI server, but ADDS
an additional Linux server with the latest Ubuntu Server distribution.

EXAMPLE 3
`.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -Verbose`

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers, but WILL implicitly deploy the PKI server.
This is due to the default parameter value that is set in the paramater block as $excludePki = "no".

EXAMPLE 4
`.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -includeCentOS yes -includeUbuntu no -Verbose`

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers and the Ubuntu server, but WILL implicitly deploy the PKI server and
explicity provision the CentOS server as well. The PKI server will be deployed due to the default parameter value that is set in the paramater block as [string]$excludePki = "no".

EXAMPLE 5
`.\Deploy-AzureResourceGroup.ps1 -excludeWeb yes -excludeSql yes -excludeAds yes -includeCentOS yes -includeUbuntu no -excludePki yes -Verbose`

This example deploys the infrastructure WITHOUT the web, sql, additional 2019 core domain controllers and the Ubuntu server, but WILL explicitly deploy the PKI server and
explicity provision the CentOS server as well. Feel free to customize your deployment with these -exclude... and additional... parameters.
More details about these parameters can be obtained by reading the header information in the .\Deploy-AzureResourceGroup.ps1 file.

1. When the script executes, answer the following prompts:

    - Authenticate to your subscription
    - Enter your target subscription name
    - Enter your student number, which is a number from 10 to 26.
    - Enter your administrator password for the adm.infra.user account. Your password will not be exposed.

Azure CLI (bash)

4.6 If you prefer to use the Azure CLI to deploy this solution, use the code block below:

    # Authenticate to azure
    az login

    # Create a password for the adm.infra.user account for each VM to be deployed. CATION: This password will be shown in clear text.
    adminPassword={'specify your own password here'}

    # Create a random student infix that will be used to name the storage account, automation account, OMS workspace and recovery services vault.
    studentRandomInfix=<enter 8 character string here, numbers and lower case characters only, no uppercase or special characters, i.e. abcd1234>

    # Assign the adm.infra.user account for each VM to be deployed.
    adminUserName=adm.infra.user

    # Assign a student number from [10-26] to disambiguate deployed resources from other attendees for multiple participants in a class/training scenario.
    studentNumber=##

    # Assign a resource group for all resources, where ## is the same as your student number above.
    rg=rg##

    # Specify the azure region closest to your location, i.e. eastus2 for East US 2 or westus2 for West US 2.
    location={location}

    # Assign the following uri value exactly as shown.
    uri="https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/master/azuredeploy.json"

    # Assign a deployment name.
    rgDeployment=rg##deployment

    # Create a resource group
    az group create --name $rg --location $location

    # Be carefull when pasting multiple lines due to the differences in CRLF support for certain text editors/IDEs.
    az group deployment create \
    --name $rgDeployment \
    --resource-group $rg \
    --template-uri $uri \
    --parameters adminUserName=$adminUserName adminPassword=$adminPassword studentRandomInfix=$studentRandomInfix studentNumber=$studentNumber

## 5.0 Connecting to your Lab

1. If you use the PowerShell script method to deploy this lab, your RDP prompt will open automatically to the development/jump server AZRDEV##01 VM.

2. If you use the Azure CLI (bash) method, then you will need to use your browser to authenticate to your subscription from <https://portal.azure.com> and click connect icon from the AZRDEV##01 VM overview blade in the portal.

The username to use is: adm.infra.user@dev.adatum.com

## 6.0 After Deploying the Template (Usage)

Although particular scenarios or specific sets of excercises are not provided as part of this project to practice these skills, listed here is the recommended outline of training objectives as a basic guide.
You may deviate, ommit, add or re-sequence these steps as necessary to meet your test/dev/training requirements.
Please NOTE that this project is primarily for training and NOT recommended for production.

For a hands-on excercises or training/class scenarios, where all attendees will be deploying their own lab, a single subscription can be used, but you may have to request increases in core or other resource limits by
submitting an Azure support ticket through this subscription. You may also consider assigning a seperate subscription to each attendee so that resource limits will not be exceeded.
Special care was taken to ensure that multiple attendees can perform simultaneous deployments without resource name conflicts within the same subscription. This is due to the student numbers assigned to each attendee, and supports numbers from 1-16. For example, the ## symbols below represents the student number of the VMs, ranging from 1-16.

SUGGESTED LAB CHALLENGES/EXERCISES

1. Build the AZRDEV##01 server as a jump/dev DSC pull server using desired state configuration in local push configuration mode.

2. Build the AZRWEB##01 web server as a web server using push mode remotely from AZRDEV##01.

3. Build the AZRADS##01 domain controller as a domain controller using push mode remotely from AZRDEV##01.

4. Build the AZRSQL##01 SQL 2019 server as an SQL server using push mode and the SQL 2019 installation media remotely from AZRDEV##01. This is to simulate an on-premises deployment scenario.

5. Apply a configuration to AZRWEB##01 using the DSC Pull server AZRDEV##01.

6. Apply a configuration to AZRADS##01 using the DSC Pull server AZRDEV##01.

7. Apply a configuration to AZRSQL##01 using the DSC Pull server AZRDEV##01.

8. Build the AZRWEB##02 web server as a web server using Azure Automation (AA) DSC (AA DSC).

9. Build the AZRADS##02 domain controller as a domain controller using AA DSC.

10. Build the AZRSQL##02 SQL 2019 server as an SQL server using AA DSC.

11. Apply a configuration to the AZRLNX##01 Linux CentOS server using the push mode remotely from AZRDEV##01.

12. Apply a configuration to the AZRLNX##01 Linux CentOS server using AA DSC.

13. Use the AZRPKI##01 server for PKI services.

## 9.0 Notes

1. *This solution does not include a hybrid connection to an on-premises environment.*
2. *All Windows VMs are domain joined during the deployment.*

## 6.0 References

Here are some references for Azure Automation, PowerShell and Desired State Configuration that can be used during your learning and exploration of these topics.

LINKS

1. Azure Automation: [Azure Automation Overview](https://docs.microsoft.com/en-us/azure/automation/automation-intro)
2. Desired State Configuration: [Windows PowerShell Desired State Configuration](https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview/overview?view=powershell-7)
3. Desired State Configuration for Linux: [Get started with Desired State Configuration for Linux](https://docs.microsoft.com/en-us/powershell/scripting/dsc/getting-started/lnxGettingStarted?view=powershell-7)
4. Powershell: [PowerShell 7.x](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.x)
5. DSC on Linux in Azure Example Scenario: [DSC on Linux in Azure](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/windows-powershell-and-dsc-on-linux-in-microsoft-azure/ba-p/259199)
6. Install SQL with DSC Example Scenario: [Install SQL with DSC](https://blogs.msdn.microsoft.com/powersql/2017/12/13/install-sql-server-2017-using-powershell-desired-state-configuration-and-sqlserverdsc/)

BOOKS

1. Windows PowerShell in Action, 3rd Edition – Bruce Payette & Richard Siddaway (See Chapter 18. Desired State Configuration)
2. The DSC Book "Forever" Edition - Don Jones and Melissa Januszko [The DSC Book](https://leanpub.com/the-dsc-book)

## 10.0 Tags

`Tags: Azure Automation Lab, Azure, Automation, Windows Powershell, Desired State Configuration, DSC, PowerShell, Linux`
