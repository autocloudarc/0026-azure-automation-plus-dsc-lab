#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module 9: Introduction to Powershell Workflows
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
    LAB 9: INTRODUCTION TO POWERSHELL WORKFLOW
        Exercise 9.1: WORKFLOW DEFINTION AND HELP TOPICS
            Task 9.1.1: Workflow Definition and Help Topics
        Exercise 9.2: WORKFLOW & ACTIVITY SYNTAX
            Task 9.2.1: Workflow Keyword & Common Parameters
        Exercise 9.3: CONTROLLING WORKFLOW EXECUTION
            Task 9.3.1: Parallel and Foreach -Parallel Keywords
            Task 9.3.2: Comparing Serial and Parallel Workflow Execution
            Task 9.3.3: Sequence & InlineScript Keywords
#>
#endregion contents

<#
    Introduction  
    
    In this lab, you will explore the Windows PowerShell v4.0 native integration with Windows Workflow Foundation (WWF).  
    
    Objectives  
    
     Articulate basic workflow concepts 
     Understand workflow syntax to write simple workflows that are: 
        o Asynchronous 
        o Interruptible 
        o Parallelizable  
    
    Prerequisites 
    
    Start all VMs provided for the workshop labs. Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
    
    Estimated time to complete this lab  60 minutes 
    
    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE). 
    Each lab has its own files. For example, the lab exercises for module 9 have a folder at C:\PShell\Labs\Lab_9 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.  
    
    Scenario  
    
    Your company has a requirement to execute long-running tasks that can survive unexpected outages across many remote machines. You need to gain a basic understanding of what a workflow is, its syntax, capabilities and how it can improve the speed and robustness of your company’s daily IT operations. 
#>

#region Exercise 9.1: WORKFLOW DEFINTION AND HELP TOPICS

<#
    Objectives  
    
    In this exercise, you will: 
     Work with fundamental PowerShell Workflow concepts 
     Load the PSWorkflow module to gain access to help topics and workflow commands
#>

#region Task 9.1.1: Workflow Definition and Help Topics
<#
    Windows PowerShell [workflows] are commands that consist of an ordered [sequnce] of related [activities]. 
    Their purpose is to [reliably] execute long-running [tasks] accross [multiple] computers, devices or IT processes.

    References:
    1. Get-Help -Name about_Workflows -ShowWindow
    2. Get-Help -Name about_WorkflowCommonParameters -ShowWindow
    3. Get-Help -Name about_ActivityCommonParameters -ShowWindow
    4. Get-Help -Name about_Checkpiont-Workflow -ShowWindow
    5. Get-Help -Name about_Suspend-Workflow -ShowWindow 
    6. Get-Help -Name about_Foreach-Parallel -ShowWindow
    7. Get-Help -Name about_InlineScript -ShowWindow
    8. Get-Help -Name about_Parallel -ShowWindow
    9. Get-Help -Name about_Sequence -ShowWindow
#>
# 1. Type and execute the command you would use to install the PowerShell workflow help topic files.

# Answer:

#endregion 9.1.1

#endregion 9.1

#region Exercise 9.2: WORKFLOW & ACTIVITY SYNTAX
<#
    Objectives  
    
    In this exercise, you will: 
     Create and execute a basic workflow 
     Execute a workflow on multiple/remote machines 
     Work with workflow common parameters 
#>

#region Task 9.2.1: Workflow Keyword & Common Parameters
<#
    1. Log on to the WIN8-WS virtual machine as user Contoso\DanPark with password PowerShell4. 

    2. Open the Windows PowerShell ISE. 
       In the console pane, define a new workflow using the workflow keyword and a unique name. 
       Notice that the syntax is identical to a function definition. 
       The body of the workflow is contained in curly braces. 
#>
       
workflow Get-EventWF 
{  
    Get-WinEvent –LogName System –MaxEvents 10  
} # end workflow 

<#
   3. Run the script to define the workflow in the current session. 
   4. Run the workflow as shown below. 
#>

Get-EventWF

<#
   5. On which machine did execution of the workflow occur? 

      Answer:
    
   6. Create a list of computer names & store it in a variable. 
