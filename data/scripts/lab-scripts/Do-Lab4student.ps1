#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 4: Advanced Functions - Attributes
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
    LAB 4: ADVANCED FUNCTIONS - ATTRIBUTES
        Exercise 4.1: ATTRIBUTES
            Task 4.1.1: [OutputType]Attribute
            Task 4.1.2: [Parameter]Attribute
            Task 4.1.3: ValueFromPipeline
            Task 4.1.4: [Alias] Attribute
            Task 4.1.5: [ValidateRange] Attribute
            Task 4.1.6: [ValidateLength] and [ValidateNotNull()] Attributes
            Task 4.1.7: [ValidateScript]Attribute
#>
#endregion contents

#region Exercise 4.1: Attributes
<#
    Introduction
  
    Windows PowerShell allows you to write functions that have the same behavior as cmdlets.  
    Advanced functions are helpful when you want to write a function without having to write a compiled cmdlet using a Microsoft .NET Framework language, or when you want to write a function that has the same capabilities as a compiled cmdlet. 

    Objectives  

    After completing this lab, you will be able to: 
     Understand how to extend existing functions with advanced Cmdlet features 
     Use parameters and attributes that imbue a function with advanced functionality 

    Scenario  

    You are one of the administrative staff at Contoso Corporation. A common requirement when developing, testing and deploying an application, service or new piece of infrastructure is verifying TCP port availability. You need to create a function for this purpose, incorporating advanced function features to produce an enterprise-ready solution. 
    Prerequisites Start all VMs provided for the workshop labs. Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
    
    Estimated time to complete this lab  30 minutes 

    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE).  
    Each lab has its own files. For example, the lab exercises for module 3 have a folder at C:\PShell\Labs\Lab_3 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.  
#>

#region 4.1.1: [OutputType] Attribute
<#
    The “OutputType” attribute is used to declare the expected return type of a function.
    This attribute is supported on simple and advanced functions and is independent of the CmdletBinding attribute.  
    The OutputType attribute value is only a documentation note. It will not alter the actual object type returned by a function.
    You may want to use this attribute to documentat the expected output type of a function as well as to enable intellisense features to view type members
    i.e. properties and methods of a function's expected output type.

    Reference: https://becomelotr.wordpress.com/2012/06/17/outputtypewhy-would-you-care/
#>

# The function that follows demonstrates how adding the [OutputType([string])] attribute enables intellesense to treat the entire function as a string object,
# and thereby presenting the members of this type when using the dot (.) notation for objects.
# 1. Load the following funciton into memory by selecting it and pressing F8.

function Add-OutputTypeAttrib
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
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

# 2. Encapsulate the function name in parenthesis () to index into the functions string type members by typing the following below in the console pane.
(Add-OutputTypeAttrib).Length
# 3. Note that this represents the length property of a string object, which for this function is 6, because "Hello" has 6 characters.
#endregion 4.1.1

#region 4.1.2: [Parameter] Attribute
<#
    All parameter attributes are optional. 
    However, if you omit the CmdletBinding attribute, the function must include at least one Parameter attribute to become an advanced function. 
    In this exercise, we will add some of the parameter attributes to the function’s parameter list. 
    The accepted parameter attributes and their accepted data types are below. 

    Mandatory [boolean]
    Position [integer]
    ParameterSetName [string]
    ValueFromPipeline [boolean]
    ValueFromPipelinebyPropertyName [boolean]
    ValueFromRemainingArguments [boolean]
    HelpMessage [string]
    Alias [string]
    
    The syntax for a parameter attribute is: 
    
    [Parameter(<Attribute Name>)] $<parameter name> 
#>

# To specify that a certain parameter is required for a function or script, we can include the name value pair of Mandatory=$true as a parameter attribute argument.
# 1. Modify the funciton below using the mandatory parameter attribute argument name and value as Mandatory=$true for the parameter attribute of the $FirstName parameter: 
# 2. Reference: Get-Help -Name about_Functions_Advanced_Parameters -ShowWindow

function Add-MandatoryArgument
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [string]$FirstName,
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

# Answer: 

