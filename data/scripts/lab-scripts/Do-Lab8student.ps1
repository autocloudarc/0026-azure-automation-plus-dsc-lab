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
    LAB 8: DESIRED STATE CONFIGURATION
        Exercise 8.1: DESIRED STATE CONFIGURATION
            Task 8.1.1: Create a simple Desired State Configuration
            Task 8.1.2: Test the simple DSC
            Task 8.1.3: Create and invoke an Archive DSC resource
#>
#endregion contents

<#
    Introduction  

    DSC is a management platform in Windows PowerShell. 
    It enables the deployment and management of configuration data for software services and the environment on which these services run. 
    DSC provides a set of Windows PowerShell language extensions, new cmdlets and resources that you can use declaratively to specify the desired state of your software environment.  
 
    Objectives  
    
    After completing this lab, you will be able to: 
     Understand how to use DSC to create Configuration script blocks 
     Generate the MOF 
     Enact the configuration 
     Explore some of the built-in resources 
     Deploy and use custom resources 
 
    Prerequisites Start all VMs provided for the workshop labs. Logon to WIN8-WS as Contoso\Administrator, using the password PowerShell4. 

    Estimated time to complete this lab  45 minutes 

    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE).  
    You can also load pre-populated lab files into the Windows PowerShell ISE, where you can select and execute individual Cmdlets.  
    Each lab has its own files. For example, the lab exercises for module 8 have a folder at C:\PShell\Labs\Lab_8 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. 
    When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.  
#>

#region Exercise 8.1: DESIRED STATE CONFIGURATION

#region Task 8.1.1: Create a simple Desired State Configuration
<#
    Objectives  
    
    After completing this exercise, you will be able to: 
     Deploy a registry key and values 
     Refer to a ZIP file and deploy the files within 
 
    Scenario  
    
    You are an administrator of Windows systems within Contoso.com and wish to ensure that certain services, settings and features are correctly deployed and configured. 
#>

<#
1. For this initial exercise, create a simple configuration that will ensure the presence of a registry key and values on the specified target computers. 
   You will use the Registry built-in resource. Within the ISE, type in the code below. 
#>

#Assert-Registry.ps1 
#requires –RunAsAdministrator 
 
Configuration RegistryDeploy 
{     
    Node ("2012R2-MS","WIN8-WS")     
    {   
 
    } # end node
} # end configuration 

<#
   An identifier follows the Configuration keyword. Curly braces delimit the block, as you would do for a function definition. 
   The Node block values are hard-coded in this simple case to our server and our workstation.  
 
2. Within the node block, add the Registry resource block for a registry entry, using the code below. 
   The identifier following the Resource gives it a unique name within this configuration. 

   Reference: http://technet.microsoft.com/en-us/library/dn249921.aspx, which lists the full range of built-In Windows PowerShell Desired State Configuration resources. 
#>

Registry RegKey        
{           
    Ensure    = "Present"           
    Key       = "HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\Rocks" 
    ValueName = "Region"           
    ValueType = "MultiString"           
    ValueData = "APAC,EMEA,LATAM,GCR"        
} # end resource

# The full modified configuration is shown below:

#Assert-Registry.ps1 
#requires –RunAsAdministrator 
Configuration RegistryDeploy 
{     
    Node ("2012R2-MS","WIN8-WS")     
    {   
        Registry RegKey        
        {           
            Ensure    = "Present"           
            Key       = "HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\Rocks" 
            ValueName = "Region"           
            ValueType = "MultiString"           
            ValueData = "APAC,EMEA,LATAM,GCR"        
        } # end resource
    } # end node
} # end configuration 

#endregion 8.1.1

#region Task 8.1.2: Test the simple DSC
<#
1. To create the configuration, invoke the Configuration block the same way you would invoke a Windows PowerShell function. 
   Add the following line at the base of the above script. 
   We will execute the configuration by using its identifier name, so add the following code via the ISE. 
   
   RegistryDeploy -OutputPath $PSScriptRoot\RegistryDeploy 
