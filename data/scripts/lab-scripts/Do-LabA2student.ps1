#region Header
<#
    Windows PowwerShell v4.0 for the IT Professional - Part 2
    Module A2: Jobs
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
    LAB A2: WINDOWS POWERSHELL JOBS
        Exercise A2.1: LOCAL JOBS
            Task A2.1.1: Creating and listing jobs
            Task A2.1.2: Receiving job output
            Task A2.1.3: Waiting for job completion
            Task A2.1.4: Investigating filed jobs
        Exercise A2.2: REMOTE JOBS
            Task A2.2.1: Run a job in a remote interactive session
            Task A2.2.2: Start remote jobs and return the results
            Task A2.2.3: Job throttling
            Task A2.2.4: Store remote job results on the remote machine
        Exercise A2.3: SCHEDULED JOB OVERVIEW
            Task A2.3.1: Scheduled Jobs overview and help topics
        Exercise A2.4: SCHEDULED JOB MANAGEMENT
            Task A2.4.1: Creating scheduled jobs, triggers, and job options
            Task A2.4.2: Disablin and removing Scheduled Jobs & Triggers
        Exercise A2.5: SCHEDULED JOB PERMISSIONS
            Task A2.5.1: Run scheduled jobs with an elevated access token
        Exercise A2.6: SCHEDULED JOB OUTPUT
            Task A2.6.1: Receiving job output
            Task A2.6.2: Scheduled job Persistence
#>
#endregion contents

<#
    Introduction  
    
    In this lab, you will become familiar with cmdlets used to configure and manage the Jobs feature in Windows PowerShell. 
    A Windows PowerShell background job is a command that runs in the background, without interacting with the current session. 
    Typically, you use a background job to run a complex command that takes a long time to complete.  
    You will also learn how to schedule Windows PowerShell jobs in the Windows Task Scheduler using the PSScheduledJobs module cmdlets. 
 
    Objectives  
    
    After completing this lab, you will be able to:  Understand job concepts  Create and manage local and background jobs  Receive background job output  Create scheduled jobs, job triggers and job options  Manage and manipulate existing scheduled jobs and job instances  Display scheduled job output  Run scheduled jobs with elevated credentials  
 
    Prerequisites 
    
    Start all VMs provided for the workshop labs. Logon to WIN8-MS as Contoso\Administrator, using the password PowerShell4. 
 
    Estimated time to complete this lab  
    120 minutes 
    
    NOTE: These exercises use many Windows PowerShell Cmdlets. You can type these commands into the Windows PowerShell Integrated Scripting Environment (ISE). 
    Each lab has its own files. For example, the lab exercises for module 7 have a folder at C:\PShell\Labs\Lab_7 on WIN8-WS.  
    We also recommend that you connect to the virtual machines for these labs through Remote Desktop rather than connecting through the Hyper-V console. 
    When you connect with Remote Desktop, you can copy and paste from one virtual machine to another.  
 
    Scenario  

    There is a requirement in your IT department to schedule PowerShell scripts in order to perform administrative tasks, such as parsing log files, copying data and automating monthly reports. You are required to evaluate and learn the PowerShell v4 scheduled job feature in order to implement these solutions
#>

#region Exercise A2.1: LOCAL JOBS
<#
Objectives  

In this exercise, you will explore how to create and manage Windows PowerShell background jobs on the local machine.
#>

#region Task A2.1.1: Creating and listing jobs
<#
1. Open the Windows PowerShell ISE. Start a long running command in the console pane by typing the command below. 
#>
Get-WinEvent –LogName System 
<#
2. The command runs as a single thread within the PowerShell_ISE.exe process, subsequently the console is unavailable while the command runs.  

3. To use the console pane when a long-running command executes, we can start a background job on the local computer with the Start-Job Cmdlet. 
   Use the – ScriptBlock parameter to specify the command to run. 

#>
Start-job –ScriptBlock {Get-ChildItem -Path C:\ -Recurse} 
<#
4. The job queue stores all background jobs for the current session. 
#>
Get-Job 
<#
5. Launch new Windows PowerShell console session and run the Get-Job Cmdlet.  
   Name any jobs listed. 
   Answer:
 
