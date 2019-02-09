#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 3: Advanced Functions - Parameters
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
    LAB 3: ADVANCED FUNCTIONS - PARAMETERS
        Exercise 3.1: PARAMETERS
            Task 3.1.1: Static Parameters
            Task 3.1.2: Switch parameters
            Task 3.1.3: Cmdlet Binding Attribute
#>
#endregion contents

<#
    Introduction  
    
    Windows PowerShell allows you to write functions that can perform operations that are similar to the operations you can perform with cmdlets.  
    Advanced functions are helpful when you want to write a function without having to write a compiled cmdlet using a Microsoft .NET Framework language, or when you want to write a function that has the same capabilities as a compiled cmdlet. 
    
    Objectives  
    
    After completing this lab, you will be able to: 
     Understand how to extend existing functions with advanced Cmdlet features 
     Use parameters and attributes that imbue a function with advanced functionality 
    
    Scenario  
    
    You are one of the administrative staff at Contoso Corporation. A common requirement when developing, testing and deploying an application, service or new piece of infrastructure is verifying TCP port availability. You need to create a function for this purpose, incorporating advanced function features to produce an enterprise-ready solution. 
    Prerequisites Start all VMs provided for the workshop labs. Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
    
    Estimated time to complete this lab  60 minutes 
    
    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE). 
    Each lab has its own files. For example, the lab exercises for module 3 have a folder at C:\PShell\Labs\Lab_3 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. When you connect with Remote Desktop, you can copy and paste from one virtual machine to another. 
#>

#region 3.1
<#
    Objectives  
    
    After completing this exercise, you will be able to: 
    * Define and use static parameters 
    * Define and use switch parameters 
    * Use the [CmdletBinding()] attribute for a function
 
    Scenario  
    
    You are researching how you can use Windows PowerShell to develop a port connectivity tool to test your server builds. 
#>

#region Task 3.1.1: Static Parameters
function Use-StaticParameter
{
    Param
    (
        # Static parameter
        [string]$Firstname
    ) # end param
    Write-Output "Hello $FirstName"
} # end function

# The $FirstName variable in this script is a static parameter
# 1. Load the function into memory by selecting it and press F8 to run selection
# 2. Execute the function by running the statement below
Use-StaticParameter -Firstname Jason
#endregion 3.1.1

#region Task 3.1.2: Switch Parameters
# We'll add the $Upper switch parameter to the function above so that if it's specified when the function is invoked, then the result will be shown in upper case.
# Otherwise, the case will be mixed.
function Use-StaticParameterUpperCase
{
    Param
    (
        # Static parameter
        [string]$Firstname,
        # Switch parameter
        [switch]$Upper
    ) # end param
    If ($Upper)
    {
        Write-Output "Hello $FirstName".ToUpper()
    } # end else
    else
    {
        Write-Output "Hello $FirstName"
    } # end else
} # end function

# 1. Load the function into memory by selecting it and press F8 to run selection
# 2. Execute the function by running the statement below without specifying the switch parameter -Upper
Use-StaticParameterUpperCase -Firstname Jason
# 3. Now execute the same function again, but this time, add the -Upper switch parameter and notice that now the result in all upper case.
Use-StaticParameterUpperCase -Firstname Jason -Upper
#endregion 3.1.2

#region Task 3.1.3: Cmdlet Binding Attribute
# We're ready to add the cmdlet binding attribute to the previous function, to make the common parameters available.

function Use-StaticParameterUpperCase
{
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [string]$Firstname,
        # Switch parameter
        [switch]$Upper
    ) # end param
    If ($Upper)
    {
        Write-Output "Hello $FirstName".ToUpper()
    } # end else
    else
    {
        Write-Output "Hello $FirstName"
    } # end else
} # end function

# 1. Load the function into memory by selecting it and press F8 to run selection
# 2. Execute the function by running the statement below and use the Outvariable common parameter to save the output in the $outVar1 variable.
# NOTE: The $ is not used in the variable name with the -OutVariable parameter.
Use-StaticParameterUpperCase -Firstname Jason -Upper -OutVariable outVar1 
# 3. Show the value of the $outVar1 variable
$outVar1
# Any of the other common parameters for the funciton, such as -Verbose or -ErrorAction are also available now that the [CmdletBinding()] attribute is used.
#endregion 3.1.3
#endregion 3.1