#>
   $Computers = “2012R2-MS”, “2012R2-DC”, “WIN8-WS” 
<# 
   7. Use the PSComputerName workflow common parameter to execute the workflow on all the machines in the list.  
    
      NOTE:  Common workflow parameters are automatically available. 
      The PS* prefixed parameters configure the connection and execution environment on the remote machines, rather than the workflow server. 
#>

# Modified script
workflow Get-EventWF 
{  
    Get-WinEvent –LogName System –MaxEvents 10  
} # end workflow 

$Computers = “2012R2-MS”, “2012R2-DC”, “WIN8-WS” 
Get-EventWF –PSComputerName $Computers 

<#
   8. Did the command work correctly? 
      Answer:

        NOTE:  
        This step should create an error. 
        If it did not, then make sure you are logged on as Contoso\DanPark. 

   9. Find the common parameter that allows the workflow to run under alternate credentials. 
      Reference: Get-Help -name about_Workflow_Common_Parameters -ShowWindow
      Answer:
     
   10.Run the workflow again specifying the Contoso\Administrator credentials. 
      The remote workflow should run successfully. 
#>

Get-EventWF –PSComputerName $Computers –PSCredential Contoso\Administrator 

<#
   11. Refer to the online help document: https://docs.microsoft.com/en-us/powershell/module/psworkflow/about/about_workflowcommonparameters?view=powershell-5.1
   
   Circle Yes or No (using parenthesis "()") for the following questions. 
   a) Can you use workflow common parameters positionally? Yes/(No) 
   b) Do workflow common parameters accept arguments from the pipeline? Yes/(No) 
   c) By default, does the PSPersist parameter create a checkpoint at the start and end of a workflow? (Yes)/No 
   d) Does WS-Management encrypt all of the data transmitted over the network? (Yes:See -PSUseSSL)/No
   e) Does the PSConfigurationName parameter control the session name to connect to on the workflow server computer? Yes/(No:Only the target servers <nodes>) 
   
   10. Workflows are analogous to PowerShell functions. In the list below, indicate which statements are true or false. 
       Reference: Get-Help -Name about_Workflows -ShowWindow
         Workflow activities run in the same PowerShell session on the workflow server. [false]
         Logging and recovery features are included in the workflow engine. [true]
         Workflow activities can only be executed sequentially. [false]
         Workflows can be paused and restarted. [true]
         Workflows can only be executed remotely using the Invoke-Command cmdlets. [false: You can also use Invoke-AsWorkflow]
         Workflow state can be maintained and recovered after an unexpected outage. [true]
    
    11. The Windows PowerShell engine converts PowerShell workflows into their native Windows Workflow Foundation representation, XAML (Xml Application Markup Language). 
    View the XAML representation of the workflow using the workflow command’s XamlDefinition metadata. 
    #>

(Get-Command Get-EventWF).XamlDefinition
#endregion 9.2.1

#endregion 9.2

#region Exercise 9.3: CONTROLLING WORKFLOW EXECUTION
<#
    Objectives  
    
    In this exercise, you will: 
     Work with workflow features such as parallelization, sequencing, and inline script activities. 
 
    Scenario  
    
    As we have seen, workflow activities are not implemented for all core PowerShell cmdlets. 
    However, the InlineScript activity allows all cmdlets in the modules included in Windows 8.1 and Windows Server 2012 to execute within a workflow. 
#>

#region Task 9.3.1: Parallel and Foreach -Parallel Keywords
<#
    1. Each activity in a workflow executes in its own environment. 
       Each activity can run in parallel, when enclosed in a Parallel activity script block.  
       Type the code below into the PowerShell ISE script pane. 
#>

workflow Test-SerialWF  
{ 
    Get-CimInstance -ClassName Win32_ComputerSystem 
    Get-WinEvent -LogName System -MaxEvents 1 | Select-Object -Property ProviderName,ID,Level 
    Get-CimInstance -ClassName Win32_Bios 
    Get-Process -Name Explorer 
} # end workflow 
    
