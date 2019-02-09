#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 6: Error Handling
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
    LAB 6: ERROR HANDLING
        EXERCISE 6.1 NON-TERMINATING ERRORS
            Task 6.1.1: Redirection Operators
            Task 6.1.2: $Error automatic variable
            Task 6.1.3: -ErrorVariable common parameter
            Task 6.1.4: $ErrorActionPreference and $WarningPreference
        EXERCISE 6.2: TERMINATING ERRORS
            Task 6.2.1: Throw keyword
            Task 6.2.2: Try-Catch-Finally
            Task 6.2.3: Trap
            Task 6.2.4: Try-Catch-Finally and Scope
        EXERCISE 6.3: CUSTOM ERROR MESSAGES
            Task 6.3.1: Write-Error
            Task 6.3.2: Write-Warning
#>
#endregion contents

<#
    Introduction 

    Windows PowerShell offers a set of tools to trap, raise and discover errors in scripts, functions and pipeline operations. 
    Windows PowerShell errors represent as rich objects containing useful information as to the type, location and context of errors. 
 
    Objectives  
    
    After completing this lab, you will be able to: 
    
     Identify terminating and non-terminating errors 
     Use the trap statement to catch errors 
     Use the Try, Catch, Finally statement to catch errors 
 
    Prerequisites 
    
    Start all VMs provided for the workshop labs. 
    Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
#>

#region EXERCISE 6.1 NON-TERMINATING ERRORS
<#
Introduction  

Windows PowerShell defines non-terminating errors as those that allow execution to continue, despite a command failure. 
This behavior is especially useful in a pipeline command when processing an array of objects. 
The pipeline will continue processing each element of the array if one or more commands are unsuccessful. 
 
Objectives  
After completing this exercise, you will be able to: 
 Understand Error stream redirection 
 Access errors in the current session 
 Force non-terminating errors to act as terminating errors 
#>

#region Task 6.1.1: Redirection Operators

# Reference: Get-Help -Name about_Redirection -ShowWindow
# 1. Execute the following command and consider the output: 
'C:\windows','C:\fakefolder','C:\users' | Get-Item 
# 2. What can we add to the above command to redirect the error stream so that no errors are contained in the console output: 
#    Hint: Redirect the errors to a new file at c:\pshell\labs\lab_6\6.1.1.errors.txt, then open the file with PowerShell using notepad (i.e.: notepad c:\pshell\labs\lab_6\6.1.1.errors.txt)

# Answer: 
'C:\windows','C:\fakefolder','C:\users' | Get-Item 2> C:\pshell\labs\lab_6\6.1.1.errors.txt

# 3. Try using multiple redirection operators on the same command. Expand on your command in step 2 to both redirect the error output to one file, and the success output to another file 
# NOTE: While the Redirection operators are useful to simply store any errors in a text file, we lose the ability to handle the error as a rich PowerShell objects. 

#endregion 6.1.1

#region Task 6.1.2: $Error automatic variable
# 1. The $Error automatic variable contains an array of error objects that represent the most recent errors. 
#    Type the command below to view the most recent error. 
$Error[0] 
# 2. Create a new error by typing the following command: 
Get-Item -path C:\FakeFile 
# a. Use the Get-Member cmdlet to determine what properties are available on the ErrorRecord object.

# Answer: 
Get-Item -Path c:\fakefile | Get-Member 
# BUG: Should be:
$error[0] | Get-Member

#    Note that some of the properties contain other objects. 
# b. What command will produce just the specific error message as a string (i.e. Cannot find path 'C:\FakeFile' because it does not exist.)? 

# Answer: 
$error[0].Exception.Message

#endregion 6.1.2

#region Task 6.1.3: -ErrorVariable common parameter

# 1. Run the following command to clear the $Error variable: 
$Error.Clear() 

# 2. Modify the command below to generate a new error and store that error object in a user-defined variable named "myError" using the -ErrorVariable common parameter: 
Test-Connection fakeserver -Count 1 