function Add-MandatoryArgumentComplete
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [string]$FirstName,
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

# 3. Now lets consider the position argument. By default, all function parameters are positional and are assigned based on the order in which the parameters are declared.
#    For example, the $FirstName parameter is the first parameter declared, so it's positional value is 0 (0-based numbering system. Think arrays!). 
#    We can add the positional argument to the parameter attribute like this:
<#
[parameter(Position=0)]
[string]$FistName
#>
#    However, this isn't necessary since it already reflects the default behavior. 
# 4. Using the [CmdletBinding()] attribute, use the PositionalBinding argument to set all parameters as named instead of positional. 
#    Reference: Get-Help -Name about_Functions_Advanced_Parameters -ShowWindow

function Set-ParametersToNamed
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [string]$FirstName,
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

# Answer:

function Set-ParametersToNamedComplete
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    Param
    (
        # Static parameter
        [string]$FirstName,
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

# 5. We can also assign certain parameters to specific parameter sets, which will be reflected in the syntax of a command (Get-Command -Name <funciton> -Syntax)
# 6. Add another parameter below the $FirstName parameter. The parameter name is $ShortName and type cast it as a string.
# 7. Assign the $FirstName parameter to a new parameter set named "First" and the $ShortName parameter to another called "Short" to the function below:

function Set-ParameterSets
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [string]$FirstName,
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

# Answer: 
# 8. Load the funciton into memory by selecting it and pressing F8.
# 9. Type the expression below to view the parameter sets
Get-Command -Name Set-ParameterSets -Syntax
# 10.Notice that the two parameter sets are shown. One which uses -FirstName and the other that uses -ShortName
function Set-ParameterSetsPartial
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameters
        [parameter(ParameterSetName="First")]
        [string]$FirstName,
        [parameter(ParameterSetName="Short")]
        [string]$ShortName,
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

# 11. Now that we've assigned parameter sets, we need to account for the new $ShortName parameter if it is supplied with the value "Jay" when the function is called.
#     This will be a class group excercise.

# Answer:
function Set-ParameterSetsComplete
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameters
        [parameter(ParameterSetName="First")]
        [string]$FirstName,
        [parameter(ParameterSetName="Short")]
        [string]$ShortName,
        # Switch parameter
        [switch]$Upper
    ) # end param
    If ($PSCmdlet.ParameterSetName -eq "First")
    {
        If ($Upper)
        {
            Write-Output "Hello $FirstName".ToUpper()
        } # end else
        else
        {
            Write-Output "Hello $FirstName"
        } # end else
    } # end if
    else 
    {
         If ($Upper)
        {
            Write-Output "Hello $ShortName".ToUpper()
        } # end else
        else
        {
            Write-Output "Hello $ShortName"
        } # end else
    } # end else
} # end function
#endregion 4.1.2

#region 4.1.3: ValueFromPipeline property
<#
     The ValueFromPipeline parameter attribute is used when a function parameter accepts an entire object from the pipeline, not just a property of an object.
     Whereas The ValueFromPipelineByPropertyName parameter attribute name indicates that the parameter will accept input from an object property 
     passed to the function via the pipeline.
#>

# 1. In the function below, set the ValueFromPipelineProperty so that the $FirstName parameter will accept string objects passed through the pipeline
#    for it's value.

function Set-ValueFromPipelineProperty
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [string]$FirstName,
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

# Answer:
function Set-ValueFromPipelinePropertyComplete
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [parameter(ValueFromPipeLine)]
        [string]$FirstName,
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

# 2. Use the expression below to test the funciton
"Jason" | Set-ValueFromPipelineProperty
# 3. Type the following to examine the parameter attribute table and note the value for the "Accept pipeline input?" entry.
Get-Help -Name Set-ValueFromPipelineProperty -Parameter FirstName
#endregion 4.1.3
#region 4.1.4: [Alias] Attribute
<#
    We can include an alias for the -FirstName parameter to provide some more flexibility for the funciton. This attribute can also be used to accomodate
    multiple parameter name options when using the [parameter(ValueFromPipeLineByPropertyName)] attribute.