<#
2. Execute the workflow 5 times by typing its name in the Windows PowerShell ISE console pane and pressing Enter. 
#>

Test-SerialWF 

<#
3. Next, make a copy of the workflow you just created and paste it below in the script pane. 
Modify the workflow name to “Test-ParallelWF”. 
Add the parallel activity keyword and its scriptblock curly braces around the statements in the workflow body. 
#>

workflow Test-ParallelWF 
{ 
    parallel 
    { 
        Get-CimInstance -ClassName Win32_ComputerSystem 
        Get-WinEvent -LogName System -MaxEvents 1 |  Select-Object -Property ProviderName,ID,Level 
        Get-CimInstance -ClassName Win32_Bios 
        Get-Process -Name Explorer 
    } # end parallel
} # end workflow   

<#
4. Run the Test-ParallelWF workflow 5 times. 
#>

Test-ParallelWF 
<#
   Describe the difference in output between the two workflows.  

   Answer: 
 
   NOTE:  It may take more than five times to produce the intended result.  
   At some point, you may notice that the results return in a different order due to parallel execution. 
   
   5. Workflows provide asynchronous activity execution capability using a ForEach -Parallel statement. 
      The statement iterates through a collection, executing activities in parallel, rather than one after the other. 
      Type the workflow below into a new Windows PowerShell ISE script pane. 
#>

workflow Test-ForEachParallelWF  
{     
    $computers = "2012R2-MS", "2012R2-DC", "WIN8-WS" 
    Foreach -Parallel ($computer in $computers)      
    {         
        Get-Process -PSComputerName $computer -Name csrss     
    } # end foreach 
} # end workflow

<#
    6. Run the script to define the new workflow. 
    
    7. Save the Contoso\Administrator credentials in a new credential object. 
#>

$cred = Get-Credential Contoso\Administrator 

<#
    8. Run the Test-ForEachParallelWF command multiple times. 
       Notice that each computer’s results present in a slightly different order each time. 
#>    
       1..10 | Foreach-Object {Test-ForEachParallelWF -PSCredential $cred} 
<#       
    9. The PSComputerName property displays “Localhost” for each process. 
       The Get-Process cmdlet is actually a workflow activity, executed locally within the workflow engine on each machine. 
       To display the computer name we can modify the function to extend each process object’s members. 
<#
       TIP: All objects in Windows PowerShell are instances of the PSCustomObject data type. 
       This data type creates a layer that wraps objects from any of the object models Windows PowerShell supports. 
       Add custom members (properties and methods) to this object using the Add-Member Cmdlet. 
       See Get-Help Add-Member for more information. 

       Modify the Test-ForEachParallelWF workflow to add a new property called “WFNodeName” that stores the current computer name. 
#>
workflow Test-ForEachParallelWF  
{     
    $computers = "2012R2-MS", "2012R2-DC", "WIN8-WS" 
    Foreach -Parallel ($computer in $computers)      
    {         
        Get-Process -PSComputerName $computer -Name csrss | Add-Member -MemberType NoteProperty -Name WFNodeName -Value $computer -PassThru     
    } # end foreach
} # end workflow

<#
    10. Define and execute the workflow ten times, using the pipeline below. 
#>    
    1..10 | ForEach-Object {Test-ForEachParallelWF -PSCredential $cred} |  Select-Object -Property WFNodeName, Name, Id 
<#
    NOTE:  Make sure you add the pipe character at the end of the Get-Process line.  Make sure that you test with the updated pipeline above. 
    
    11. A simpler way to execute in parallel across multiple machines and return the PSComputerName is to use the Workflow Common Parameter PSComputerName. 
        This parameter actually executes in parallel across all computer names passed to it. Try the code below: 
#>
workflow Test-ParallelWF_PSComputerName 
{         
    Get-Process -Name csrss 
} # end workflow 

$computers = "2012R2-MS", "2012R2-DC", "WIN8-WS" 
$cred = Get-Credential Contoso\Administrator 
1..10 | Foreach-Object {     Write-Host $_  Test-ParallelWF_PSComputerName -PSCredential $cred -PSComputerName $computers }

