# Do not run the whole script at once
break

# May need to run in a fresh ISE host session if you get an error "ResetRunspaceState".

# Workflow -- long running capability and reliability
#  "Workflows are typically long-running scripts that are designed to survive
#  component or network errors and reboots."
#  "Reliably executing long-running tasks across multiple computers, devices or IT processes"
#  long-running, repeatable, frequent, parallelizable, interruptible, suspendable, and/or restartable
#  -Parallel processes
#  -Configurable retries
#  -Progress bar
# Requires WinRM 3.0 (OOB or installed on 7/2008R2)
# http://technet.microsoft.com/en-us/library/jj134242   Introducing Windows PowerShell Workflow
# http://technet.microsoft.com/en-us/library/jj149010   about_Workflows
# http://blogs.msdn.com/b/powershell/archive/2012/03/17/when-windows-powershell-met-workflow.aspx
# http://blogs.msdn.com/b/powershell/archive/2012/06/15/high-level-architecture-of-windows-powershell-workflow-part-1.aspx
# http://blogs.msdn.com/b/powershell/archive/2012/06/19/high-level-architecture-of-windows-powershell-workflow-part-2.aspx
# http://blogs.technet.com/b/windowsserver/archive/2012/05/30/windows-server-2012-powershell-3-0-and-devops-part-2.aspx


# A basic WMI call to the local machine
# Using alias and positional first paramter
Get-WmiObject Win32_ComputerSystem


# Workflows require all parameter names
workflow TestWWF {
    Get-WmiObject -Class Win32_ComputerSystem
}

Get-Command

# Call it from a workflow locally
TestWWF

# Call it from a workflow against a remote machine
# Note that the code inside the workflow does not use the computername parameter.
$cred = Get-Credential Contoso\Administrator
TestWWF -PSComputerName 2012R2-MS -PSCredential $cred


# Against multiple remote machines
TestWWF -PSComputerName 2012R2-MS,2012R2-DC -PSCredential $cred

# Workflows can look like cmdlets
# (Run each line separately.)
Get-Command TestWWF
Get-Help TestWWF

TestWWF



# Basic Workflow

workflow HelloWorkflow
{
    Write-Output -InputObject "Hello From Workflow"
}

HelloWorkflow

Get-Command HelloWorkflow



# Checkpoint, Suspend and Resume Demo

workflow LongWorkflow {
    Write-Output -InputObject "Loading some information..."
    Suspend-Workflow
    Write-Output -InputObject "Performing some action..."
    Start-Sleep -Seconds 15
    Checkpoint-Workflow
    Write-Output -InputObject "Cleaning up..."
}

LongWorkflow -AsJob -JobName LongWF
Get-Job LongWF
Receive-Job LongWF -Keep
Resume-Job LongWF
Get-Job LongWF
Suspend-Job LongWF
Get-Job LongWF
Resume-Job LongWF
Get-Job LongWF
Receive-Job LongWF
Get-Job LongWF | Remove-Job

