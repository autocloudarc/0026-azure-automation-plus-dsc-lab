#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 7: Debugging
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
    LAB 7: DEBUGGING
        Exercise 7.1: STRICT MODE AND DEBUG OUTPUT
            Task 7.1.1: Turn on Windows PowerShell Strict Mode
            Task 7.1.2: Write-Debug & Write-Verbose Cmdlets
            Task 7.1.3: Set-PSDebug Cmdlet
        Exercise 7.2: THE WINDOWS POWERSHELL DEBUGGER
            Task 7.2.1: Using the ISE debugger
            Task 7.2.2: The Set-PSBreakpoint Cmdlet
            Task 7.2.3: Debugging Windows Powershell Workflows
#>
#endregion contents

<#
    Introduction 
    
    Understanding how to debug PowerShell scripts is a core competency for development of robust, production-ready code.  As scripts become more complex, debugging techniques becomes correspondingly more important. 

    Objectives  
    
    After completing this lab, you will be able to:  Understand and use cmdlets-based techniques for debugging in PowerShell 
     Use the debugger within the PowerShell ISE 
     Use Trace-Command to gain understanding of PowerShell’s internal mechanisms for running cmdlets 

    Prerequisites 
    
    Start all VMs provided for the workshop labs. Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
    
    Estimated time to complete this lab  45 minutes 

    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE).  
    Each lab has its own files. For example, the lab exercises for module 7 have a folder at C:\PShell\Labs\Lab_7 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. 
    When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.
#>

#region Exercise 7.1: STRICT MODE AND DEBUG OUTPUT
<#
    Introduction  

    Windows PowerShell provides a Set-Strictmode cmdlet. 
    Use this to detect many common scripting errors such as uninitialized variables and null references.  
    In this exercise you will explore this cmdlet, together with cmdlets for displaying debug information to the console. 
    
    Objectives  
    
    After completing this exercise, you will be able to: 
     Use the Set-StrictMode cmdlet to detect common scripting errors 
     Use the Write-Debug and Write-Verbose cmdlets to display runtime output 
     Use the Set-PSDebug cmdlet to enable detailed script tracing 
#>

#region Task 7.1.1: Turn on Windows PowerShell Strict Mode
<#
    The Set-StrictMode cmdlet tells Windows PowerShell to raise errors if script code violates best practices.  
#>

<#
1. The code below represents an excerpt from you large new production script. 
   You recieve calls from staff complaining that the script does not always work correctly.
   Reviewing it by eye, nothing in the logic looks incorrect, yet the calls still come in. 
   
2. Examine the code.  

3. Select and execute the code.  
#>

#SampleMistake.ps1
$TransferApprovedSuccessfully=$false
# lots of code doing things

$TransferApprovedSuccessfully=$true 
# lots more code...

if ($TransferApprovedSuccesfully -eq $true)
{
    Write-Output "€100m funds transfer underway"
    # lots more code...
} # end if
else
{
    Write-Output "Awaiting funds."
} # end else

<#
4. Before you deploy the script into production, turn on strict mode to catch common scripting errors.  
   Within the Script Pane, at the top of your script, add the following command: Set-StrictMode -Version Latest
#>

# Modified code

#SampleMistake.ps1
Set-StrictMode -Version Latest
$TransferApprovedSuccessfully=$false
# lots of code doing things

$TransferApprovedSuccessfully=$true 
# lots more code...

if ($TransferApprovedSuccesfully -eq $true)
{
    Write-Output "€100m funds transfer underway"
    # lots more code...
} # end if
else
{
    Write-Output "Awaiting funds."
} # end else

<#
5. Re-load and execute the script again.

6. Identify the cause for the staff complaints and record it below.
#>

# Answer:
<#
The variable '$TransferApprovedSuccesfully' cannot be retrieved because it has not been set.
At line:10 char:5
+ if ($TransferApprovedSuccesfully -eq $true)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (TransferApprovedSuccesfully:String) [], RuntimeException
    + FullyQualifiedErrorId : VariableIsUndefined
#>
#endregion 7.1.1

#region Task 7.1.2: Write-Debug & Write-Verbose Cmdlets
<#

Use the Write-Debug cmdlet to inform about stages reached and information transfer within a script. 
Perhaps the data is going into a function, which then calls other functions. 
As the author, you want to confirm this. 
Think of Write-Debug output as low-level detail intended for the script developer. 

The Write-Verbose cmdlet outputs informative, visual progress indicators for the person running the code. 