# Answer: 
Test-Connection fakeserver -Count 1 -ErrorVariable myError 

# 3. Display the most recent error using the $myError variable.
# Answer:
$myError

# 4. Display the most recent error using the $error variable.
# Answer
$error[0] 
 
<#
NOTE:  
    The above command will overwrite the $myError variable each time it is run. This is different from the $Error automatic variable which continually prepends errors up to the $MaximumErrorCount limit. 
    The error records for $error uses a stack, like a stack of plates, where the most recently washed plate is placed at the top of the stack and can be indexed with an array reference of $error[0].
    To append errors in –ErrorVariable, like $Error, prefix the error variable name with a “+” symbol (i.e. –ErrorVariable +myError). 
    The -ErrorVariable common parameter variable however behaves like a queue, where the most recent error is referenced as the last element in the array.
#>
# 4. By default all errors that are raised are added to the $Error array. 
# What common parameter and parameter value can you use to prevent this from happening? 

# Answer: 
# -ErrrorAction Ignore

#>

#endregion 6.1.3

#region Task 6.1.4: $ErrorActionPreference and $WarningPreference
<#
PowerShell uses preference variables to affect the Windows PowerShell operating environment and all commands run in the environment (current session). 
In many cases, the cmdlets have parameters that you can use to override the preference behavior for a specific command. 
Alternatively, you can modify the preference variables to change the default behavior.

# Reference: Get-Help -Name about_Preference_Variables -ShowWindow

1. Determine the default values for the following preference variables relating to error handling: 
    $ErrorActionPreference = ?  
    $WarningPreference = ?
    $VerbosePreference = ?
    $ErrorView = ?
#>

# Answer
<#
$ErrorActionPreference = continue
$WarningPreference = continue
$VerbosePreference = 
$ErrorView
#>

# 2. The above preference variables also control the output of the various Write- cmdlets. 
#    Execute the following command  
Write-Verbose "this is a verbose message"
  
# 3. Note: The above command produces no output. 
# Change the value of the appropriate preference variable to show the output in the console, and re-run the command in step 2 to observe the result: 

# Answer
$VerbosePreference = "Continue"
Write-Verbose "This is a verbose message"

# 4. Now we'll revert the $VerbosePreference value from "Continue" to the default "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

# 5. Modify the command above to display the message using the -Verbose common parameter.

# Answer:
Write-Verbose "This is a verbose message" -Verbose

# This is the other approach we can use to display verbose messages on a Cmdlet by Cmdlet basis, even if the bult-in system preference variable $VerbosePreference is set to "SilentlyContinue"

#endregion 6.1.4

#endregion 6.1

#region EXERCISE 6.2: TERMINATING ERRORS
<#

    Introduction  

    A terminating error stops a statement from running. 
    If Windows PowerShell does not handle a terminating error in some way, Windows PowerShell also stops running the function or script. 
 
    Objectives  

    After completing this exercise, you will be able to: 
     Understand the difference between terminating and non-terminating errors 
     Enhance scripts to handle different errors

#>

#region Task 6.2.1: Throw keyword

# 1. The function below accepts a parameter to define a CSV file to process, which will create a new set of users.

function ProcessUserFile
{
    param
    (
        $userFile
    ) # end param

    $users = Import-Csv -Path $userFile 
    foreach ($user in $users)
    {
        Write-Host "Adding user: $($user.name)"
        $user | New-ADUser -Enable $true
    } # end foreach
    Write-Host "Processing Complete"
} # end function

# 2. Load the function into memory by selecting it and pressing F8.

# 3. Call the function using the command below, which does not specify the UserFile parameter. 

ProcessUserFile

# 4. Take note of the error message that results.

<#
    If the end user was not familiar with the internal working of the function, i.e. Import-CSV and New-ADUser, then the resulting error message might not make sense. 
    Also, note how the function still executes the last Write-Host cmdlet. 
