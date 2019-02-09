#requires -Version 4.0
#requires -RunAsAdministrator

#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 2: Remoting
    Student Lab Manual

    Conditions and Terms of Use 
    Microsoft Confidential - For Internal Use Only 
 
    This training package is proprietary and confidential, and is intended only for uses described in the training materials. Content and software is provided to you under a Non-Disclosure Agreement and cannot be distributed. Copying or disclosing all or any portion of the content and/or software included in such packages is strictly prohibited. 
    The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. 
    Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred.  
 
    © 2014 Microsoft Corporation. All rights reserved.

    Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property. 
    Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.  
    For more information, see Use of Microsoft Copyrighted Content at http://www.microsoft.com/about/legal/permissions/ 
    Microsoft®, Internet Explorer®, and Windows® are either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. Other Microsoft products mentioned herein may be either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. All other trademarks are property of their respective owners. 
#>
#endregion header

#region contents
<#
    LAB 2: WINDOWS POWERSHELL REMOTING
        Exercise 2.1: WINDOWS POWERSHELL REMOTING
            Task 2.1.1: Windows Server 2012r2 default configuration
            Task 2.2.2: $Using variable scope prefix
        Exercise 2.2: REMOTE SESSION BEHAVIOUR
            Task 2.2.1: Explore disconnected sessions
            Task 2.2.2: Using disconnected sessions
            Task 2.2.3: Interrupted sessions
        Exercise 2.3: CONSTRAINED SESSION CONFIGURATION
            Task 2.3.1: Create a constrained session configuration file
        Exercise 2.4: COMMON INFRASTRUCTURE MODEL (CIM) REMOTING
            Task 2.4.1 Protocols and Ports
            Task 2.4.2: Enable-PSRemoting
        Exercise 2.5: USING CIM CMDLETS
            Task 2.5.1: Finding classes, properties, and methods
            Task 2.5.2: Querying for specific data
            Task 2.5.3: Querying multiple computers with CIM cmdlets
        Exercise 2.6: USING CIM SESSIONS AS PARAMETERS
            Task 2.6.1: Finding cmdlets with a CimSession parameter
            Task 2.6.2: Using the -CimSession parameter
#>
#endregion contents

<#
    Introduction 
    
    In this lab, you will explore the remoting features in Windows PowerShell. 
    You can run remote commands on a single computer or on multiple computers by using a temporary or persistent connection. 
    You can also start an interactive session with a single remote computer. 
    
    Objectives  

    After completing this lab, you will be able to: 
     Use the Windows PowerShell remoting features in Microsoft Windows Server 2012R2 
     Describe Windows PowerShell session behavior 
     Identify default PowerShell remoting behavior  
     Learn how to disconnect and reconnect sessions 
     Configure delegated sessions 
     Run remote commands under alternative credentials 
     Understand when the $using variable can be employed in a remote session 
 
    Prerequisites Start all VMs provided for the workshop labs. 
    Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
 
    Estimated time to complete this lab  60 minutes

    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE).  
    Each lab has its own files. For example, the lab exercises for module 7 have a folder at C:\PShell\Labs\Lab_7 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. 
    When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.

    Scenario

    As a senior systems engineer, you are required to understand and evaluate the new remoting features in Windows PowerShell to manage remote Microsoft Windows Servers. 
#>

<#

Objectives  

In this exercise, you will: 
 Identify default PowerShell remoting configuration settings in Windows Server 2012R2 
 Discover how the new $using variable prefix can simplify passing local variables to remote scriptblocks  
 
Scenario 

You are reviewing the Windows PowerShell remoting features included in Microsoft Windows Server 2012R2 and 
are required to provide a summary of the default remoting configuration.

#>

#region 2.1
# Exercise 2.1 WINDOWS POWERSHELL REMOTING
<#
    Task 2.1.1: Windows Server 2012R2 default configuration
    a. Using the WSMAN PowerShell provider on 2012R2-MS, write a script to collect the current value for all the following remoting configuration properties.
    b. Use an array named $wsmanPaths to store all paths, then employ a loop to iterate through each, displaying the name and value properties.

    wsman:\localhost\Shell\IdleTimeout
    wsman:\localhost\Shell\AllowRemoteShellAccess
    wsman:\localhost\Shell\MaxShellsPerUser
    wsman:\localhost\Service\IPv4Filter
    wsman:\Service\AllowUnencrypted
    wsman:\Service\DefaultPorts\HTTP
    
    Reference: Get-help -Name about_wsman
#>

# Solution:

$wsmanPaths = 
@(
    "wsman:\localhost\Shell\AllowRemoteShellAccess"
    "wsman:\localhost\Shell\MaxShellsPerUser"
    "wsman:\localhost\Service\IPv4Filter"
    "wsman:\localhost\Service\AllowUnencrypted"
    "wsman:\localhost\Service\DefaultPorts\HTTP"
) # end array