6. Return to the previous Windows PowerShell ISE and start another job. 
   Save the job object in a variable and name the job using the cmdlets –Name parameter.
#> 
$myJob1 = Start-job –ScriptBlock {Get-WinEvent} –Name myJob 
<#
7. Use Get-Member to explore the job object. 
   Review the object’s members and their data types.  
   
8. Find a property that indicates the job has completed. 
   How could you use the Get-Job Cmdlet to return all completed jobs? 
   Write the command below. 
   Answer:
 
9. Once the job stored in the $myJob1 variable is complete, calculate its total execution time. 
   Compare DateTime objects using the subtraction operator. 
   Record the total job execution time below. 
   Answer:
 
10. Job objects have an event member type called “StateChanged” which can be used to detect and, optionally execute code, when the job state changes. 
    The RegisterObjectEvent Cmdlet allows Windows PowerShell to subscribe to an event.  
    
11. Type the commands below to create a new job and register a new event subscription for the job’s “StateChanged” event. 
#>

$myJob1 = Start-Job -ScriptBlock {Get-WinEvent -LogName application -MaxEvents 1000} 
 
Register-ObjectEvent -InputObject $myJob1 -EventName StateChanged `
-SourceIdentifier $myJob1.Name -Action {Write-Host “Job finished!” ForegroundColor red} 
<#
12. The example script C:\PShell\Labs\Lab_4\Get-JobEvent.ps1 shows a more fully featured example. 
Open this script in the Windows PowerShell ISE script pane. The full listing is below. 
#>
$myJob2 = Start-Job -ScriptBlock {Get-WinEvent -LogName application -MaxEvents 1000}  
 
$Action = { 
    $wsh = New-Object -ComObject wscript.shell 
 
    if ($event.Sender.State –eq “Completed”)  
    {    
        $wsh.Popup("Job Name: $($event.SourceIdentifier)       
        Job State: $($event.Sender.State)       
        Command: $($event.Sender.Command)       
        Duration: $(($event.Sender.PSEndTime - $event.Sender.PSBeginTime).Seconds) seconds") 
        Unregister-Event -SourceIdentifier $myJob2.Name 
    } # end if
    else 
    {    
        $wsh.Popup("Job Name: $($event.SourceIdentifier)       
        Job State: $($event.Sender.State)") 
    } # end else
} # end action 
 
Register-ObjectEvent -InputObject $myJob2 -EventName StateChanged -SourceIdentifier $myJob2.Name -Action $Action 
<#
13. What do you think the $event variable represents and how do you think it was created? 
    Answer:

14. Press ‘play’ or hit the f5 key to execute the script.  

15. When the jobs state changes, a dialog box will appear displaying the job name, state, command and duration. 
    This technique demonstrates how to respond to a background job’s state change by subscribing for event notifications. 

16. Add the following line to the end of the script to start, then immediately stop the job. 
#>
Stop-Job $myJob2 
<#
17. Execute the script again. What is the job state? 
    Answer: 
 
18. Use the Get-EventSubscriber Cmdlet to list the current event subscriptions. 

19. Remove the event subscriptions using the pipeline command below. 
#>
Get-EventSubscriber | Unregister-Event 
<#
20. Identify jobs using the command script block configured to run. 
    For example, to find all jobs with the command “Get-WinEvent”, type the command below. 
#>
Get-Job –Command “Get-Winevent*” 
<#
21. Execute the Get-Job Cmdlet. 
    What do you notice about the sequence of integers in the “Id” column? 
    Answer:

22. Pipeline the $myJob2 variable to the Format-list Cmdlet to view all information contained in the job object. 
#>
$myJob2 | Format-List –Property * 
<#
23. Study the “ChildJobs” property. What does it contain? 
    Answer: 
 
24. Each job consists of a parent job (the executive) and a child job. 
    List both the parent and child jobs of a Particular Job. 
    Answer:
#>

Get-Job –Id $myJob2.Id -IncludeChildJob  
<#
25. Use the ChildJobs property to access the child job from the parent job. 
#>
$myJob2.ChildJobs 
<#
In a local job example, child jobs have limited value. 
The concept of parent and child jobs will become far more useful when working with remote jobs. 
#>

#endregion A2.1.1
 
#region Task A2.1.2: Receiving job output
<#
Job execution and job output are stored in separate objects. 
The Receive-Job Cmdlet returns job output. 
Type the command below to view the result of a previous job. 
#>
Receive-Job –Job $myJob2 
<#
1. List the output a second time. 
   What do you notice about the output? 
   Answer:
 
2. In the Windows PowerShell ISE, press play to execute the Get-JobEvent.ps1 script again. 
   Once the GUI dialog has appeared, try receiving the job output again.  
   This time include the –Keep switch parameter. 
#>
Receive-Job –Id $myJob2 -keep 
<#
    Run the Receive-Job command, with the –Keep parameter, again. 
    The results should still be available. 

3. Job output is also available through the job object. 
   Pipe the $myJob2 variable to Getmember.  
   
4. Find a property that holds the job result and use it to display the job output. 
   Write the command below.  Note that the output belongs to the Child Job… 
   Answer:
 
5. Pipe the output to Get-Member. What do you notice about the object’s data type? 
   Answer:
 
#>
#endregion A2.1.1

#region Task A2.1.3: Waiting for job completion
<#
The user interface can be forced to wait until one or more background jobs has completed before allowing further user interaction. 
Type the commands below to view the Wait-Job Cmdlet’s effect. 
 
1. Open the Windows PowerShell ISE and type the following commands into the console pane. 
2. Start a job and pipe it to the Wait-Job cmdlet.
#>
 
Start-Job -ScriptBlock {get-winevent -LogName Application -MaxEvents 1000} | WaitJob 
<#
3. Alternatively, store the job in a variable and pass that to the Wait-Job cmdlet. 
#>
$myJob4 = Start-Job -ScriptBlock {get-winevent -LogName Application -MaxEvents 1000} 
Wait-Job –Job $myJob4 
<#
4. Are you able to use the Windows PowerShell ISE 
   Answer:
#>
#endregion A2.1.1

#region Task A2.1.4: Investigating filed jobs
<#
Failed jobs are inevitable in a distributed computing environment. 
Fortunately, Windows PowerShell jobs have an Error object member that records why a particular job failed.  
1. Start a new background job. 
#>
$myJob4 = Start-Job –ScriptBlock {Get-ChildItem HKLM:\SAM} 
<#
2. Access the job’s Error property to discover why the command failed. 
#>
Get-Job -Id $myJob4.Id -IncludeChildJob | Select-Object -ExpandProperty Error 
<#
3. The error property contains a RemotingErrorRecord object. 
#>
(Get-Job -Id $myJob4.Id -IncludeChildJob).Error | Get-Member 
(Get-Job -Id $myJob4.Id -IncludeChildJob).Error.Exception  (Get-Job -Id $myJob4.Id -IncludeChildJob).Error.Targetobject  
(Get-Job -Id $myJob4.Id -IncludeChildJob).Error.FullyQualifiedErrorId  
(Get-Job -Id $myJob4.Id IncludeChildJob).Error.Exception.SerializedRemoteInvocationInfo 
#>
#endregion A2.1.4

#endregion A2.1

#region Exercise A2.2: REMOTE JOBS
<#
Objectives  

In this exercise, you will explore creating and managing Windows PowerShell jobs on remote machines. 
Execute remote background jobs in three different ways: 

 Start a background job in a remote interactive session. Performs the same as running a local job. 
 Start a background job on one or more remote computers and collect the job output on the local machine. 
 Start a background job on one or more remote computers and leave the job output on the remote machine. 
#>
#region Task A2.2.1: Run a job in a remote interactive session
<#
1. Open the Windows PowerShell ISE and type the following commands into the console pane. 
   a. Start a Remote, interactive session. 
The remote machine’s name will prefix the prompt. 
#>
Enter-PSSession –ComputerName 2012R2-MS 
<# 
[2012R2-MS]: PS C:\> 
   b. Execute a background job in the interactive session 
#>
$myRemoteJob = Start-Job –ScriptBlock {Get-WinEvent –LogName Application – MaxEvents 1000} c. Notice that another command can run. 
Get-ChildItem C:\Windows –Recurse -File 
<#
   d. Get the job 
#>
$myRemoteJob | Get-Job 
<#
   e. Receive the job results 
#>
Receive-Job $myRemoteJob -Keep | Export-Clixml –Path C:\ AppLog.xml f. Exit the interactive session. 
Exit-Pssession 
<#
   g. View job results from the remote machine. 
#>
Import-Clixml –Path \\2012R2-MS\C$\AppLog.xml | Select-Object -Property MachineName, TimeCreated, Message 
#>
#endregion A2.2.1

#region Task A2.2.2: Start remote jobs and return the results
<#
Use the Invoke-Command cmdlet to run a script block on one or more remote machines. 
This requires Windows PowerShell remoting enabled on the remote machines. 
 
1. Invoke a command on remote machines as a job. 
   Create the job object on the local machine, but the command runs on each remote machine, in parallel. 
#>
$Jobs = Invoke-Command –ComputerName  2012R2-DC, 2012R2-MS, WIN8-WS ` –ScriptBlock {Get-WinEvent –LogName System –MaxEvents 1000} -AsJob 
<#
2. Check the job state. Notice that the –IncludeChildJob switch displays four jobs.  
   The first job is an executive and does not run any commands. 
   Instead, use it to manage the child jobs, which execute commands in each remote session. 