#>

# 3. Complete the following steps to add some basic error handling to the function for the case of an unspecified parameter. 
#    a. Modify the Param statement to include a default expression for the $UserFile parameter 

# Answer:
# Param($UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n"))

# Modified function
function ProcessUserFile
{
    param(
        $UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n")
    ) # end param

    $users = Import-Csv -Path $userFile 
    foreach ($user in $users)
    {
        Write-Host "Adding user: $($user.name)"
        $user | New-ADUser -Enable $true
    } # end foreach
    Write-Host "Processing Complete"
} # end function

# 4. Select the modified function and press F8 to re-load the function.

# 5. Call the function again with the UserFile parameter unspecified.
ProcessUserFile

<#
Now the resulting error message is more specific and user friendly. 
As the UserFile parameter was unspecified, the sub-expression containing the Throw keyword is executed which generates a terminating error and stops PowerShell from executing the rest of the function. 
Now, execution stops before the ‘Write-Host’ cmdlet. 
 
NOTE: 
The advanced function features discussed in Module 3 can achieve a similar result using the Mandatory parameter attribute. 
However, this method highlights the Throw keyword to generate a terminating error. 

6. Add the following additional checks to the script to validate the UserFile parameter value. 
    Use the Throw statement to generate a user-friendly error describing the failed check: 
    a. Ensure the value of $UserFile is a [String] type 
    b. Ensure the string points to a valid file 
    c. Ensure the file has a file extension of ‘csv’ 

NOTE: 
The expression used with the Throw command can be an object or a string. 
This populates the targetObject property on the resulting error object. 
#>

# Modified function
function ProcessUserFile
{
    param(
        $UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n")
    ) # end param

    switch ($UserFile)
    {
     {$_ -isnot [string]} {throw "ERROR: Please specify a string value for the UserFile Parameter"}
     {!(Test-Path -Path $_)} {throw "ERROR: File not found"}
     {(Get-Item -path $_).Extension -ne '.csv'} {throw "ERROR: Please specify a CSV file"}
     default { Write-Verbose "Validation complete" -Verbose }   
    } # end switch

    $users = Import-Csv -Path $userFile 
    foreach ($user in $users)
    {
        Write-Host "Adding user: $($user.name)"
        $user | New-ADUser -Enable $true
    } # end foreach
    Write-Host "Processing Complete"
} # end function

# 7. Select the modified function and press F8 to re-load the function.

# 8. Call the function again 3 times to attempt triggering each of the 3 switch conditions with the commands below.
#    NOTE: Run each command separately by selecting it and pressing F8. 
#    Observe the error messages to determine which throw statements were triggered.

ProcessUserFile -UserFile 2

ProcessUserFile -UserFile "InvalidPath"

ProcessUserFile -UserFile "c:\pshell\labs\lab_6\users1.bad"

#endregion 6.2.1

#region Task 6.2.2: Try-Catch-Finally
<#

    From the function in the previous section, consider the foreach script block. 
    Some possible errors with this segment of code may include:
    
    1. Can't access the DC
    2. CSV is not a real csv file or badly formatted
    3. CSV file contains incorrect properties / column headers
    4. Inadequate permissions (Access Denied)
    5. User already exists
    6. The ActiveDirectory module is not available
#>

# 1. Now we'll modify the script by adding a set of try-catch-finally blocks. 

# Modified function
function ProcessUserFile
{
    param(
        $UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n")
    ) # end param

    switch ($UserFile)
    {
     {$_ -isnot [string]} {throw "ERROR: Please specify a string value for the UserFile Parameter"}
     {!(Test-Path -Path $_)} {throw "ERROR: File not found"}
     {(Get-Item -path $_).Extension -ne '.csv'} {throw "ERROR: Please specify a CSV file"}
     default { Write-Verbose "Validation complete" -Verbose }   
    } # end switch

    # Adding try-catch-finally
    try
    {
        $users = Import-Csv -Path $userFile 
        foreach ($user in $users)
        {
            Write-Host "Adding user: $($user.name)"
            $user | New-ADUser -Enable $true
        } # end foreach  
    } # end try
    catch 
    {
        Write-Host "An unknown error occurred"         
        Write-Verbose $_ -Verbose
    } # end catch
    finally 
    {
        Write-Host "Processing Complete"
    } #end finally
} # end function