#>
# 1. Add the [Alias()] attribute for the $FirstName parameter and assign the value as "Name" for the function below
# Answer:

function Set-AliasParameterAttributeComplete
{
    # Add output type parameter attribute to classify the return type of this function as a string object.
    [OutputType([string])]
    [CmdletBinding()]
    Param
    (
        # Static parameter
        [Alias("Name")]
        [string]$FirstName,
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

# 2. Load the function into memory
# 3. Test the function with the new parameter alias "Name" using the expression below:
Set-AliasParameterAttribute -Name Jason
#endregion 4.1.4

#region 4.1.5: [ValidateRange] Attribute
<#
    The ValidateRange attribute specifies a numeric range for each parameter or variable value. 
    Windows PowerShell generates an error if any value is outside that range. 
    This attribute can be used for input validation when only a specific range of integer values can be accepted.
#>

# 1. Add the [ValidateRange()] attribute to the funciton below to restict integer values for the $diceGuess parameter to between 1-6.

function New-DiceRoll
{
    param
    (
        [parameter(Mandatory=$true,
        HelpMessage = "Enter a number from 1-6 to guess the dice roll [1-6]")]
        [int]$diceGuess
    ) # end param

    [int]$diceRoll = Get-Random -Minimum 1 -Maximum 6
    If ($diceGuess -eq $diceRoll)
    {
        "Correct! :-)"
    } # end if
    else
    {
        "Incorrect :-("
        "Please try again"
    } # end else
} # end function

# Answer:
function New-DiceRollComplete
{
    param
    (
        [parameter(Mandatory=$true,
        HelpMessage = "Enter a number from 1-6 to guess the dice roll [1-6]")]
        [ValidateRange(1,6)]
        [int]$diceGuess
    ) # end param

    [int]$diceRoll = Get-Random -Minimum 1 -Maximum 6
    If ($diceGuess -eq $diceRoll)
    {
        "Correct! :-)"
    } # end if
    else
    {
        "Incorrect :-("
        "Please try again"
    } # end else
} # end function
#endregion 4.1.5

#region 4.1.6: [ValidateLength] and [ValidateNotNull] Attributes

# We can also validate a certain number of characters in a string and test to ensure it is also not null
# 1. Modify the function below to validate that the string length of the airport code for the $AirportCode parameter is not null and is 3 exactly characters long.
function Test-AiportCodeLength
{
    param
    (
        [string]$AirportCode
    ) # end param

    Write-Output "You entered the ICAO aiport code: $($AirportCode.ToUpper())"
} # end function

# Answer:
function Test-AiportCodeLengthComplete
{
    param
    (
        [ValidateNotNull()]
        [ValidateLength(3,3)]
        [string]$AirportCode
    ) # end param

    Write-Output "You entered the ICAO aiport code: $($AirportCode.ToUpper())"
} # end function

#endregion 4.1.6
#region 4.1.7: [ValidateScript] Attribute
<#
    The ValidateScript attribute specifies a script used to validate a parameter value. 
    Windows PowerShell pipes the value to the script and generates an error if the script returns false or if the script throws an exception. 
    When you use the ValidateScript attribute, the value to be validated is referenced using the $_ variable. 
#>

# 1. Modify the script below using ONLY the [ValidateScript()] attribute to test that the length of the string is exactly 3 characters
function Test-AiportCodeWithValidateScript
{
    param
    (
        [string]$AirportCode
    ) # end param

    Write-Output "You entered the ICAO aiport code: $($AirportCode.ToUpper())"
} # end function

# Answer:
function Test-AiportCodeWithValidateScriptComplete
{
    param
    (
        [ValidateScript({($($_.length) -eq 3)})]
        [string]$AirportCode
    ) # end param

    Write-Output "You entered the ICAO aiport code: $($AirportCode.ToUpper())"
} # end function

# 2. Test the function with the following expressions and observe the result. Note any error messages recieved.
Test-AiportCodeWithValidateScript -AirportCode iad
Test-AiportCodeWithValidateScript -AirportCode ia
Test-AiportCodeWithValidateScript -AirportCode iadva
#endregion 4.1.7
#endregion 4.1