#>
$Jobs | Get-Job –IncludeChildJob 
<#
3. Alternatively, just return the child jobs 
#>
$Jobs.ChildJobs 
<#
4. Execute the same command, but specify the local credentials for 2012R2-MS. User: 2012R2-MS\Administrator - Password: PowerShell4 
#>
$Jobs = Invoke-Command -ComputerName 2012R2-DC, 2012R2-MS, WIN8-WS –ScriptBlock {Get-WinEvent –LogName System} -AsJob -Credential 2012R2MS\Administrator 
<#
5. How would you check whether any of the jobs failed and return the reason for the failure?
   Answer: ($jobs | get-job -ChildJobState Failed).JobStateInfo.Reason
#>

#endregion A2.2.2

#region Task A2.2.3: Job throttling
<#
The Invoke-Command Cmdlet provides a ThrottleLimit parameter to control the maximum number of concurrent connections that can be established to run the command. 
This setting defaults to 32 but can be set to the largest Integer data type value. 

1. Open the script C:\PShell\Labs\Lab_4\4.2.3.ps1 in the Windows PowerShell ISE. 
   The first part of the script runs a command on three computers, but uses the ThrottleLimit parameter to limit the number of concurrently executed commands to one.  
#>
$Jobs = Invoke-Command -ComputerName 2012R2-DC, 2012R2-MS, WIN8-WS -ScriptBlock {Get-WinEvent -LogName System -MaxEvents 1000} –AsJob –ThrottleLimit 1 
<#
2. The second part of the script causes a while loop to execute if any job is in the “NotStarted” or “Running” states, then returns the currently running job. 
#>
While ($Jobs.ChildJobs.JobStateInfo.State -contains "NotStarted" ` -or $Jobs.ChildJobs.JobStateInfo.State -contains "Running") 
{     
    $RunningJob = $Jobs.ChildJobs | Where-Object state -eq "Running"     
    Write-Host "$($RunningJob.Location) $($RunningJob.State)" -ForegroundColor Yellow     
    Start-Sleep -Seconds 1 
} # end while

<#
3. Run the script to observe the throttling behavior. Press the ‘play’ button, or hit the f5 key. 

4. How has the command execution behavior changed by introducing the ThrottleLimit parameter. 
   Answer:
#>
#endregion A2.2.3

#region Task A2.2.4: Store remote job results on the remote machine
<#
This scenario creates job objects on the remote computers rather than on the local machine. 
The job runs locally on the remote machine. 
We are really issuing commands to manage a local job, remotely.  
The example also uses the $Using variable scope modifier and Param() statement to pass local variables to the remote jobs. 

1. Create sessions to the remote machines.  
#>
$sessions = New-PSSession –ComputerName 2012R2-DC, 2012R2-MS, WIN8-WS 
<#
2. Define two local variables to hold the Log file name and maximum number of events to return. 
#>
$logName = "Application" 
$maxEvents = 10 
<#
3. To run a command on the remote machines, as a background job, using the Start-Job Cmdlet we must understand variable scope. 
   a. Invoke-Command runs a scriptblock to start a new job on each remote machine. 
   b. The Start-Job scriptblock defines two named parameters with a Param() statement.  
   c. The Get-WinEvent Cmdlet, running on the remote machine, receives its LogName and –MaxEvents parameter values from the Start-Job’s – ArgumentList parameter scope. 
   d. The –ArgumentList parameter receives its values from the local session scope by using the $Using scope modifier. 
#>
Invoke-Command –Session $sessions –ScriptBlock 
{ 
    Start-Job –ScriptBlock { Param($log, $max) Get-WinEvent –LogName $log -MaxEvents $max } -ArgumentList $Using:logName, $Using:maxEvents 
} # end scriptblock 
<#
    NOTE: In this example, it is necessary to use persistent, rather than non-persistent, sessions, because temporary sessions are closed and the job cancelled when returning the job object. 
4. Check the commands have completed. 
#>
Invoke-Command –Session $sessions –ScriptBlock {Get-Job -State Completed}  
<#
5. Receive the job output from the remote machines. 
#>
Invoke-Command –Session $sessions –ScriptBlock {Get-Job | Receive-Job} 
<#
6. Remove the jobs from the remote machines. 
#>
Invoke-Command –Session $sessions –ScriptBlock {Get-Job | Remove-Job} 
#>
#endregion A2.2.3

#endregion A2.2

#region Exercise A2.3: SCHEDULED JOB OVERVIEW
<#
    Objectives  
    
    In this exercise, you will use help topics related to scheduled jobs. 
#>
#region Task A2.3.1: Scheduled Jobs overview and help topics
<#
1. Log on to the WIN8-WS client as DanPark. 
2. Complete the following sentence about scheduled job concepts. 

A _______________ runs commands or a script. 
It can include _________________  that start the job and __________________ 
that set conditions for running the job. 
 
Answer: 
scheduled job, job triggers, job options
 
3. Find the PowerShell module that implements scheduled jobs and write its name below.  
 
   Hint: Get-Module –ListAvailable 

4. Find out how many cmdlets are included in the scheduled job module and circle the correct answer below: 

    a) 11 
    b) 19 
    c) 8 
    d) 16 
    e) 13
    
    Answer:
 
5. Type the following commands. 
#>
Import-Module PSScheduledJob Get-Help about_Scheduled_* | Format-Table -AutoSize 
<#
6. Record the scheduled job help topic names returned: 
   Answer:
#>
#endregion A2.3.1

#endregion A2.3

#region Exercise A2.4: SCHEDULED JOB MANAGEMENT
<#
Objectives  

In this exercise, you will: 
 Create scheduled jobs, triggers and job options 
 Disable and remove scheduled jobs and job triggers
#>
#region Task A2.4.1: Creating scheduled jobs, triggers, and job options
<#
In this task, you will walk through the process of creating, disabling, and deleting scheduled jobs, job triggers, and job options. 
 
1. Log on to the WIN8-WS client as DanPark. 
2. Launch the PowerShell console with elevated privileges. 
3. Create a new job trigger to execute a job at a specific time. 
   For this exercise, we will schedule the job to execute only once, 2 minutes from the time we create the trigger. 
#>
$myTrigger = New-JobTrigger -Once -At (Get-Date).AddMinutes(2)  
<#
4. Register a new scheduled job to run a simple scriptblock that lists all processes. 
   Supply the variable holding the job trigger object as the argument to the -Trigger parameter of the Register-ScheduledJob cmdlet. 
   A unique name for the job is mandatory. 
#>
Register-ScheduledJob -Trigger $myTrigger -ScriptBlock {Get-Process} -Name myTestJob 
<#
5. Create a second job trigger. 
   Assign one or more job triggers to an existing scheduled job object. 
#>
$myTrigger2 = New-JobTrigger –At (Get-Date).AddMinutes(3) –Weekly –DaysOfWeek Monday,Friday 
Add-JobTrigger –Name myTestJob –Trigger $myTrigger2 
<#
6. Use the Get-ScheduledJob cmdlet to review the new scheduled job. 
#>
Get-ScheduledJob | Format-List -Property * 
<#
7. Alter scheduled job behavior by modifying its JobOption property.  
The NewScheduledJobOption cmdlet is a convenient way to list the default settings of a scheduled job’s JobOption property. 
#>
New-ScheduledJobOption   
<#
8. Modify the default job option by using the Get-ScheduledJobOption and Set-ScheduledJobOption cmdlets. 
   Note that the -Name parameter accepts the name of an existing Scheduled Job object. 
#>
Get-ScheduledJobOption -Name myTestJob |  Set-ScheduledJobOption -MultipleInstancePolicy Queue 
<#
9. The Get-ScheduledJobOption cmdlet also displays the changes you have made to the job option object.
#> 
Get-ScheduledJobOption –Name myTestJob | Format-List –Property * 
<#
10. Use the pipeline to display the job trigger associated with the scheduled job. 
#>
Get-ScheduledJob -Name myTestJob | Get-JobTrigger 

#>
#endregion A2.4.1

#region Task A2.4.2: Disabling and removing Scheduled Jobs & Triggers
<#
Now that we have demonstrated how scheduled jobs and job triggers creation occurs, disabling and removing them is straightforward. 

1. Disable the job triggers. 
#>
Get-JobTrigger –Name myTestJob | Disable-JobTrigger 
<#
2. Confirm the triggers are disabled. 
The Enabled property should be $false. 
#>
Get-JobTrigger –Name myTestJob 
<#
3. Triggers are re-enabled using the Enable-JobTrigger cmdlet 
#>
Get-JobTrigger –Name myTestJob | Enable-JobTrigger 
<#
4. Write the command below you could use to delete the myTestJob job triggers. 
   Use the command to delete the job triggers from the myTestJob scheduled job. 
   Answer: 
#>
   Remove-JobTrigger -Name myTestJob
<#
5. Enable or disable a scheduled job. 
#>
Disable-ScheduledJob -Name myTestJob 
<#
6. Confirm the job was disabled. 
#>
Get-ScheduledJob   
<#
7. Re-enable the scheduled job. 
#>
Enable-ScheduledJob –Name myTestJob 
<#
8. Permanently delete a scheduled job. 
   Write the command below. 
   Answer: 
#>   
   Get-PSScheduledJob -Name myTestJob | Remove-PSScheduledJob
<#
   Execute this command to remove the ‘myTestJob’ scheduled job, created earlier in this exercise. 
#>
#endregion A2.4.2

#endregion A2.4

#region Exercise A2.5: SCHEDULED JOB PERMISSIONS

<#
Objectives  

In this exercise, you will run scheduled jobs using an elevated access token. 
#>

#region Task A2.5.1: Run scheduled jobs with an elevated access token
<#
Create a new scheduled job. 
By default, the configuration runs using the unprivileged token of the account that authored it. 
Specify the elevated token during scheduled job creation or after the job creation.  
In this scenario, stop the W32Time service using a scheduled job.  

1. Log onto the WIN8-WS virtual machine using the DanPark account. 

2. Launch an elevated PowerShell session (Use Contoso\Administrator credentials). 

3. Use the Register-ScheduledJob cmdlet to create a new scheduled job. 
The job is required to stop the W32Time service once, a few minutes in the future (for testing purposes). 
#>
$InThreeMinutes = (Get-Date).AddMinutes(3) 
$myTrigger3 = New-JobTrigger –At $InThreeMinutes -Once 
Register-ScheduledJob -Name myTestJob2 -Trigger $myTrigger3 -ScriptBlock {Stop-Service W32Time} 
<#
4. Once the time specified in the trigger has passed, use the Get-Job and Receive-job cmdlets to investigate the job instance and retrieve the result.  
The while loop continues to run Get-Job and check the job’s ‘state’ property until the job completes.  
The subsequent line pipes the completed job output to Receive-Job. 
#>
while ((Get-Job).state -ne "Completed") 
{
    "Job not completed"
    Start-Sleep –s 5
} # end while 
Get-Job | Receive-Job 
<#
5. Was the job successful? 
   Answer: 

   Write the commands used to investigate the scheduled job below, along with any errors encountered. 
   Answer: Get-Job | Recieve-Job

   Should a successful Stop-Service cmdlets generate output? 
   Answer:

6. Open a non-elevated PowerShell console and try to stop the W32Time service and record the result below. 
#>
Stop-Service -Name W32Time
<# 
7. Return to your elevated console and remove the ‘myTestJob2’ scheduled job and restart the W32Time service. 
#>
Unregister-ScheduledJob –Name myTestJob2 Start-Service w32Time 
<#
Rights needed to stop a service with a non-elevated access token, even with the Domain Administrator account, are not present. 
Investigate how to enable the elevated access token for a scheduled job.  

8. Write the revised Register-ScheduledJob command below and schedule the job to run one minute after creation.  Name the job myTestJob3. 
   Answer: 

Get-Service w32time | Stop-Service Stop-Service : Service 'Windows Time (w32time)' cannot be stopped due to the following error: Cannot open w32time service on computer '.'. 
#>
Register-ScheduledJob -name myTestJob2  -Trigger @{At=(get-date).AddMinutes(1); Frequency="Once"}  -ScriptBlock {Stop-Service W32Time} -Credential Contoso\Administrator 
<#
   Hint:  See help Register-ScheduledJob -Full and look at the ScheduledJobOption parameter. 
9. Verify the job ran successfully and that the W32Time service stopped.  
   Note that you may need to wait a few minutes for the job to run. 
#>
Get-Job –Name myTestJob3 | Format-List –Property * Get-Service –Name W32Time 
<#
10. Start the W32Time service and unregister the scheduled job. 
#>
Start-Service w32time Get-ScheduledJob | Unregister-ScheduledJob 
<#
11. Using the ‘Domain Users and Computers’ application on WIN8-WS, add a user to the domain – Contoso\KimAkers. 

12. Like many other PowerShell cmdlets, scheduled jobs can also run under alternate credentials. 
Using the Get-Credential cmdlet creates a new credential object for a user account other than the one you are currently using (all lab passwords are PowerShell4). 
#>
$cred = Get-Credential Contoso\KimAkers 
<#
13. Create a new scheduled job of your own design and use the credential object as an argument to the Register-ScheduledJob cmdlet -Credential parameter. 
#>
Register-ScheduledJob –Name myTestJob4 –Scriptblock {Get-WinEvent –Logname Application –MaxEvents 10} –Trigger @{At=$((Get-Date).AddMinutes(2));Frequency="Once"} –Credential $cred 
<#
14. Verify the new scheduled job is set to run under the specified account using either PowerShell or the Task Scheduler Microsoft Management Console (MMC). 
#>
(Get-ScheduledJob myTestJob4).Credential 
<#
Note:  You must launch the Task Scheduler graphical console as an Administrator in order to see scheduled jobs from all users. 
15. Did the job run successfully? 
    Answer:

16. What is required to allow ‘KimAkers’ to successfully run a scheduled task? 
    Answer: Assign the Log on as a Batch Job Privilidge (SeBatchLogonRight) to KimAkers Account using Group Policy. 

    Hint: User Rights - http://technet.microsoft.com/en-us/library/bb457125.aspx 
#>
#endregion A2.5

#endregion A2.6

#region Exercise A2.6: SCHEDULED JOB OUTPUT

<#
Objectives  

In this exercise, you will:  Get output from a scheduled job  Work with job persistence
#>

#region Task A2.6.1: Receiving job output
<#
When a PowerShell scheduled job runs, we refer to it as a scheduled job instance, which is a regular PowerShell background job object. 
These are managed using the *-Job cmdlets. 

1. Create a script that lists all processes where the CPU property is greater than five. 
   Sort them by CPU in descending order, and convert them to HTML format.  
   Include only the Name and CPU properties of each process object in the final HTML markup. 
   
2. Create a Scheduled job, called myTestJob5, to run daily at 2am and execute the script created in the previous step. 

3. Wait until 2am for the script to run.  
   Fortunately, this is not necessary!  
   Use the Start-Job cmdlet to start any scheduled job immediately.  
   Start the new job you just created, making sure the Start-Job cmdlet’s -DefinitionName parameter has the correct job name argument. 
#>
Start-Job –DefinitionName myTestJob5 
<#
4. View the job state with the Get-Job cmdlet.  
#>
Get-Job –Name myTestJob5 
<#
NOTE: The *-Job cmdlets are only able to retrieve scheduled job instances when the PSScheduledJobs module is imported into the current session. 
5. Receiving the Scheduled job output is also the same as a regular PowerShell job, using the Receive-Job cmdlet.  
#>
Receive-Job –Name myTestJob5 -Keep 
<#
To stop the job output deletion after display, the Receive-Job cmdlets’s -Keep parameter is required.   

6. Run the job manually several more times at varying intervals. 

7. Use the Get-Job and Get-Member cmdlets to find the property names that contain the start time and end time of the job objects. 
   Write the two property names below. 
   Answer: 
 
8. Compose a pipeline command to display the job’s name, start time, end time, and command properties. Sorted the results in descending order by the start time. 
#>
Get-Job | Sort-Object PSBeginTime Descending | Format-Table Name, PSBeginTime, PSEndTime, Command -AutoSize 

#endregion A2.6.1

#region Task A2.6.2: Scheduled job Persistence
<#
Windows PowerShell scheduled jobs are both Windows PowerShell jobs and Task Scheduler tasks.  
Each scheduled job is registered. Examine the Task Scheduler and the XML saved on disk. 
Although all of the information saved to disk is more easily viewed using the *ScheduledJob and *-Job cmdlets, it is useful to know where it is stored on disk. 
Review all saved scheduled job definitions and their instance output data at the following path: C:\Users\username\AppData\Local\Microsoft\Windows\PowerShell\ScheduledJobs 

1. List the contents of the path for the current user. 
#>
dir $env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ScheduledJobs 
<#
2. Each folder uses the scheduled job name given upon creation. 
   Open one of the scheduled job folders and write the file and folder objects found below. 
   Answer:
 
   Note:  Do not edit the XML files. If any XML file contains invalid XML, Windows PowerShell deletes the scheduled job and its execution history, including job results. 

3. The Output folder contains a date/time stamp named folder for each run of the scheduled job. 
   Using the Get-Help cmdlet and the scheduled job help files, find the default number of output data folders retained by the system before the folders are deleted.
Commented [A12]: Get-Job | Sort-Object PSBeginTime Descending | Format-Table Name, PSBeginTime, PSEndTime, Command -AutoSize 
Commented [A13]: Output ScheduledJobDefinition.xml 

   Hint:  See the section MANAGE EXECUTION HISTORY in help about_Scheduled_Jobs_Advanced 
4. Choose the correct number of retained job run output folders from the list:  
a) 10 
b) 99 
c) 16 
d) 32 
e) 7 

Answer:

5. What is the name of the property that stores this number for each scheduled job? 
   Answer:
 
6. How can you modify the default number of output data folders retained by the system for job output? Write the command to do this below. 
   Answer:
#>
Get-ScheduledJob ProcessJob | Set-ScheduledJob MaxResultCount 15
<#
7. How would you clear the job output history for a Scheduled job? Write the command below. 
   Answer: 
#>   
Get-ScheduledJob ProcessJob | SetScheduledJob -ClearExecutionHistory 
<#
8. Open the Task Scheduler management tool.  
   Click Start, type task, right click Task Scheduler, choose ‘Run as Administrator’, and type the administrator credentials. 
   Navigate to the following path in the interface:  Task Scheduler (local) > Task Scheduler Library > Microsoft > Windows > PowerShell > ScheduledJobs 
   The jobs you created using PowerShell should also appear here in the Task Scheduler management interface.
#>
#endregion A2.6.2

#endregion A2.6