#>

<#
2. This generates one MOF file per node at the path you specify. 
   Open the MOF files in either Notepad or the ISE and study their contents. 
   You do not need to understand how to create these files manually, but it is good to see the relationship between the configuration that you ran and the industry-standard MOF file output. 
   
3. Next, the following cmdlet parses the configuration MOF files, sends to each node its corresponding configuration, and enacts those configurations. 
   Add the following line to the base of the above script: 

   Start-DscConfiguration -path $PSScriptRoot\RegistryDeploy -Wait –Verbose 
#>

<#
4. Save the script to C:\Pshell\Labs\Lab_8\Assert-Registry.ps1 and then run from within the ISE. 
   Carefully study each line of the blue verbose output. 

NOTE:  This script uses the automatic variable $PSScriptRoot which is only available in the context of a running script (in PowerShell v3+).  
You must run the entire script for it to function correctly (as opposed to F8 Run Selection).  
Otherwise, this variable will be empty, and the files will appear in a folder at the root of the C: drive.  
This applies to all of the exercises in this module lab. 

5. Verify the actual configuration on a given node matches the desired configuration. 
#>

$session=New-CimSession -ComputerName "2012R2-MS" 
Test-DscConfiguration -CimSession $session  

<#
6. Using the same CIM session, report the current configuration on the target node. 
#>

Get-DscConfiguration -CimSession $session  

<#
7. Now observe the difference between ensure present vs. ensure absent. 
   On WIN8-WS open REGEDIT and view the path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\Rocks. 
   Notice the REG_MULTI_SZ value named Region. 
   This was created by the configuration. 

8. Now edit line 9 of the configuration script as follows: 
   Ensure = "Absent"  

9. Run the script again with F5. 

10. Now go back to REGEDIT and refresh the view of the path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\PowerShell\Rocks. 
    Notice the REG_MULTI_SZ value named Region should now be removed by the updated configuration. 
    Study the blue verbose output in the ISE and identify the line(s) where this change was made. 
#>
#endregion 8.1.2

#region Task 8.1.3: Create and invoke an Archive DSC resource
<#
1. For this next task, create another simple configuration that will ensure the presence of a ZIP file and unpack it onto the specified target computers. 
   You will use the Archive built-in resource. Within the ISE, type in the code below. 
#>

#assert-xDHCPdeploy.ps1 
#requires -RunAsAdministrator 
 
Configuration xDHCPDeploy  
{     
    Node ("2012R2-MS","WIN8-WS")     
    {         
        Archive xDHCPzip 
        {   Ensure = "Present"         
            Path = "\\2012R2-MS\DSCResources\xDHCP.zip"         
            Destination = "$PSHOME\Modules"       
        } # end resource     
    } # end node 
} # end configuration 

<#
2. As before, we create the configuration. Enter the following code into the ISE. 
#>

xDHCPdeploy -OutputPath $PSScriptRoot\xDHCPdeploy 

<#
3. Next, we enact the configuration. 
Add the following line to the base of the above script and then run from within the ISE. Carefully study each line of the blue verbose output. 
#>

Start-DscConfiguration -path $PSScriptRoot\xDHCPdeploy -Wait –Verbose
<#
NOTE:  This script uses the automatic variable $PSScriptRoot which is only available in the context of a running script (in PowerShell v3+).  
You must run the entire script for it to function correctly (as opposed to F8 Run Selection).  
Otherwise, this variable will be empty, and the files will appear in a folder at the root of the C: drive.  
This applies to all of the exercises in this module lab. 
4. Verify the actual configuration on the target node matches the desired configuration. 
#>

$session=New-CimSession -ComputerName "2012R2-MS" 
Test-DscConfiguration -CimSession $session
Get-DscConfiguration -CimSession $session  

<#
5. You can also confirm the creation of the xDHCP target folder manually. 
#>

Get-Childitem -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules
#>
#endregion 8.1.3
#endregion 8.1