ForEach ($wsmanPath in $wsmanPaths)
{
    Get-ChildItem -Path $wsmanPath | Select-Object -Property Name, Value
} # end foreach

# Output:
<#
Name                   Value     
----                   -----     
AllowRemoteShellAccess true      
MaxShellsPerUser       2147483647
IPv4Filter             *         
AllowUnencrypted       false     
HTTP                   5985 
#>

<#
    Task 2.1.2: $Using variable scope prefix 
    A variable scope prefix provides a more elegant way of passing local arguments to a script block executed remotely. 
    Prior to this addition, arguments were passed to a param() statement in a script block, using the -Argumentlist parameter of Invoke-Command. 
    These arguments became bound positionally, rather than by name.

    Reference: Get-Help -Name about_Remote_Variables
#>

# a. Type the code below and review the results

$logName = "system"
$numEvents = 20
Invoke-Command -ComputerName 2012r2-DC -ScriptBlock {
    Get-WinEvent -LogName $using:LogName -MaxEvents $using:numEvents
} # end scriptblock

<#
    Write a script that uses a locally defined string array of folder paths and determines whether they exist on all of the remote machines, 
    utilizing Invoke-Command and the $using scope prefix. Use the arrays provided below
    
    $computers = @("2012r2-dc","2012r2-ms","win8-ws")

    $folderPaths = 
    @(
        "C:\windows"
        "C:\windows\system32"
        "c:\windows\logs"
    ) # end array
#>

# Answer:

#endregion 2.1

#region 2.2
# Exercise 2.2: Remote Session Behavior
<#
    Objectives  
    
    In this exercise, you will:  Explore Disconnected sessions  Disconnect and re-connect remote sessions  Review robust session functionality 
 
    Scenario 
    
    You are exploring the Windows PowerShell remote session functionality for your company as part of a Windows Server 2012R2 infrastructure deployment.  

    Reference: Get-Help -Name about_Remote_Disconnected_Session
#>

# Task 2.2.2: Using disconnected sessions 
# 1. Log onto 2012R2-MS using the Contoso\Administrator (not local Administrator) account and password PowerShell4.  
# Open the Windows PowerShell ISE and create a new remote PowerShell session to 2012DC. 
# For convenience save the cmdlet output to a variable. 
$s = New-PSSession –ComputerName 2012R2-DC 
# 2. List the local PowerShell sessions. Note the State and Availability session properties. 
Get-PSSession 
# 3. Create a new variable in the remote session using the Invoke-Command cmdlet. 
Invoke-Command –Session $s -Scriptblock {$myVar = “This is a disconnected session”} 
# 4. Disconnect the session, using the Disconnect-PSSession cmdlet 
Disconnect-PSSession –Session $s 
# 5. Log onto the WIN8-WS using the Contoso\DanPark account and open the Windows PowerShell console or ISE. 6. From WIN8-WS, list the sessions on the remote machine 2012DC. 
Get-PSSession –ComputerName 2012R2-DC 
# 7. Describe why the command did not complete successfully. 
# Answer: 

# 8. Correct the previous command to successfully list sessions on the remote machine and write the correct command below and note the session Name property. 
# Answer:

# 9. Using Windows PowerShell on WIN8-WS, re-connect the remote session on 2012R2-DC as the domain administrator account, 
# using the session name noted in the previous step. Save the session reference in a variable. 
$s1 = Get-PSSession –ComputerName 2012R2-DC -Name <Session> -Credential Contoso\Administrator Connect-PSSession $s1 
# 10. Confirm you can retrieve the contents of the $myVar variable, created at the start of this exercise. 
Invoke-Command –Session $s1 –Scriptblock {$myVar}
# Answer:

#endregion 2.2

#region 2.3
<#
    Exercise 2.3: Constrained Session Configuration 
    
    Objectives  

    In this exercise, you will: 
     Learn how to create and register a ‘session endpoint’ configuration file. 
     Modify the ACL on the session configuration to allow a non-administrative user to connect to an endpoint. 
     Use the RunAs parameter on the Set-PSSessionConfiguration cmdlet to allow commands run in a constrained session to be executed using alternative or elevated credentials. 
    
    Scenario 

    Creating constrained remote endpoint configurations in Windows PowerShell 2.0 was a complicated experience. 
    It required session profile scripts to be first: written, second: copied to and thirdly registered on a remote machine.  
    As you will see, PowerShell 4.0 greatly simplifies this process. 

    Reference: Get-Help -Name New-PSSessionConfigurationFile
#>
<#
    Task 2.3.1: Create a constrained session configuration file 
    1. Logon to 2012R2-MS as Administrator.  
    Enable the Windows Firewall for all three of the network profiles.  
    Launch a Windows PowerShell console as Contoso\Administrator.  
    Enter the following command to enable the firewall for all network profiles. 