<#
    2. The above example will catch any terminating errors that get thrown within the Try{} scriptblock. 
       If an error is thrown, then the Catch{} scriptblock will be executed. 
       The Finally{} script block is executed regardless of whether or not a terminating error is thrown.  
       
       However, the New-ADUser cmdlet also generates some non-terminating errors. 
       In order to catch these as well, we need to change the ErrorAction to Stop: 

       Try
       { 
            ForEach ($User in $Users)
            { 
                Write-Host "Adding User: $($User.Name)..."             
                $User | New-ADUser -Enabled $True –ErrorAction Stop         
            } # end foreach    
       } # end try

    3. Here is the content of the c:\pshell\lab_6\users1.csv file. 
    
        [users1.csv]
        fname,lname
        Rusty,Gates
        
        Notice that it doesn't have the correct information needed to add a new user to AD, since the SAMAccountName, Name and Path properties are missing.
#> 

# Modified function
function ProcessUserFile
{
    param(
        $UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n")
    ) # end param

    switch ($UserFile)
    {
     {$_ -isnot [string]} {throw "ERROR: Please specify a string value for the UserFile Parameter"}
     {!(Test-Path -Path $_)} {throw "ERROR: File not found"}
     {(Get-Item -path $_).Extension -ne '.csv'} {throw "ERROR: Please specify a CSV file"}
     default { Write-Verbose "Validation complete" -Verbose }   
    } # end switch

    # Adding try-catch-finally
    try
    {
        $users = Import-Csv -Path $userFile 
        foreach ($user in $users)
        {
            Write-Host "Adding user: $($user.name)"
            $user | New-ADUser -Enable $true -ErrorAction Stop
        } # end foreach  
    } # end try
    catch 
    {
        Write-Host "An unknown error occurred"         
        Write-Verbose $_ -Verbose
    } # end catch
    finally 
    {
        Write-Host "Processing Complete"
    } #end finally
} # end function

# 4. Select the modified function above and press F8 to re-load it into memory.

# 5. In the command pane, call the function using the incorrect CSV file as the input: 
ProcessUserFile -UserFile C:\PShell\labs\Lab_6\users1.csv

# 6. Note the error that was generated:
#    New-ADUser : The input object cannot be bound to any parameters for the command either because the command does not take pipeline input and its properties do not match any of the parameters that take pipeline input.

<#

    8. As the catch command does not specify a particular exception, it will catch any exception. 
    
    9. Next, add another Catch block immediately after the Try block to specifically catch a ParameterBinding exception: 
       
       Catch [System.Management.Automation.ParameterBindingException]
       {     
            Write-Host "The CSV file provided does not contain the correct information."     
            Write-Host "The CSV file must contain the following values at minimum:"     Write-Host "`tSAMAccountName"     
            Write-Host "`tName"     
            Write-Host "`tPath"     
            Write-Verbose $_ -Verbose 
       } # end catch
        
       Catch
       {     
            Write-Host "An unknown error occurred"     
            Write-Verbose $_ 
       } # end catch 
#>