You can determine the current point of execution within a script and, if the information is changing, its current state. 
The Write-Debug cmdlet writes debug messages to the console from a script or command.  

By default, debug messages are not displayed in the console, but they can be displayed on a single Cmdlet basis, by using the -Debug common parameter or by modifying the value of the $DebugPreference variable. 
#>
# 1. Within the ISE, open the file C:\Pshell\Labs\Lab_7\Get_PSversionInfo.ps1 
# 2. Examine the code in the Script Pane and note the use of Write-Verbose and Write-Debug statements. 
# 3. Run the script. 
# 4. Two automatic variables can be set to enable debug and verbose output. 
#    Test by setting each at the top of the script, after #Get-PSversionInfo.ps1 and before the function definition, then run the script again. 
$DebugPreference   = "Continue" 
$VerbosePreference = "Continue" 
# 5. Turn them off when completed.  
#    Add these lines at the end of the script and run it again. 
$DebugPreference   = "SilentlyContinue" 
$VerbosePreference = "SilentlyContinue" 
# 6. Remove the preference variables from the script. 
# 7. Add -Debug and/or -Verbose parameters when calling the Get-PSVersionInfo function.  
#    Add either of these parameters at the end of the function call.  
#    Now run the script again. 
Get-PSVersionInfo "INVALID1","2012R2-DC","2012R2-MS","WIN8-WS","INVALID2" –Debug 
Get-PSVersionInfo "INVALID1","2012R2-DC","2012R2-MS","WIN8-WS","INVALID2" –Verbose 
# 8. Note that the expected Write-Debug or Write-Verbose statements do not work. 
#    Why do you think this is the case? 
# Answer:

# 9. To enable the common parameters -Debug and -Verbose, uncomment the [CmdletBinding()] at the top of the function. 
#    Alter the call to add –Verbose or –Debug or both, so that it looks like the excerpt below. 
Get-PSVersionInfo "INVALID1","2012R2-DC","2012R2-MS","WIN8-WS","INVALID2" ` -Verbose –Debug 
# 10. Run the script and note the information that appears, depending on the presence of the –Verbose or –Debug. 
#>

#endregion 7.1.2

#region Task 7.1.3: Set-PSDebug Cmdlet
<#

The Set-PSDebug command has the ability to turn on detailed, line-by-line tracing of your script.
Reference: Get-Help -Name Set-PSDebug -ShowWindow
 
1. Within the Windows PowerShell ISE, open the file C:\Pshell\Labs\Lab_7\Get_PSversionInfo2.ps1. 
   Examine the code in the Script Pane and note the use of Write-Verbose and Write-Debug statements. 

2. Run the script. 

3. At the top of the script before the function defintion, add the following line: 
   Set-PSDebug -Trace 1 

4. Run the script. 
   Note the line-by-line detailed tracing produced. 

5. Alter the trace level to 2 by modifying the command. 
   Set-PSDebug -Trace 2 

6. Run the script. 
   Examine the extremely detailed trace output, showing variable assignments and function calls. 
   If the step parameter were specified, you would be prompted before each line of the script is executed.
   
7. Turn off the tracing by setting the trace level to 0. 
   Set-PSDebug -Trace 0 
   
8. Run the script. 
   Confirm you now have normal output. 
   Note that the first attempt will still show tracing until the –Trace 0 is executed. 

#>
#endregion 7.1.3

#endregion 7.1

#region Exercise 7.2: THE WINDOWS POWERSHELL DEBUGGER

<#
    Introduction

    Windows PowerShell provides an interactive debugger for use within both the ISE and the PowerShell console.  Explore the mechanisms for initiating and using the debugger. 
    
    Objectives  

    After completing this exercise, you will be able to: 
     Use the ISE debugger
     Use the Set-PSBreakpoint cmdlet 
     Debug Windows PowerShell Workflows 
     Use the Trace-Command cmdlet
#>
#region Task 7.2.1: Using the ISE debugger
<#
    NOTE:  When you set breakpoints, the debugging environment requires that you save the script. 
    
    1. Within the ISE, open the file C:\Pshell\Labs\Lab_7\Debugging1.ps1. 
       Examine the code within the Script Pane. 
       You can see various functions, each setting some variables. 
       You wish to halt at a particular point within your script to examine values. 
    
    2. Put the mouse pointer over line 9 of the script, right-click and select "Toggle Breakpoint". 
       Notice that the selected line: "$cpu" is highlighted in red. 
       
    3. Run the script. 
       Now execution stops at the breakpoint line. 
       Hover the pointer over the $other, $profit and $cup variables variables to examine their current values. 

    4. Click the Debug menu at the top of the ISE. 
       Try each of the Step commands (Step Over, Step Into and Step Out), and then press F5 to run through to completion. 
       
    5. Remove the breakpoint by clicking on the line marked in red and pressing F9. 
#>
#endregion 7.2.1

#region Task 7.2.2: The Set-PSBreakpoint Cmdlet
<#
    The Set-PSBreakpoint cmdlet can create tightly-focused breakpoints on a line, command, or variable. 
    
    NOTE:  To examine special Windows PowerShell variables like $_, assign it to a variable and hover over it. 
    
    1. Open the file C:\Pshell\Labs\Lab_7\Debugging1.ps1 in the ISE. 
       Examine the code within the Script Pane. 
       You wish to halt whenever the $cpu variable is written to, so that you can examine it and the variables around it. 
    
    2. Within the blue Windows PowerShell Console Pane, type the following command: 
#>
       Set-PSBreakpoint -Variable cpu -Mode write -Action {if ($cpu -eq 1) {break}} 
<#    
    3. Run the script. Whenever a variable named $cpu is written, the breakpoint action will occur. 
       You will be able to hover your cursor over the variables in the script pane to examine their current values. 
       
    4. Continue script execution, using either the Debug menu or F5.  
       You may need to repeat this step multiple times until the script completes. 
       
    5. Run the script three more times.  
       Use the Debug Menu to explore the use of the step commands. 
       Notice how they behave when selected on a line with a function call. 
       Notice how they behave on the lines inside a function. 
       
       a. For the first time use ‘Step Over’ (F10) until the script finishes. 
       b. For the second time use ‘Step Into’ (F11) until the script finishes. 
       c. For the third time use ‘Step Out’ (Shift+F11) until the script finishes. 
       
    6. Clear the breakpoint(s) you have set. In the blue Console Pane, type the following command: 
       Get-PSBreakpoint | Remove-PSBreakpoint 
       
    7. After reviewing the variables, you now decide that it is more appropriate to only break when calling the particular function "Step-Into". 
       In the blue Console Pane type the following command: 
       Set-PSBreakpoint -Command Step-Into 
       
    8. Run the script again, noting that the debugger has halted at the entry to the function. 
       You can now use the Step commands to move through the function, isolating where your variables and logic may be behaving in unexpected ways. 
       Use Step Into and at various times hover over your variables to confirm their values. 
       
    9. Let the script run through, or exit the Debugger (SHIFT+F5). 
       Clear the breakpoint(s) you have set. In the blue Console Pane, type the following command. 
       Get-PSBreakpoint | Remove-PSBreakpoint 
       
    10. You now decide that you wish your script to stop whenever calling a particular Cmdlet. 
        In the blue Console Pane, type the following command. 
        Set-PSBreakpoint -Command Test-Connection 
        
    11. Execute the script to confirm reaching the breakpoint. 
    
    12. Let the script run through, or exit the Debugger.  
    
    13. Clear the breakpoint(s) you have set. 
        In the blue Console Pane type the following command: 
        Get-PSBreakpoint | Remove-PSBreakpoint
#>
#endregion 7.2.1

#region Task 7.2.3: Debugging Windows Powershell Workflows
<#
    
    We can use Windows PowerShell debugging to help troubleshoot Workflows. 
    
    To do this they must be running synchronously, not as jobs. 
    
    1. Within the ISE open the file C:\Pshell\Labs\Lab_7\Workflow1.ps1   
    
    2. Just like with the earlier tasks, we can set a breakpoint within the Workflow script. 
       Highlight line 3 and toggle a breakpoint with either a right-click or the F9 key.
         
       Or you can set the breakpoint explicitly with the following command in the console pane: 
       Set-PSbreakpoint -Script $psISE.CurrentFile.FullPath -Line 3 
       
    3. Load the workflow by pressing F5. 
    
    4. Launch the workflow by issuing its workflow name. 
       Type the following command in the console pane: 
       Test-Seq 
    
    5. The workflow will stop at the breakpoint. 
       Now use the Debug menu and Step Into to move through the executing Workflow. 
       Hover over variables with the mouse pointer. 
       Step through to completion or press F5 to finish execution
#>
#endregion 7.2.3

#endregion 7.2