#endregion 9.3.1

#region Task 9.3.2: Comparing Serial and Parallel Workflow Execution
<#
    1. Write a simple workflow to display ‘Informational level’ log entries of the last 7 days for each machine in the domain. Name the workflow Serial-EventLogWF. Save the script as C:\PShell\Labs\Lab_9\SerialParallelWorkflows.ps1 Use the Get-WinEvent cmdlet’s –FilterHashTable parameter to filter the log entries. Use the $Filter variable, below, as the –FilterHashTable parameter value. 
       $lastWeek = (Get-Date).AddDays(-7) $Filter = @{LogName='System'; Level=3; StartTime=$lastWeek} 

    2. Make a copy of the previous workflow, name it Parallel-EventlogWF and add a  –Parallel switch to the ForEach script block within the workflow body. 
    
    3. Time the commands’ execution using the Measure-Command cmdlet. 
       Record and compare the execution times of the two workflows in the table below.  
       Run each command three times for comparison and record the average time for each.
 
      [Workflow Name]      | [Execution Times (TotalSeconds)]
      Serial-EventLogWF    | ?
      Parallel-EventlogWF  | ?
 
      NOTE: A solution is in C:\Pshell\LabFiles\Lab_9\9.3.2.ps1 on WIN8-WS. 

4. Think of a scenario where this technique could improve efficiency in your daily scripting tasks.  

#>
#endregion 9.3.2

#region Task 9.3.3: Sequence & InlineScript Keywords
<#
    We have seen how to parallelize activities within a workflow, but what if we are required to execute some workflow steps in a serial fashion and others in parallel? 
    PowerShell Workflow implements the Sequence keyword specifically for this scenario. 
    The workflow below calculates the percentage of free disk space on the C: volume of each computer in the domain. 
    
    1. First, store the machine list in a variable. 
#>
$Computers = “2012R2-MS”, “2012R2-DC”, “WIN8-WS” 
<#
    2. Use the workflow keyword to define a new workflow 
       workflow Test-SequenceInlineScriptWF { 
    
    3. Add a Parallel keyword, scriptblock, and a Get-CimInstance activity that retrieves the computer’s operating system details. 
       Parallel {     Get-CimInstance -ClassName Win32_OperatingSystem 
       
    4. Add another Get-CimInstance activity to collect size and freespace information from the computer’s C: volume and calculate the percentage of free disk space. 
       It is imperative these commands run in sequence, so they are placed within a Sequence scriptblock, within the Parallel scriptblock 
       Sequence {      $disk = Get-CimInstance -Query "Select freespace,size from Win32_LogicalDisk Where DeviceID='C:'"                  

    5. An InlineScript keyword is required when a non-native workflow command (classic Cmdlet, .NET Method, etc.) is used.  
       The commands run in a separate PowerShell process (PowerShell.exe), rather than the Windows Workflow engine. 
       In this example, we calculate the percentage of free disk space and round the result to two decimal places. 
        
       TIP:  Accessing a variable defined in another part of the workflow is achieved with the $using variable scope modifier. 
       In this example the $disk variable can be accessed from within the InlineScript block with the syntax $using:disk 

       InlineScript 
       { 
        $percentFree = [Math]::Round($(($using:disk.freespace/$using:disk.size)*100),2)        
        "$PSComputerName : $percentFree %"        }                   }    }    } 

        NOTE:  The full script is provided here: C:\PShell\Labs\Lab_9\9.3.3.ps1. 

    6. To run the workflow against multiple machines we can take advantage of the -PSComputerName common workflow parameter. 
       Pass the array of computer names created in step 1 of the task and the parameter value. 
       
       $cred = Get-Credential Contoso\Administrator Test-SequenceInlineScriptWF -PSComputerName $computers -PSCredential $cred 
       
    7. Why do you not have to specify the -PSComputerName parameter for each of the Get-CimInstance activities? 
       
       HINT:  See the -PSComputerName parameter in Get-Help about_Workflow_Common_Parameters. 
    
       Answer: 
      
#>
#endregion 9.3.3

#endregion 9.3