# Modified function
function ProcessUserFile
{
    param(
        $UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n")
    ) # end param

    switch ($UserFile)
    {
     {$_ -isnot [string]} {throw "ERROR: Please specify a string value for the UserFile Parameter"}
     {!(Test-Path -Path $_)} {throw "ERROR: File not found"}
     {(Get-Item -path $_).Extension -ne '.csv'} {throw "ERROR: Please specify a CSV file"}
     default { Write-Verbose "Validation complete" -Verbose }   
    } # end switch

    # Modifying try-catch-finally
    try
    {
        $users = Import-Csv -Path $userFile 
        foreach ($user in $users)
        {
            Write-Host "Adding user: $($user.name)"
            $user | New-ADUser -Enable $true -ErrorAction Stop
        } # end foreach  
    } # end try

    Catch [System.Management.Automation.ParameterBindingException]
    {     
        Write-Host "The CSV file provided does not contain the correct information."     
        Write-Host "The CSV file must contain the following values at minimum:"     Write-Host "`tSAMAccountName"     
        Write-Host "`tName"     
        Write-Host "`tPath"     
        Write-Verbose $_ -Verbose 
    } # end catch
        
    Catch
    {     
        Write-Host "An unknown error occurred"     
        Write-Verbose $_ 
    } # end catch 

    finally 
    {
        Write-Host "Processing Complete"
    } #end finally
} # end function

# 9. Reload and call the function again with the same users1.csv 
ProcessUserFile -UserFile C:\pshell\labs\lab_6\users1.csv

<#
    10.The result below should appear in the console pane:

    Adding user: ...
    The CSV file provided does not contain the correct information.
    The CSV file must contain the following values at minimum.
        SAMAccountName
        Name
        Path
    Processing Complete
#>
<#

11. Now, when the function throws a ParameterBindingException, the first catch block will execute, giving the user a friendly response. 
You can have as many catch blocks as required, and a single catch block can catch multiple exception types. 

The Write-Verbose cmdlets can also be used in these catch blocks to display additional information by using the -Verbose switch (for advanced functions) or $VerbosePreference. 

NOTE: Catch blocks require the full name of the exception. Investigate the error object to determine the full exception name so it can be caught. 
#>

# 10. Execute the following command to generate an error. Reference: Get-Help -Name about_Preference_Variables -ShowWindow (search for $ErrorView)
Fake-Cmdlet 
# 11. Using the $Error[0] object, determine how to find the full name of the exception. Write the command and the exception below 
#>

# Answer
$Error[0].Exception.ToString()

#endregion 6.2.2

#endregion 6.2

#region EXERCISE 6.3: CUSTOM ERROR MESSAGES
<#
Introduction
 
Windows PowerShell includes a number of cmdlets to generate arbitrary custom errors and warnings. 
 
Objectives  

After completing this exercise, you will be able to: 
 Generate custom non-terminating errors 
 Generate custom warnings 
#>

#region Task 6.3.1: Write-Error
<#

    The Write-Error cmdlet generates a custom non-terminating error.  
    Reference: Get-Help -Name Write-Error -ShowWindow

    1. Execute the following command: 
#>
    
Write-Error "PEBCAK Detected" 

<# 
    Note that while the error is non-terminating it still gets added to the $Error variable 
    
    2. You can also add information to the Error object. 
    Try the following example: 
#>

# BUG: Category, CategoryActivity and RecommendedAction not available
Write-Error -Message "PEBCAK" -Exception "UserException" -Category InvalidArgument -CategoryActivity "FollowingInstructions" -RecommendedAction "Resubmit" 

<#
    3. View the resulting error object 
#>

$Error[0] | Select-Object -Property * 

#endregion 6.3.1

#region Task 6.3.2: Write-Warning
<#
Similar to Write-Error, the Write-Warning cmdlet writes a warning message to the Windows PowerShell host. 
The response to the warning depends on the value of the user's $WarningPreference variable and the use of the WarningAction common parameter 
1. Run the following commands together in the console pane: 
#>

Write-Warning "Low disk space detected" 

# NOTE: Unlike Write-Error and Throw, Write-Warning does not add to the $Error variable, even if the WarningAction or $WarningPreference is set to Stop.

#endregion 6.3.2

#endregion 6.3