#>
Set-NetFirewallProfile -All -Enabled True
<#
2. A single cmdlet creates file based session configurations.
3. We will create a constrained session configuration called "RestrictedSession" on 2012R2-MS using the New-PSSessionConfigurationFile cmdlet
   with the following restrictions:
    a. The Microsoft.PowerShell.core Moudle is loaded
    b. No language elements can be used
    c. Only *-Service, *-Object and Get-* cmdlets can be used. We also have to include the "Exit-PSSession" and "Out-Default" cmdlets as they are required within
       an interactive remote session.
4. First, logon onto 2012r2-ms to create the session configuration file.
#>
New-PSSessionConfigurationFile -Path .\RestrictedSession.pssc ` 
-VisibleCmdlets "*-Service","*-Object”,"Get-*",”Exit-PSSession”,”OutDefault” ` 
Windows PowerShell v4.0 for the IT Professsional Part 2 – Module 2:Remoting -LanguageMode NoLanguage
# 5. Next, register the session configuration file.
Register-PSSessionConfiguration -Path .\RestrictedSession.pssc ` -Name RestrictedSession -AccessMode Remote –Force 
# 6. Set the ACL for Dan Park on the session configuration file -ShowSecurityDescriptorUI -Force
    # a. Add the user name DanPark to the ACL.
    # b. Check the Allow checkbox fo the Execute(Invoke) permission. This is the minimum permission required for remote sessions.
# 7. Logon to WIN8-WS as user DanPark. Create a new connection tot he session configuration creted on 2012R2-MS from a Windows PowerShell console or ISE.
$session = New-PSSession -ComputerName 2012r2-ms -ConfigurationName RestrictedSession
# List the available commands. For this exercise, enter an interactive remote session using the Enter-PSSession cmdlet 
Enter-PSSession –Session $session 
# Note: Presents an interactive remoting prompt, prefixed with the remote machine name, as shown below 
# [2012R2-MS]: PS>  
# At the interactive prompt, type the following commands in order to answer the following questions. 
Get-Command Question A: Provide the number of cmdlets listed. 
Get-Command -CommandType cmdlet | Measure-Object 
# Provide the number of cmdlets listed.
# Answer:

# 9. Which parameter specifies commands visible in the constrained session? 
# Answer:

# 10. Try to execute a language statement (If (), While (), Do {}, etc). 
foreach ($p in Get-Process) {$p.handles} 
# Record what happens below: 
# 11. Execute the Get-Service cmdlet in the remote interative session. 
Get-Service 
# 12. Why does this command fail to run? 
#     Answer:

# 13. On 2012R2-MS, modify the session configuration to allow commands to run under an alternate set of credentials. 
Set-PSSessionConfiguration –Name RestrictedSession –RunAsCredential Contoso\Administrator -Force 
Windows PowerShell v4.0 for the IT Professsional Part 2 – Module 2:Remoting 
# 14. Log back on to WIN8-WS and try to execute the Get-Service command again. 
$session = New-PSSession -ComputerName 2012R2-MS -ConfigurationName RestrictedSession 
Invoke-Command -Session $session -ScriptBlock {Get-Service} 
# 15. Is the result different this time, if so why?
# Answer:

<#
    Task 2.4.2: Enable-PSRemoting 
    
    When remoting is disabled, all WinRM features will fail (remote sessions, CIM cmdlets, etc.).  
    Windows Server 2012 R2, by default, has remoting enabled. On Windows 7, Windows 8, Windows 8.1 and Windows Server 2008 R2, by default, remoting is disabled. 
    To complete this lab, you must enable remoting on the WIN8-WS client. In a large organization, you can enable remoting across many machines using Group Policy.  For individual machines, you can use the cmdlet Enable-PSRemoting.  In PowerShell 4.0, this cmdlet also enables remoting over public network interfaces. 
    Note:  For more information about enabling remoting with Group Policy, see the help topic about_Remote_Troubleshooting.  
    For more information about public, private, and domain network profiles see Help Enable-PSRemoting -Full. 

    References: 
    1. Get-Help -Name about_Remote_Troubleshooting
    2. Get-Help -Name Get-CimInstance

#>

# 1. Log on to the WIN8-WS client as DanPark
# 2. Try to perform a local CIM query using the -ComputerName parameter
Get-CimInstance -ClassName Win32_BIOS -ComputerName localhost
# 3. Examine the status of the WinRM service:
Get-Service -name WinRM
    # a. What is the status of the WinRM service?
    # Answer:

# 4. Enabling remoting requires an elevated console. Launch the PowerShell console on WIN8-WS as contoso\administrator.
# 5. Enable remoting on the WIN8-WS client. Read all text output carefully. Answer Yes to all prompts.
Enable-PSRemoting
# 6. Examine the status of the WinRM service now.
Get-Service -Name WinRM
    # a. What is the status of the WinRM service?
    # Answer:

# 8. Try the CIM query again. Recall thta this failed earlier in step 2.
Get-CIMInstance -ClassName Win32_BIOS -ComputerName localhost
#endregion 2.3






 




