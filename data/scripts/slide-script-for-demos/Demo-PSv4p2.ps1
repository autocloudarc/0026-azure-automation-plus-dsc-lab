#requires -version 4.0
#requires -RunAsAdministrator
<#
.SYNOPSIS
   Content of WorkshopPLUS - Windows PowerShell v4.0 for the IT Administrator - Part 2 in script format.
   The content in this script facilitates demonstrations for delivering advanced topics for features of PowerShell v4.0.

.DESCRIPTION
   This master script contains a collection functions or snippets that shows how certain features of PowerShell 4.0 can be used for a variety of scenarios.
   This was copied from the slides for the Part 2 workshop, soley to reinforce the content directly from a powershell script and to supplement the demo scripts we already use for each module.
   You can include this script as an ISO file for the LOD lab machines during delivery to provide a more interactive experience rather than copy / pasting from the slides when doing one off demos directly from the slide content.
   This way, you will be able to execute certain code blocks interactively and directly from this file when it is mounted to the DVD drive in the lab machines.
.NOTES
   LIMITATIONS : Script samples are based on WMF 4.0 DSC (not WMF 5.0) resources
   AUTHOR(S)   : Preston K. Parsard (copied from the slides for: WorkshopPLUS - Windows PowerShell v4.0 for the IT Administrator - Part 2.)
   EDITOR(S)   : Preston K. Parsard
   REFERENCES  : https://github.com/PowerShell/PowerShell
   KEYWORDS	   : PowerShell
   DISCLAIMER  : THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
               : INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, 
               : royalty-free right to use and modify the Sample Code and to reproduce and distribute the Sample Code, provided that You agree: (i) to not use Our name, 
               : logo, or trademarks to market Your software product in which the Sample Code is embedded; 
               : (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, 
               : and defend Us and Our suppliers from and against any claims or lawsuits, including attorneysâ€™ fees, 
               : that arise or result from the use or distribution of the Sample Code.
   FEEDBACK    : Use the PowerShell Workshop Trainers\v4.0 Part 2 Workshop team site & channel, conversations tab for any questions or to provide feedback.
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   IT Administrators and Developers
.FUNCTIONALITY
   Demos which coincides with slides
#>

<# TO-DOs
TASK-ITEM.0001: #Requires -Version ..
TASK-ITEM.0002: Show Split-Path examples
#>

<#
 PowerShell News:
 1. https://blogs.msdn.microsoft.com/powershell/2016/08/18/powershell-on-linux-and-open-source-2/
#>

#***************************************************************************************************************************************************************************
# REVISION/CHANGE RECORD	
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DATE         VERSION    NAME			     E-MAIL				    CHANGE
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 28 NOV 2018  00.00.0001 Preston K. Parsard prestopa@microsoft.com Initial release

# INTRODUCTIONS
<#
0. About Me


1. Name:
2. Company Affiliation:
3. Title/Fucntion/AOR
4. Product Experience
5. Expectations for this course
SCHEDULE
Start: 08:00 
Break: As needed
Lunch: 12:00
Break: As needed
End:   17:00 

AGENDA:
=======
DAY01 
Module01.ReviewOfPart1Concepts
Module02.Remoting
Module03.AdvancedFunctions1
DAY02
Module04.AdvancedFunctions2
Module05.RegularExpressions(Regex)
Module06.ErrorHandling
DAY03
Module07.Debugging
Module08.IntroductionToDesiredStateConfiguration(DSC)
Module09.IntroductionToWorkflow

LAB ENVIRONMENT:
https://www.Premier-Education-Services.com
2012R2-DC: Windows Server 2012 R2 Core; 10.0.1.200
2012R2-MS: Domain Member Server; 10.0.1.210
WIN8-WS: Domain Member Workstation; 10.0.1.220
Domain FQDN:         contoso.com
Domain NetBIOS Name: contoso
Admin Account Username: Administrator
Password:               PowerShell4
User Account Username:  DanPark
Password:               PowerShell4
#>

#region DAY-01
#region Module1-ReviewOfPart1Concepts
<#

1. Introduction
1a. Taskbased command-line shell
1b. Scripting language built on .NET framework
1c. Helps IT pros and devlelopers control and automate administration of OS and applicaitons
1d. Has both interactive console & and Integrated Scripting Environment (ISE)

2. Versions (WMF)
2a. Grouping of several management related tools
2b. PowerShell, BITS and the WinRM service

3. Commands
Every cmdlet has common parameters PowerShell provides.
Example: -Outvariable, -ErrorAction, -Verbose
Risk Mitigation Parameters: -WhatIf & -Confirm switch parameters are present on many cmdlets. Risk mitigation parameters are only for certain cmdlets.
Get-Command shows you external & PowerShell commands
Get-Help assists with cmdlets, concepts, examples, etc.
Aliases save time typing & help transition
Scriptblocks are statements in braces
#>
{Get-Process}
# Functions are reusable, named scriptblocks
#>
function GetEveryProcess
{
    Get-Process
} #end funciton

# 3b. Help
# 3c. ScriptBlocks: Statements in braces

# 4. Remoting
# Allows running commands against remote machine(s)
# Types of remoting:
# • Temporary
Invoke-Command -ComputerName 2012R2-DC –Credential contoso\administrator -ScriptBlock {Get-Culture}
# • Persistent
New-PSSession -ComputerName 2012R2-DC –OutVariable ps
Invoke-Command –Session $ps -ScriptBlock {Get-Culture}
# • Interactive:
Enter-PSSession -ComputerName 2012R2-DC

# 5. Pipeline
# The pipeline is a chain of cmdlets that passes objects
# Initial pipeline input provided by:
# • Get-* & Import-* cmdlets, text files & external commands
# Pipeline objects are manipulated using:
# • Sort-*, Select-*, Group-*, Measure-Object, cmdlets & more
# Pipeline output via:
# • Format-* cmdlets (should always be last)
# • Export-* cmdlets
# • Out-* cmdlets
# • Variables
# $_ or $PSItem refer to the current pipeline object
Get-ChildItem | Where-Object { $psitem.Length –gt 1MB }
# Alternatively, create a custom pipeline variable using –PipelineVariable
Get-Process -PipelineVariable CurrentProcess | Where-Object {$CurrentProcess.ws -gt 100MB}
# Where-Object has a simple syntax (new to v3)
Get-ChildItem | Where-Object { $_.Length –gt 1MB }
Get-ChildItem | Where-Object Length -gt 1MB
# Individual parameters can take pipeline input by value/property name

# 6. Scripts
# A collection of statements or expressions within a text file with a .ps1 extension
# Scripts can be run in either the Windows PowerShell console, ISE or launched externally from cmd.exe
# The Param() statement enables the script to accept input parameters
# Execution Policy defines permissions for running scripts
# The default execution policy restricts Windows PowerShell from running any scripts
# • Restricted
# • Unrestricted
# • AllSigned
# • RemoteSigned
# • Bypass
# Policy can be applied at five separate scopes:
# • GPO (User or Computer), Process, Registry (current user or all users)
# Microsoft Confidential
# Scripts (Continued)
# Comments are extra annotation added purely for readability of script:
# single-line comment

<#
multi-line
comment

# Windows PowerShell has some special comments:
# • #Requires ensures a script has what it needs to run
#Requires -Version 4.0 -RunAsAdministrator
# • Regions make code sections collapsible
#region
#endregion
# • Comment-based help keywords can be placed in functions/scripts for cmdlet like help
# The Windows PowerShell ISE includes features such as:
# • IntelliSense, AutoSave, Brace Matching, Collapsible code, Rich copy, etc.

6a. ExecutionPolicy
6a1. Scope
#>

<#
7. HelpSystem
In the ISE, highlight or click on a cmdlet/about_ topic, then press F1 for a help window
PS v3.0+ doesn’t ship help content. It must be updated.
Modules often ship with help, but can also be updated
Updating help can be done with or without internet access:
#>
Update-Help
# Save-Help –DestinationPath \\Server\Share
# Update-Help –SourcePath \\Server\Share -SourcePath parameter can be pre-defined in a Group Policy Object (GPO)

Get-Help
# F1
Update-Help
Save-Help 

<#
8. Objects
Everything in Windows PowerShell is an object
Objects consist of properties & methods (members), defined in a type
An object is an instance of a type
The Get-Member cmdlet lists the type members of an object (properties and
methods)
Dot Notation is used to access an object’s members
8a. Types
8b. Properties
8c. Methods

9. Operators
9a. Comparison
9b. Logical
9c. Range
9d. NumericMultipliers
9e. Arithmetic
9f. Assignment
9g. Bitwise
9h. Unary
9i. Binary
9j. Format

Windows PowerShell provides operators for comparison and evaluation.
• Comparison (-eq, -ne, -contains,-like, -match, etc.) & case sensitive variants
• Logical (-and, -or, -not, -xor)
Number or Character ranges (1..5, a-z)
Numeric Multipliers (KB, MB, GB, TB, PB)
Arithmetic (+ , - , / ,* ,%)
Assignment (=, +=, -=, *=, /=, ++, --)
Bitwise
-bAnd, -bOr, -bNot, -bXor, -shl, -shr
Binary or Unary forms:
#>
"Hello, World" –split ","
–split "Hello World"
# Binary form only:
"Hello, World" –split ","
"Linux" –replace "Linux","Windows"
# Format Operator (-f)
'{0:d4}' -f 4

<#
10. Providers
10a. *-Item
10b. *-ItemProperty
10c. *-Content
10d. *-Path
10e. *-Location
10f. $<drive name>:<item name>, i.e. $env:COMPUTERNAME

A common interface to different data stores which is exposed as a file system
hierarchy
Drives allow providers to be accessed using classic naming C:, Cert:, Alias:
Get-PSProvider to list providers
Items can be manipulated using consistent cmdlets:
• *-Item, *-ItemProperty, *-Content, *-Path, *-Location, cmdlets
$<drive name>:<item name> is a quick way to access PSDrive items
• $env:COMPUTERNAME

11. Variables and data types
11a. Built-in
11b. User defined
11c. Variable Sub-Expression $(...)
11d. Static members (methods & properties). Can be used without creating an instance of a type
11e. Strongly typing variables enforces its data type
11f. Type Operators
Variables reference objects
Two categories of variable:
• Built-in Variables
#>
$Error
$HOME
$host
# • User defined Variables
$process = Get-Process
Cmdlets that manage variables
Get-Command -Noun variable
# "Double quotes" define an expandable string, ‘Single quotes’ define a literal string
# Variable sub-expressions $(…) access an object’s property within strings

$Number = 98052
"Expandable String $Number" 
# Expandable String 98052
'Literal String $Number' 
# Literal String $Number
$b = Get-Service -Name BITS
"Service: $b.name" 
# Service:
System.ServiceProcess.ServiceController.name
"Service:
$($b.name)"
# Service: BITS
# Static members (methods & properties)
# • Can be used without creating an instance of a type
# Strongly typing a variable enforces its data type
[math] | Get-Member –Static
[math]::PI
[string]::Concat("abc","def")
[int]$var1 = 124
$var1 = "Fred"
<#
Cannot convert value "Fred" to type "System.Int32".
Error: "Input string was not in a correct format."
Type Operators:
• -is, -isnot : return True or False.
• -as : converts datatypes
The backtick, or escape character, ( ` ) is used for:
• Special characters
• Line continuation
• Literal characters in expandable strings
--% stops PowerShell from attempting to interpret input
30
"PSv4" -is [string]
"09/09/2014" -as [datetime]
#>

<#
12. Arrays
An array is a collection of objects (0, 1, or more)
Are created by:
• Assigning multiple values to a variable
• Using @()
• Cmdlets that return multiple values
Store objects starting at index 0: $array[0]
Return array size: $array.Count
Array concatenation: $array += 99
Sorting
• sort pipeline output
#>
$array = @()
$array = 2, 5, 6, 8, 10, 1, 0
$array | Sort-Object –Descending
# • sort the array permanently
[array]::Sort($array)
# Retrieving members (properties & methods)
Get-Member -InputObject $array #returns the array object’s members
$array | Get-Member #returns the members of elements within the array

<#
12a. Creating 
12a1. Assigning multiple values
12a2. Using @()
12a3. Cmdlets that return multiple values
#>
$array[0]
$array.count
$array += 99
<#
12a7. Sorting
12a8. Array vs. member types
#>
#endregion Module1-ReviewOfPart1Concepts

#region Module2-Remoting
#region Section1: ReviewOfRemotingBasics
#region l1
 # Lesson1: WhatIsRemoting?
 # Run commands on one or more remote computers 
 # Utilize a *TEMPORARY* or a *PERSISTENT* connection, referred to as a session 
 # A session connects to a runspace on the remote machine 
 # A runspace is an instance of the PowerShell automation engine 
 # Remote runspace capabilities can be constrained 
 # Introduced in Windows PowerShell 2.0 and then enhanced in later version
 # *Various Powershell Remote Administration Techniques*
 # Requirements
 #  Local & Remote computers: >= PS2.0
 #  PS Rmoting enabled on target
 #  Initiating user must be a member of the local administrators group on the remote computer
 # Enabling Remoting using a Cmdlet (first, lauch PowerShell w/ "Run as Administrator", then type:
   Enable-PSRemoting
 # For greater scale and easier administration, use a GPO
 # 1. WinRM Service Automatic Startup
 # 2. Optional Windows Firewall Inbound rule
 # 3. Allow remote server management (create listeners) 
<#
 Windows Remoting Defaults
    # • Remoting is enabled on all 2012+ Server editions – Standard, Datacenter & Core 
    # • Windows Remote Management (WinRM) Service running 
    # • WS-Management (WSMan) protocol has an HTTP listener configured 
    # • Inbound firewall rule for port 5985 is enabled (WsMan default listener port)
    # • Remoting is disabled on all client editions (WinXP – 8.1) 
    # • Windows Remote Management (WinRM) Service disabled & stopped 
    # • WS-Management (WSMan) protocol has no listener configured 
    # • Inbound firewall rule for port 5985 is disabled
    # • Cross-version connection is possible (v2.0, v3.0, v4.0+)
#>
# Example: Interactive Session
Enter-PSSession -ComputerName 2012R2-DC
# [2012R2-DC] PS C:\>
# [2012R2-DC] PS C:\> hostname
# [2012R2-DC] PS C:\> Exit-PSSession
# PS C:\>

# Example: Temporary Session 
Invoke-Command -ComputerName 2012R2-DC –Credential contoso\administrator -ScriptBlock {Get-Culture}
# LCID     Name   DisplayName PSComputerName 
# ----     ----   ----------- -------------
# 3081     en-AU  English (Australia)  2012R2-DC

# Example: Persistent Session 
# Step 1: Create a persistent session
$s = New-PSSession -ComputerName 2012R2-DC -Credential Contoso\Administrator
# Id Name     ComputerName State  ConfigurationName Availability 
# -- ----     ------------ -----  ----------------- -----------
# 1  Session1 2012R2-DC    Opened Microsoft.PowerShell Available
# Step 2: Use the session
Invoke-Command –Session $s -ScriptBlock {Get-Culture}
# LCID     Name   DisplayName PSComputerName 
# ----     ----   ----------- -------------
# 3081     en-AU  English (Australia)  2012R2-DC
#endregion l1
#endregion Section1: ReviewOfRemotingBasics
#region Section2: AdvancedRemotingConcepts
#region l1
 # Lesson1: ImplicitRemoting
 <#
    1. Feels like a local session command but runs remotely.
    2. Use Import-PSSession or Import-Module -PSSession
    3. Several products like Exchange 2010+ use implicit remoting 
    4. Use of Invoke-Command is implied, not explicit
    5. Local functions "wrap" remote invoke of command
 #>
 # Example: Import-PSSession
 # Create Persistent Session
 $Session = New-PSSession -ComputerName 2012R2-MS 
 
 #Import Remote Command and Automatically Create Local Function Wrapper
 Import-PSSession -Session $session ` -CommandName Get-NetIPConfiguration -Prefix RemoteMS
 # ModuleType Version    Name                                ExportedCommands 
 # ---------- -------    -------------------
 # Script     1.0        tmp_way5tpwk.hxm                    Get-RemoteMSNetIPConfiguration

 # Verify Imported Command
 Get-Command get*IPConfig* 
 # CommandType  Name                           ModuleName 
 # -----------  ----                           ---------
 # Function     Get-NetIPConfiguration         NetTCPIP 
 # Function     Get-RemoteMSNetIPConfiguration tmp_way5tpwk.hxm

# Example: Import-Module -PSSession
# Create Persistent Session
$Session = New-PSSession -ComputerName 2012R2-MS 
# Import Remote Module and Automatically Create Local Function Wrapper
Import-Module NetTCPIP -PSSession $Session -Prefix RemoteMS
# Verify Imported Module
Get-Module NetTCPIP
# ModuleType Version Name      ExportedCommands 
# ---------- ------- ----      ---------------
# Script     1.0     NetTCPIP  {Find-RemoteMSNetRoute, Get-RemoteMSNetCompartment, Get-R...
#endregion l1
#region l2
 # Lesson2: SerializedObjects
 # • During remoting, objects are transmitted from a remote to a local session 
 # * Similar to using Export-CliXML and Import-CliXML
 # • Serialization and de-serialization process occurs 
 # • Some fidelity is lost. Methods are lost for non-basic types 
 # • Basic Types typically de-serialize fully
 # Remote Type       Style   Object State
 # Enter-PSSession   1-1     Output objects remain on remote system, formatting and Out cmdlets occur remotely
 # Invoke-Command    1-1,1-8 Output objects transmitted to local session, formatting and out cmdlets occur locally
 # Implicit Remoting 1-1     Output objects transmitted to local session, formatting and out cmdlets occur locally   
 # Example: Methods removed and de-serialized type name
 Invoke-Command -ComputerName 2012r2-MS -ScriptBlock {Get-Service b*} | Get-Member
#endregion l2
#region l3
 # Lesson3: PSComputerName
 # PSComputerName property
 # • During de-serialization, the PSComputerName property is added to all objects 
 # • Identifies object source during One-to-Many remoting
 Invoke-Command -ComputerName 2012r2-MS -ScriptBlock {Get-Service b*}
#endregion l3
#region l4
 # Lesson4: RemotingOnPublicNetworks
 # Remoting on public networks is a potential security risk 
 # • PowerShell v2.0: Enable-PSRemoting fails if host is connected to a public network 
 # • PowerShell v3.0+ on Client OS: use the –SkipNetworkProfileCheck parameter 
 # • PowerShell v3.0+ on Server OS: Enable-PSRemoting sets private and domain networks unrestricted, but public networks are limited to the local subnet
 # To remove the local subnet restriction on Server OS:
 # Set-NetFirewallRule –Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
#endregion l4
#region l5
 # Lesson5: DisconnectedSessions
 # Remote PowerShell sessions can be re-connected, if interrupted
 # A timeout setting controls time-to-live of a disconnected session
 # This feature requires PowerShell v3.0+ on both side
 # 1. Invoke-Command -InDisconnectedSession
 # 2. Get-PSSession -ComputerName
 # 3. Connect-PSSession
 # 4. Receive-PSSession
 # Managing Disconnected Sessions
 # Invoke-Command –InDisconnectedSession: Creates, then disconnects from a new session 
 # Get-PSSession: Lists local and remote sessions 
 # Connect-PSSession: Reconnects to a disconnected session 
 # Receive-PSSession: Reconnects and receives output 
 # Disconnect-PSSession: Disconnects a session
 # NOTE: Another user can connect to PSSessions, but only if they can supply the credentials that were used to create the initial session
 Invoke-Command –Computername RemotePC01 –Scriptblock {dir c:\} –InDisconnectedSession
 Disable-NetAdapter -Name "<AdapterName>" -WhatIf
 Enable-NetAdapter -Name "<AdapterName>" -WhatIf
 $s = Get-PSSession –Computername RemotePC01 Connect-PSSession –Session $s 
 Receive-PSSession –Session $s #Receive will connect as well 
 Disconnect-PSSession –Session $s #Only when foreground not busy
 # Session state: Relationship between local session and remote runspace [Opened: Runspace connected, Disconnected: Local session not connected to runspace, Broken: Connection to runspace lost]
 # Session availability: Ability of runspace to accept commands [Available: Runspace is ready, None: Runspace not available (not connected), Busy: Runspace is busy]
 # Example: View Session State and Availability
 New-PSSession -ComputerName 2012r2-ms
 Disconnect-PSSession -Session 4
 # Example: Session State and Availability
 # State Opened: Connected remote runspace
 # Avilability: None: available for re-connection, Busy: Performing work and has been disconnected
<#
 Robust Sessions
    • PowerShell 2.0: Network issues may cause a remote PSSession to enter a "Broken" or "Closed" state 
    • PowerShell 3.0+: Remote Sessions remain in a "Connected" state for up to 4 minutes 
    • Progress bar indicates reconnection attempts 
    • Local session becomes "Broken" after 4 minutes 
    • Remote session becomes available for connection from anywhere, as the original user When PowerShell is exited with an "Open" Session: 
    • If commands are running in the PSSession, it becomes "disconnected" 
    • If the PSSession is idle, it is terminated (similar to Remove-PSSession)
#>
# E#xample: Connecion Interruption
Invoke-Command -ComputerName 2012r2-ms -ScriptBlock { 1..60 | ForEach-Object { Write-Host "." -NoNewline; Sleep -Seconds 1 }}
Disable-NetAdapter -Name "<AdapterName>"
Enable-NetAdapter -Name "<AdapterName>"
# Disconnected Session Timeout 
# Disconnected sessions are maintained until removed or the Idle Timeout expires 
# • IdleTimeout property of the New-PSSessionOption cmdlet
# • Default is 2 hours
# -SessionOption parameter controls the timeout value for: 
# • Invoke-Command 
# • New-PSSession 
# • Disconnect-PSSession
# New-PSSessionOption cmdlet creates an object to pass to –SessionOption parameter 
# • Change the timeout using Disconnect-PSSession –IdleTimeoutSe
#endregion l5
#region l6
 # Lesson6: RemotingVariables
 # $Using variable scope prefix
 # PowerShell 2.0 • Invoke-Command -Argumentlist parameter passes local variables to script blocks 
 # • Script block required an embedded Param() statement 
 # • Invoke-Command -ArgumentList arguments are bound by position
 # PowerShell 3.0+ 
 # • Implements a new variable scope prefix 
 # • $Using:<local variable name> 
 # • No Param() statement or -ArgumentList parameter require
 # Example: $Using variable prefix
 $eventLog = "Application" 
 Invoke-Command -ComputerName 2012MS -ScriptBlock { Get-WinEvent -LogName $using:eventlog}
#endregion l6
#region l7
 # Lesson7: Modules
 # Remote Module Discovery and Import
 # • Get-Module can list modules on remote machines 
 # • Import-Module can load modules from remote machines (Implicit Remoting) 
 # • Optional noun prefix on imported commands 
 # • PSSession or CIMSession (only for CIM Modules)
 # List remote modules over a PSSession 
 $ps = New-PSSession –ComputerName 2012DC 
 Get-Module –PSSession $ps -ListAvailable
 # Import remote modules over a PSSession 
 Import-Module –PSSession $ps –Name ActiveDirectory –Prefix REMOTE 
 Get-Module -Name ActiveDirectory 
 Get-REMOTEADUser user01
 # Create persistent session
 $session = New-PSSession -ComputerName 2012r2-ms
 # List modules on remote system using PSSession
 Get-Module -ListAvailable -PSSession $session
 # Import Module (Implicit Remoting)
 Import-Module -Name Storage -PSSession -Prefix MS
 Get-MSDisk 
#endregion l7
#endregion Section2: AdvancedRemotingConcepts
#region Section3: Security
#region l1
 # Lesson1: Constrained Session Configurations
 # Remoting Endpoints
 # Remoting clients target an "Endpoint" on the remoting server
 # The remoting endpoint is configurable
 # Use the *-PSSessionConfiguration cmdlets to manage endpoints
 # Endpoint capabilities can be limited 
 # • Commands 
 # • Permissions 
 # • Language Security 
 # • RunAs
 # Example: Viewing remoting endpoints
 Get-PSSessionConfiguration
 # Session Configuration Cmdlets
 # Session configuration management cmdlets:
 Set-PSSessionConfiguration –RunAsCredential 
 # • Endpoint can run in the context of another user 
 # • Initial connection requires only a lower privileged, delegated account Multiple remote sessions can run in the same wsmanprovhost.exe process 
# Constrained Session Configuration
# • New-PSSessionConfigurationFile cmdlet creates a new configuration file 
# • Cmdlet parameters control session behavior 
# • Configuration settings are stored in a .pssc file as a hashtable
# 1. Create a new session configuration file
# New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -VisibleCmdlets "Get-Process","Get-EventLog" -LanguageMode ConstrainedLanguage -Path "$home\Documents\Session.pssc 
# 2. Configure endpoint permission
# Set-PSSessionConfiguration -Name myRestrictedConfig -ShowSecurityDescriptorUI
# Overall process
# 1. Create session configuration file: 
New-PSSessionConfigurationFile -Path .\restricted.pssc -SessionType RestrictedRemoteServer
# 2. [Optional] Review/Update configuration file
# 3. Associate configuration file with new remote endpoint: 
Register-PSSessionConfiguration -Path .\restricted.pssc -Name myRestrictedConfig 
# 4. Set account access permissions / RunAsCredential
Set-PSSessionConfiguration -Name myRestrictedConfig -ShowSecurityDescriptorUI -RunAsCredential (Get-Credential)
#endregion l1
#region l2
 # Lesson2: Authentication Options
 # Authentication Mechanisms
 # Authentication Type Description Default Endpoint (server)
 # 1. Basic; username & pw (should use HTTPS) [server] disabled, [client] enabled (SSL required)
 # 2. Negotiate; Windows Integrated Auth, Kerberos (preferred) or NTLM [server] enabled [client] enabled
 # 3. Kerberos; Mutual authentication requiring a domain [server] enabled [client] enabled
 # 4. Client based cert: x.509 certs/PKI [server] disabled, [client] enabled 
 # 5. CredSSP; Security Service Provider that allows credential delegation [server] disabled (GPO option) [client] disabled (GPO option)
 # TrustedHosts
 # List of remote computers that are trusted
 # Computers in a workgroup, or different domain, should be added to allow authentication
 # TrustedHosts are not authenticated
 # Client may send credential information to these computers
 # Example: Replace or Set TrustedHosts
 # Replace or Set New Value
 # Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value WorkGroupPC
 # Get current value 
 # Get-Item -Path WSMan:\localhost\Client\TrustedHosts
 # Get current value 
 $trustedHosts = (Get-Item -Path WSMan:\localhost\Client\TrustedHosts).Value
 # Append to current value 
 $trustedHosts += ",Server01.Domain01.Fabrikam.com" 
 Set-Item -Path WSMan:\localhost\Client\TrustedHosts –Value $trustedhosts
 # Get new value 
 Get-Item -Path WSMan:\localhost\Client\TrustedHosts
 # Example: Alternate Credentials
 Invoke-Command -ComputerName 2012r2-ms -ScriptBlock {hostname} -Credential contoso\administrator
 $Creds = Get-Credential contoso\administrator
 Invoke-Command -ComputerName 2012R2-MS -ScriptBlock {Hostname} -Credential $Creds 2012R2-MS 
 Enter-PSSession -ComputerName 2012R2-DC -Credential $Creds
 # [2012R2-DC]: PS C:\Users\Administrator\Documents> Hostname 2012R2-DC
 # [2012R2-DC]: PS C:\Users\Administrator\Documents> Exit-PSSession 
 # clear-text username and password 
 $Username = 'contoso\administrator' 
 $ClearPassword = 'PowerShell4'
 # Convert clear password in SecureString 
 $SecurePassword = $ClearPassword | ConvertTo-SecureString -AsPlainText -Force
 # Create credential object (same object that Get-Credential outputs) 
 $Cred = New-Object PSCredential -ArgumentList $Username,$SecurePassword
 Invoke-Command -ComputerName 2012R2-MS -ScriptBlock {Hostname} -Credential $Cred 
 #Run this line once manually on computer and user where script will run
 $cred = Get-Credential contoso\administrator
 $EncryptedString = $cred.Password | ConvertFrom-SecureString
 # $EncryptedString 01000000d08c9ddf0115d1118c7a00c04fc297eb0100000071f193d84290394f8...
 #Place the encrypted string in your script #It will only decrypt on machine/user that ran above lines 
 $SecurePassword = $EncryptedPassword | ConvertTo-SecureString
 $EncryptedPassword = "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000071f193d84290394f8"
 $Username = 'contoso\administrator' $Cred = New-Object PSCredential -ArgumentList $Username,$SecurePassword
 Invoke-Command -ComputerName 2012R2-MS -ScriptBlock {Hostname} -Credential $Cred 
 # Example: Alternate authentication
 Invoke-Command -Authentication Basic –Credential contoso\administrator -ComputerName 2012R2-MS -ScriptBlock {Hostname}
 Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value $true
 Invoke-Command -Authentication Basic -Credential contoso\administrator -ComputerName 2012r2-ms -ScriptBlock {hostname}
#endregion l2
#region l3
 # Lesson3: SSL Listener/Endpoint
 # Example: First, identify cert thumbprint
 # Must have a certificate (typical SSL web server cert works) 
 # • Installed in Local Computer/Personal (My) 
 # • Key Usage must include: Server Authentication 
 # • Must have PrivateKey 
 # • Obtain through internal PKI or Public CA

 #Identify possible certificates and get thumbprint value, this can be run remotely $Filter = {$_.hasprivatekey -and $_.EnhancedKeyUsageList.FriendlyName -contains 'Server Authentication'}
 Get-ChildItem Cert:\LocalMachine\My | Where $Filter | Format-List thumbprint,EnhancedKeyUsageList,DNSNameList,Issuer
 # Example: Second, Create Listener (Local or Remote)
 # Example 1: Create new local HTTPS Listener using local certificate 
 $CertThumbprint = '3138F8B8B4A948ADAB752DE7E355408234D59800' 
 New-Item -ItemType Listener -Path WSMan:\LocalHost\Listener -Address * -Transport HTTPS -CertificateThumbPrint $CertThumbprint
 # Example 2: Remotely connect to WSMAN and create new HTTPS Listener on target using target’s certificate 
 $CertThumbprint = '3138F8B8B4A948ADAB752DE7E355408234D59800' 
  Connect-WSMan -ComputerName 2012R2-DC New-Item -ItemType Listener -Path WSMan:\2012r2-dc\Listener -Address * -Transport HTTPS -CertificateThumbPrint $CertThumbprint
 # WSManConfig: Microsoft.WSMan.Management\WSMan::2012r2-dc\Listener
 # Type            Keys                                Name ---- ---- ---
 # Container       {Transport=HTTPS, Address=*}        Listener_1305953032   
 # Example: Second, Create Inbound Firewall Rule (Local or Remote)
 # Local – Copy HTTP Rule to create HTTPS Rule 
 Get-NetFirewallRule -Name WINRM-HTTP-In-TCP | Copy-NetFirewallRule -NewName WINRM-HTTPS-In-TCP
 Get-NetFirewallRule -Name WINRM-HTTPS-In-TCP | Set-NetFirewallRule -LocalPort 5986 -NewDisplayName 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
 # Remote – Same copy technique as above $CimSession = New-CimSession -ComputerName 2012R2-DC 
 Get-NetFirewallRule -Name WINRM-HTTP-In-TCP -CimSession $CimSession | Copy-NetFirewallRule -NewName WINRM-HTTPS-In-TCP
 Get-NetFirewallRule -Name WINRM-HTTPS-In-TCP -CimSession $CimSession | Set-NetFirewallRule -LocalPort 5986 ` -NewDisplayName 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
 # Example: Use SSL Listener/ Endpoint
 Invoke-Command -ComputerName 2012r2-dc.contoso.com -ScriptBlock {Get-Culture} -UseSSL
#endregion l3
#region l4
 # Lesson4: Double-Hop Remoting
 # [source] 1stHop-OK-> [intermediate] 2ndHop-FAIL-> [target]
 Enter-PSSession -ComputerName 2012R2-MS
 # [2012R2-MS]: PS C:\Users\Administrator.CONTOSO\Documents> Test-Path -Path \\2012R2-DC\FileShare 
 Test-Path : Access is denied + CategoryInfo : PermissionDenied: (\\2012R2-DC\FileShare:String) 
 # Credential Delegation
 # By default: • Your credentials are used to authenticate to the first machine 
 # • Your security principal is used on the first hop machine 
 # • Your credentials can not be passed from the first hop machine to the second hop machine, thus the second hop authentication fails
 # NOTE: Creating a custom endpoint using RunAs can achieve second hop without credential delegatio

 # Credential Delegation
 # For the second hop to succeed
 # • Credential delegation must occur from the intermediate computer
 # • CredSSP Authentication can be used
 # TASK-ITEM: Lookup unconstrained kerberos delegation
 # • Unconstrained (General) Kerberos Delegation can be used, but isn’t recommended
 # • Fresh credentials are required, but cannot use the logged-in user or integrated authentication
 # The Risk
 # You must trust the intermediate computer
 # If the intermediate computer is compromised: • Your credentials could be harvested • Your credentials could be delegated elsewhere without your knowledge
 # The same precautions you take before you type your password on your own machine, must be used on computers that may delegate your credentials
#endregion l4
#region l5
 # Lesson5: CredSSP
 # CredSSP (Credential Security Service Provider)
 # Authentication protocol that allows delegation
 # Configure and Enable for client and server roles separately
 # When enabling on the client, designate specific targets (avoid using wildcard *)
 # Use the same naming format throughout (either: short name, FQDN or IP)
 # Consider the risks of allowing your credentials to be stored on another machine
 # Example: Enabling CredSSP
 Enable-WSManCredSSP -Role Client -DelegateComputer 2012R2-MS
 Enable-WSManCredSSP -Role Server
 # Example: CredSSP
 Enable-WSManCredSSP -Role Client -DelegateComputer 2012R2-MS Invoke-Command -ComputerName 2012R2-MS -ScriptBlock {Enable-WSManCredSSP -Role Server}
 Invoke-Command -Authentication CredSSP -Credential contoso\administrator -ComputerName 2012R2-MS -ScriptBlock {Test-Path \\2012R2-DC\FileShare}
 #endregion l5
#endregion Section3: Security
#endregion Module2-Remoting

#region Module3-AdvancedFunctions 1
#region Section1: FunctionsReview
#region l1
 # Lesson 1: FunctionBasics
 <#
    What is a function?
    1. Reduces size of code and increases reliability
    2. Can accept parameter values and return output
    3. Advanced functions act like cmdlets
    4. Can include help content for use with Get-Help (like cmdlets)
 #>
 # Syntax
 # Param() statement is optional
     Function [Scope:]<name> 
     { 
        Param ($parameter1,$parameterN)
        <statement list>
        <statement list>  
     } #end function

 # Example: Creating a utility function
 # A long command (or series of commands) can be turned into a function to simplify future use.
 Get-Service -Name spooler -RequiredServices -ComputerName 2012R2DC 
 Function Get-ServiceInfo
 {
    Get-Service -Name Spooler -RequiredServices -ComputerName 2012r2DC
 } #end function
 # Use the function name to run the long command
 Get-ServiceInfo

 # Example:Creating a utility function with parameters
 # Turn cmdlet parameter values into function parameters to make code more dynamic 
 Function Get-ServiceInfo
 {
    param($svc, $computer)
    Get-Service -Name $svc -RequiredServices -ComputerName $computer
 } #end function
 Get-ServiceInfo -svc spooler -computer localhost
#endregion l1
#region l2
 # Lesson 2: Comment-BasedHelp
 <#
    Function Comment-based Help
    Syntax
    # .< help keyword>
    # <help content>
        -or -
    <#
        .< help keyword>
         < help content>
    #>  
    
    # Special help comment keywords can be used to write Get-Help topics for functions
    # Comment-based help keywords
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER  <ParameterName>
    .EXAMPLE
    .INPUTS
    .OUTPUTS
    .NOTES
    .LINK
    .COMPONENT
    .ROLE
    .FUNCTIONALITY
    #>
    # Example: Function Help
    function Get-SysLogNN
    {
     <#
      .SYNOPSIS
        Function that returns the most recent system event log entries.
      .DESCRIPTION
        Function that returns the most recent system event log entries. The number of items returned is determined by the parameter.
      .PARAMETER NumberOfEvents
      .EXAMPLE
        PS C:\> Get-SysLogNN -Log System -NumberOfEvents 10
      .EXAMPLE
        PS C:\> Get-SysLogNN -Log Application -NumberOfEvents 20
     #>
         param($log, $numberofevents)
         Get-EventLog -LogName $log -Newest $numberofevents
    } #end function
    Get-Help -Name Get-SysLogNN -full
 #>
#endregion l2
#endregion Section1: FunctionsReview

#region Section2: Parameters
#region l1
 # Lesson 1: Static Parameters
 <#
    Parameter overview

    Like cmdlets, functions/scripts have parameters that can be named, positional, switch, or dynamic

    Can be defined in three ways:
    Param() keyword in body
    Following function name before body
    $Args automatic variable (positional only)

    Static Parameters – No Param() Statement
    Can appear in parentheses () prior to the function body
    When defined outside of the function body the [CmdletBinding()] attribute arguments are not available.

    function <Name> ($p1,$p2,$pn)
    {
        <PowerShell code>
    } #end fucntion
 #>
#endregion l1
#region l2
 # Lesson 2: Switch Parameters
 # Parameters with no parameter value
 # To create a switch parameter in a function use the [Switch] type
 # False by default, True if present
 # Syntax Param ([switch]<ParameterName>)
 # Example

 function SwitchExample {
   Param([switch]$state)
   if ($state) {"on"} else {"off"}
}
SwitchExample
SwitchExample -state
SwitchExample -state:$false
SwitchExample -state:$true
#endregion l2
#region l3
 # Lesson 3: Dynamic Parameters 
 <#
 Parameters that are only available under certain conditions
 Use an IF or SWITCH statement to control availability
 Define parameters through objects instead of keywords
 System.Management.Automation.RuntimeDefinedParameter represents parameter
 System.Management.Automation.ParameterAttribute represents parameter attributes(e.g. Mandatory, Position, ValueFromPipeline, Parameter Set)
 Basic Syntax
 
 function <name> {
 Dynamicparam {<statement list>}
 } 
 #>
 # Example Dynamic Parameter 
 function Test-DynamicParam 
 {
    [CmdletBinding()]
    param(
        # Static parameter determines which other parameters will be available
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateSet("val1","val2")]
        [string]$param1
    ) #end param
    DynamicParam
    {
    # Switch discovers $param1 value and creates dynamic parameters accordingly
    switch ($param1)
    {
        # If $param1 = val1 then Val1DP parameter is available
        "val1"
        {
            $attributes = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $true
            $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)
            $Val1DP = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter("Val1DP",[string],$attributeCollection)
            $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("Val1DP",$Val1DP)
            return $paramDictionary
            break
        } #end match
        # If $param1 = val2 then Val2DP parameter is available
        "val2"
        {
            $attributes = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $true
            $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)
            $Val2DP = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter("Va21DP",[string],$attributeCollection)
            $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("Val2DP",$Val2DP)
            return $paramDictionary
            break   
        } #end match
    } #end switch   
    }
    -Process { Write-Output "`$param1: $param1 `t `$Val1DP: $Val1DP `t `$Val2DP: $Val2DP" } #end process
 } #end function
#endregion l3
#endregion Section2: Parameters
#region Section3: [CmdletBinding()]
#region l1
 # Lesson 1: Overview
 <#
    Gives a function parameter binding like a compiled cmdlet
    Automatically adds all common parameters
    Param() Required$Args cannot be used

    [CmdletBinding()] Attribute – Basic Syntax
    CmdletBinding syntax with no options used
    function  <Name> 
    {
       [CmdletBinding()]
       Param ()
    }

    CmdletBinding syntax showing all options
    function  <Name> 
    {
       [CmdletBinding(
          SupportsShouldProcess=<Boolean>,
          ConfirmImpact=<String>,
          DefaultParameterSetName=<String>,
          HelpURI=<URI>,
          SupportsPaging=<Boolean>,
          PositionalBinding=<Boolean>)]
       Param ()
    }
#>
#endregion l1
#region l2
 # Lesson 2: Risk Mitigation
 <#
    Preferences and parameters determine behavior when:
    Changes are made
    Changes are simulated
    Changes are prompted for confirmation
    Implemented by wrapping portions of code in If() statements to evaluate whether:
    To execute the scriptblock
    To display what would have occurred, without executing the scriptblock
    To prompt whether to execute the scriptblock
#>
    function Remove-TargetDirectory
    {
        [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact="High")]
        param([string]$directory="c:\test")
        If ($PSCmdlet.ShouldProcess("$directory","Removing directory"))
        {
            Remove-Item -Path $directory
        } #end if
    } #end 
    Remove-TargetDirectory

    Function Kill-Process
    {
        [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
        Param([String]$Name)

        $TargetProcess = Get-Process -Name $Name
        If ($pscmdlet.ShouldProcess($name, "Terminating Process"))
        {
            $TargetProcess.Kill()
        } #end if
    } 
    Kill-Process -Name notepad -WhatIf
    Kill-Process -Name notepad
    
    <#
        PowerShell uses a combination of all three mitigation mechanisms to determine whether confirmation prompts appear:
        $ConfirmPreference
        Automatic variable controls confirmation prompts
        Defaults to "High"
        -Confirm parameter can also override confirmation prompts
        ConfirmImpact keyword defines the impact level of the function
        
    [CmdletBinding()] Attribute – ConfirmImpact

    function  <Name> 
    {
       [CmdletBinding(
          SupportsShouldProcess=<Boolean>,
          ConfirmImpact="High","Medium","Low",
          DefaultParameterSetName=<String>,
          HelpURI=<URI>,
          SupportsPaging=<Boolean>,
          PositionalBinding=<Boolean>)]
       Param ()
    } #end function

    Confirmation Severity Levels
    Default confirmations will be prompted when:
    ConfirmImpact value is greater than or equal to $ConfirmPreference value
    $ConfirmPreference = High (default)
    #>

    Function Kill-Process
    {   [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="Medium")]
        Param([String]$Name)

        Process
        {
            $TargetProcess = Get-Process -Name $Name
            If ($pscmdlet.ShouldProcess($name, "Terminating Process"))
            {
                $TargetProcess.Kill()
            }
        }
    } #end function

    Function Kill-Process
    {
        [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
        Param([String]$Name)

        Process
        {
            $TargetProcess = Get-Process -Name $Name
            If ($pscmdlet.ShouldProcess($name, "Terminating Process"))
            {
                $TargetProcess.Kill()
            }
        }
    } #end function

#endregion l2
#region l3
 # Lesson 3: Arguments
 # [CmdletBinding()] – DefaultParameterSetName


    function Name 
    {
        # Specifies the parameter set to use when it cannot be determined from user input
       [CmdletBinding(DefaultParameterSetName="<String>")]
       Param ()
    }
    function Name 
    {  
       # Specifies an online version of a help topic that describes the function
       [CmdletBinding(HelpURI="http:|https://HelpURI")]
       Param ()
    }
    function Name 
    {
       # Automatically adds First, Skip, and IncludeTotalCount parameters
       # Allow users to select output from a large result set
       # Designed for functions that return data from data stores, such as a SQL database.      

       [CmdletBinding(SupportsPaging=$true)]
       Param ()
    }
    
    function Name 
    { 
       # Determines whether function parameters are positional by default
       # Default value is $True when not present in CmdletBinding
       # When parameters are positional, the parameter name is optional
       # Position argument of the Parameter attribute takes precedence over the PositionalBinding argument
       [CmdletBinding(PositionalBinding=$true)]
       Param ()
    }

#endregion l3
#endregion Section3: [CmdletBinding()]
#endregion Module3-AdvancedFunctions 1
#endregion DAY-01

#region DAY-02
#region Module4-AdvancedFunctions 2
#region Section 1: Advanced Parameters and Attributes
#region l1
 # Lesson 1: [Parameter()] Attribute
 # Optional
 # Used to declare attributes of function parameters
 # To be recognized as an ‘advanced function’, a function must have either, or both, of the [CmdletBinding()] or the [Parameter] attributes
 # Parameter attribute has arguments that define the characteristics of the parameter
 # Syntax - Single Argument
 <#   
    function <name> 
    {
      Param (
        # Parentheses that enclose the argument and its value must follow "Parameter" keyword with no intervening space
        [parameter(Argument=value)] 
        $ParameterName
      )
    } 
    
    # Syntax - Multiple Argument
    function <name> 
    {
        # Commas separate arguments
        Param (
        [parameter(Argument1=value1 , 
                   Argument2=value2)]
        $ParameterName
      )
    } 
    #>
  # ParameterSetName
  <#
    Specifies parameter set to which a parameter belongs
    If no parameter set is specified, parameter belongs to all the parameter sets defined by the function
    To be unique, each parameter set must have at least one parameter that is not a member of any other parameter set
  #>
  Param (
  [parameter(ParameterSetName="Machine")]
  [String[]]$MachineName,
  [parameter(ParameterSetName="User")]
  [String[]]$UserName
  ) 
  
  # Mandatory
  Param ([parameter(Mandatory=$true)][String[]]$MachineName)
  
  # Position
  Param ([parameter(Position=0)][String[]]$MachineName)
  # By default, all function parameters are positional 
  # PowerShell assigns position numbers to parameters in the order in which the parameters are declared in the function
  # To disable, set PositionalBinding argument of CmdletBinding attribute to $False 
  # Position argument takes precedence over PositionalBinding argument for the parameters on which it is declared
  
  # ValueFromPipeline: Use if parameter accepts entire object (not just a property)
  ValueFromPipeline Param ([parameter(ValueFromPipeline=$true)] [String[]]$MachineName)
  
  # ValueFromPipelineByPropertyName: Use if parameter accepts property of an object
  ValueFromPipelineByPropertyName Param ([parameter(ValueFromPipelineByPropertyName=$true)] [String[]]$MachineName)

  # HelpMessage: Displays a message when a mandatory parameter is missing
  Param ( [parameter(Mandatory=$true, HelpMessage="Enter computer names separated by commas.")] [String[]]$ComputerName )

  # ValueFromRemainingArguments: Parameter accepts all values that are not arleady assigned
  Param( [parameter(ValueFromRemainingArguments=$true)] [String[]]$ComputerName )

  # Example: Value from Remaining Arguments
  # Without NoValueFromRemainingArguments $p2 = ‘two
  function NoValueFromRemainingArguments { Param($p1,$p2)  "`$p1 $p1"; "`$p2 $p2"}
  # With ValueFromRemainingArguments $p2 = ‘two three’
  function ValueFromRemainingArguments { Param($p1,[Parameter(ValueFromRemainingArguments=$true)]$p2)  "`$p1 $p1"; "`$p2 $p2"}
#endregion l1
#region l2
 # Lesson 2: [Alias()] Attribute
 # Establishes an alternate name for a parameter An unlimited number of aliases can be assigned
 # Example: MachineName and CN are aliases for the ComputerName Parameter
 Param ([parameter()][alias("CN","MachineName")] [String[]]$ComputerName)
#endregion l2
#region l3
 # Lesson 3: [OutputType()] Attribute
 # Reports .NET type of object function returns 
 # Can combine with optional ParameterSetName parameter for different output types 
 # Use a null value when output is a not a .NET type
 
 # Multiple Output Types
 <#
 [OutputType([int],[string],[char])] 

 One or more Paramter Sets
 [OutputType([<Type1>], ParameterSetName="<Set1>","<Set2>")] 
 [OutputType([<Type2>], ParameterSetName="<Set3>")]
 #>
 # Example: 
 function Print-Hello 
 { 
    [OutputType([double])] 
    Param ($Name)
    "Hello $Name" 
 } #end function
 
 (Get-Command Print-Hello).OutputType
 # Note: The OutputType attribute value is only a documentation note. 
 # It is not derived from the function code, or compared to the actual function output. As such, the value may be inaccurate.
 # Below command displays the actual .NET type returned by the command
 (Print-Hello -Name Johan).GetType().FullName
#endregion l3
#region l4
 # Lesson 4: Validation Attributes
 # [ValidateSet()] Attribute
 # Specifies a set of valid values for a parameter or variable 
 # PowerShell generates an error if a value does not exist in the set
 function Get-CpuCounter 
 { 
    Param([ValidateSet("% Processor Time","% Privileged Time","% User Time")] $perfcounter)
    Get-Counter -Counter "\Processor(_Total)\$perfcounter" 
 } #end function
 # Intellesense suggests allowed values
 Get-CpuCounter -perfcounter
 # Other Validation Attributes
 # AllowNull: $null is allowed
 param([parameter(Mandatory=$true)]
       [AllowNull()]
       [string]$ComputerName
      ) #end param
 # AllowEmptyString: empty string is allowed
 param([parameter(Mandatory=$true)]
       [AllowEmptyString()]
       [string]$ComputerName
      ) #end param
 # AllowEmptyCollection: Empty collection is allowed
 param([parameter(Mandatory=$true)]
       [AllowEmptyCollection()]
       [string[]]$ComputerName
      ) #end param
 # Other validation attributes
 # ValidateNotNull: $null is not allowed
 Param ([parameter(Mandatory=$true)][ValidateNotNull()]$ID)
 # ValidateNotNullOrEmpty: Neither $null nor empty string allowed
 Param ([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String[]]$UserName)
 # ValidateCount: Specifies minimum and maximum accepted number of parameter values
 Param ([ValidateCount(1,5)][String[]]$ComputerName) 
 # Validatelength: Specifies minimum and maximum accepted number of characters
 Param ([ValidateLength(1,10)][String[]]$ComputerName) 
 # ValidatePattern: Specifies a regular expression to compare to the parameter value
 Param ([ValidatePattern("[0-9].[0-9].[0-9].[0-9]")][String[]]$ComputerName)
 # ValidateRange: Specifies a numeric range for each parameter value
 Param ([ValidateRange(0,10)][Int]$Attempts)
 # ValidateScript: Specifies a "script" that is used to validate a parameter value PowerShell generates an error if the "script" returns "false" or if it throws an exception 
 Param ([ValidateScript({$_ -ge (get-date)})][DateTime]$EventDate
#endregion l4
#endregion Section 1: Advanced Parameters and Attributes
#endregion Module4-AdvancedFunctions 2

#region Module5-RegularExpressions(Regex)
#region Section 1: Introduction
#region l1
 # Lesson 1: What is Regex?
 # A sequence of characters that forms a search pattern
 # Enables parsing of large amounts of text to find specific character patterns, to validate, extract, edit, replace, or delete text substrings
 # PowerShell supports the .NET Framework Regular Expression engine
 "Phone number: +61 42 911 1972" -match "\+\d{2} \d{2} \d{3} \d{4}" 
 # Note: Escape character for regular expressions ( \ ) is different than for PowerShell ( ` )
 # PowerShell Regex Language Support
 
 # Operators 
 # • -split 
 # • -csplit 
 # • -replace 
 # • -creplace 
 # • -join 
 # • -match 
 # • -cmatch 
 # • -notmatch 
 # • -cnotmatch
 
 # Statements 
 # • Switch
 
 # Parameter Attribute 
 # • ValidatePattern (Discussed in Functions Module)
 
 # Cmdlets 
 # • Select-String

 # .NET 
 # • System.Text.RegularExpressions namespace

 # Provides access to underlying .NET regular expression engine
 # [Regex] type accelerator contains methods for split, match, replace, etc.
 # [System.Text.RegularExpressions.RegexOptions] allows attributes like RightToLeft, IgnoreCase, Multiline, etc.
 # [System.Configuration.RegexStringValidator] determines whether a string conforms to a regex pattern
 [System.Text.RegularExpressions.Regex]
 # Type accelerator [regex]
 [System.Text.RegularExpressions.RegexOptions]
 [System.Configuration.RegexStringValidator]
 # Automatic variable
 # Hash table of matched string values
 # Works with operators and statements
 # Enables extraction of matched content in addition to boolean true
 # Stops after first match
 # Example: Searching for a simple match using literal "Dev"
 "You say Yes, I say No, What does the Dev say?" -match "Dev"
 $matches
 # Overall regex match
 $matches[0] 
 # First capturing group
 $matches[1]  
 # Named group $matches["group name"]
#endregion l1
#region l2
 # Lesson 2: Characters, Character Classes and Quantifiers
 # Format Logic Example 
 # value Exact characters anywhere in original value 
 "book" -match "oo" 
 # . Any single character, except newline 
 "copy" -match "c..y" 
 #[value] At least one character in brackets 
 "big" -match "b[iou]g" 
 # [range] At least one character within range 
 "and" -match "[a-e]nd" 
 # [^] Any character(s) except those in brackets 
 "and" -match "[^brt]nd" 
 # ^ Beginning character(s) 
 "book" -match "^bo" 
 # $ End character(s) 
 "book" -match "ok$" 
 # \ Character that follows as an escaped character 
 "Try$" -match "Try\$"
 
 # Character Class Matches
 # \w Any word character
 "abcd defg" -match "\w+" # matches abcd
 # \W Any non-word character
 "abcd defg" -match "\W+" # matches the space 
 # \s Any white-space character 
 "abcd defg" -match "\s+" 
 # \S Any non-white-space character 
 "abcd defg" -match "\S+" 
 # \d Any decimal digit 
 12345 -match "\d+" 
 # \D Any non-decimal digit 
 "abcd" -match "\D+"
 # \p{name} Any character in named character class such as Ll, Nd, Z, IsGreek, and IsBoxDrawing 
 "abcd defg" -match "\p{Ll}+"
 # \P{name} Text not included in groups and block ranges specified in {name}
 1234 -match "\P{Ll}+"
 # * Zero or more {0,}
 "abc" -match "\w*"
 "baggy" -match "g*"
 # + One or more {1,}
 "xyxyxyxy" -match "xy+"
 # ? Zero or one {0,1}
 "abc" -match "\w?"
 "http" -match "https?"
 # {n} Exactly n matches
 "abc" -match "\w{2}"
 # {n,} At least n matches
 "abc" -match "\w{2,}"
 # {n,m} At least n, but no more than m, matches
 "abc" -match "\w{2,3}"

 # Regex Groups and Alternation (OR)
 # (): Groups regular expressions, applies quantifier to group, restricts alternation to group
 "abcd defg" -match "(\w{4})"
 # (?<name>): Named groups. Group names must begin with a letter
 "abcd defg" -match "(?<all>(?<word1>\w{4})(?<nonword>\W)(?<word2>\w{4}))"
 # | Alternation Logical OR
 "3001 2009 6754" –match "(3001)|(2009)"
 
 #Example: Groups
 "contoso\administrator" -match "\w+\\\w+"
 "contoso\administrator" -match "(\w+)\\(\w+)"
 "contoso\administrator" -match "(?<Domain>\w+)\\(?<UserName>\w+)"
 "192.168.1.254" -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
 "192.168.1.254" -match "(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})"
 "192.168.1.254" -match "(?<FirstOctet>\d{1,3})\.(?<SecondOctet>\d{1,3})\.(?<ThirdOctet>\d{1,3})\.(?<FourthOctet>\d{1,3})"

 # Mode Modifiers
 # Matching modes can be specified in the regex pattern 
 # Specify regex options w/o using [System.Text.RegularExpressions.RegexOptions] 
 # Useful with operators, where regex options cannot be specified 
 # Can combine mode modifiers e.g. (?smi) Use minus to turn mode off
 # Format Mode Description 
 # (?i) IgnoreCase Case insensitive 
 # (?m) Multi-line ^ and $ match next to line terminators 
 # (?s) Single-line Dot matches any character including line terminator
 # Mode modifier examples
 # Case insensitive
 "test" -match "(?i)T"
 "test" -match "(?-i)T"
$text = @"
Hello
a1
digital
world, you binary a2
thing you
"@
([regex]::Matches($text,"(?m)^.\d{1}")).value
# Single line
"hello`nworld" -match "(?s).+"
$matches.values
#endregion s1l2
#endregion Section 1: Introduction
#region Section 2: RegexUseCases
#region s2l1
# Example 1: Search for match with Select-String: \d - any decimal digit
Get-Content -Path C:\temp\dhcp-2018-10-17T1828.txt | Select-String -Pattern "10.161.97.37"
# Example 2: Search for match with switch -regex and extract data with $matches. \d - any decimal digit, {2} - Exactly 2 matches, % - literal percentage sign
function Get-WiFiSignalStrength 
{ 
    $wlan = (netsh wlan show interfaces) 
    Switch -Regex ($wlan) 
    {  
        "\d{2}%" {Write-Host $($matches.Values) -ForegroundColor Green} 
    } #end switch
} #end function
Get-WiFiSignalStrength

# Example 3: Replacing substrings with -replace or -creplace
"Mr. Henry Hunt, Mrs. Sara Samuels, Miss. Nicole Norris" ` -replace "Mr\. |Mrs\. |Ms\.",""
# Henry Hunt, Sara Samuels, Miss. Nicole Norris
# \.: escapes dot to use it as a literal dot (instead of regex 'any single character')
# Space: Literal space
# |: Alternation operator Mr. OR Mrs. OR Ms.
# Example 4: Split text with -split or -csplit
# Syntax: Split Regex Options
# <String> -Split <Delimiter>[,<Max-substrings>[,"<Options>"]]
# Options Syntax: 
# • SimpleMatch [,IgnoreCase] 
# • [RegexMatch] [,IgnoreCase] [,CultureInvariant] [,IgnorePatternWhitespace] [,ExplicitCapture] [,Singleline | ,Multiline]
# SimpleMatch: 
# • SimpleMatch: Use simple string comparison (regex characters are considered as normal text) 
# • IgnoreCase: Case-insensitive (even with –cSplit
# RegexMatch: 
# • RegexMatch: Use regular expression. Default 
# • IgnoreCase: Case-insensitive (even with –cSplit) 
# • CultureInvariant: Ignores cultural differences 
# • IgnorePatternWhitespace: Ignores un-escaped whitespace and comments (#) 
# • Multiline: Multiline mode recognizes start and end of lines and strings 
# • Singleline: Recognizes only start and end of strings; default 
# • ExplicitCapture: Ignores non-named match groups; only explicit capture groups are returned
# Example 5: Split text with -slit or -csplit
$a = @"
1The first line. 
2The second line. 
3The third of three lines. 
"@
$a -split "^\d", 0, "multiline" 
<#
The first line.
The second line.
The third of three lines
#>
# ^: Beginning with character(s)
# \d: Any decimal digit
# Example 6: Split text with regex TYPE
[regex]::Split("www.microsoft.com","\.")
# \.: Matches literal dot
# [regex]: Built-in TYPE accelerator for [System.Text.RegularExpressions.Regex]
# Example 7: Regex and regex option TYPES
$text = @("www.microsoft.com", "www.Microsoft.com")
[regex]::matches($text,"[a-z]icrosoft.com") # Case sensitive pattern match 
[regex]::matches($text, "[a-z]icrosoft.com", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) # matches() Returns multiple matches. Tip: match() returns single match 
# \. Matches a literal dot 
# [a-z] Matches any lowercase character between a and z 
# [Regex] Built-in TYPE accelerator for [System.Text.RegularExpressions.Regex]
#endregion s2l1
#endregion Section 2: RegexUseCases
#endregion Module5-RegularExpressions(Regex)

#region Module6-ErrorHandling
#region Section 1: IntroToErrors
#region s1l1
 # Lesson 1: WhatIsAnError?
 <#
    Powershell representation of an object-based exception
    Design Time Errors
    * Syntax errors are caught by the PowerShell parsar and/or PowerShell ISE
    Runtime Errors
    * When something goes wrong duirng code execution
    * Only detectable when a specific state is reached or statement is executed
    
    Types of Errors
    1. Terminating
        * Stops a statement from running
        * If PowerShell does not handle the terminating erro, it stops running the function or script
    2. Non-Terminating
        * Less severe, often just a single operation out of many
        * Primary processing doesn't need to stop
        * Error may be displayed in host application
    NOTE: Cmdlet/Function/Script/Objec author decides which type of errors to trigger
 #>
#endregion s1l1
#region s1l2
 # Lesson 2: DealingWithErrors
 <#
    What to do when an error occurs?
    1. Nothing
        * Red error messages are displayed
        * Results could be unpredictable
    2. Debug Code
        * Identify where the error has occured
        * Resolve syntax or logic problems
    3. Handle the Errors with Code
        * Typically hide the red error messages
        * Write logic to handle errors appropriately
        * Actions can be: ignore, process, log, raise or halt further execution
    
    Error Handling: Terminating vs. Non-Terminating
    1. Terminating Errors
        * Requires Try-Catch-Finally or Trap statements
        * Enters a child scope
    2. Non-Terminating Erros
        * Test for error and run handling code
        * Can be converted into terminating error
            * "Stop" with -ErrorAction or $ErrorActionPreference
            * Use the "throw" keyword
 #>
#endregion s1l2
#endregion Section 1: IntroToErrors
#region Section 2: Streams
#region s2l1
 # Lesson 1: PowerShellsFiveStreams
 <#
    * Streams separate different categories of output
    * Without separation, error and output object would be mixed, requiring later filtering
    * Some streams are hidden (verbose, Debug)
    * Redirection operators allow control over a streams destination

    The Streams
    1. Ouptut
        * Most common
        * Flows down pipeline
        * Captured by Assignment "="
    2. Error
        * Execution Problems
        * Shown by default in red
    3. Warning
        * Less severe execution problems
        * Shown by default in yellow
    4. Verbose
        * More detailed execution information
        * Hidden by default
    5. Debug
        * Related to debugging code
        * Hidden by default
 #>
 # Example: Streams
 "Output Stream"
 Write-Output "Output Stream"
 Write-Error "Error Stream"
 Write-Warning "Warning Stream"
 Write-Verbose "Verbose Stream" -Verbose
 Write-Debug "Debug Stream" -Debug

 <#
    Controlling Stream Behavior
    1. Preference variables
        * Variables that control how PowerShell reacts to stream messages
    2. Cmdlet common parameters
        * -Verbose, -Debug, -ErrorAction, -WarningAction
    NOTE: There is no preference variable for Output Stream
    * Controlled by assignments, redirection, and pipeline
 #>
 # Stream defaults
 $ErrorActionPreference
 $WarningPreference
 $VerbosePreference
 $DebugPreference
#endregion s2l1
#region s2l2
 # Lesson 2: RedirectionOperators
 <#
    Save streams of information to a file
 #>
 # > Sends outpout to specified file
 Get-Process > Process.txt
 # >> Appends output to contents of speciffied file
 dir *.ps1 >> scripts.txt
 # 2> Sends errors to specified file
 Get-Process -Name none 2> Errors.txt
 # 2>> Appends errors to contents of specified file 
 Get-Process -Name none 2>> Errors.txt
 # 2>&1 Sends errors (2) and success output (1) to success output stream
 Get-Process -Name None, PowerShell 2>&1
 # 3> Sends warnings to specified files
 Write-Warning "Test!" 3> Warnings.txt
 # 3>> Appends warnings to contents of specified file
 Write-Warning "Test!" 3>> Warnings.txt
 # 3>&1 Sends warnings (3) and success output (1) to success ouptut stream
 function Test-Warning
 {
    Get-Process -Name Powershell 
    Write-Warning "Test!"
 } # end function
 Test-Warning 3>&1
 # 4> Sends verbose output to specified file
 Import-Module -Name * -Verbose 4> Verbose.txt
 # 4>> Appends verbose output to contents of specified file
 Import-Module -Name * -Verbose 4>> Verbose.txt
 # 4>&1 Sends verbose output (4) and success output (1) to success output stream
 Import-Module -Name * -Verbose 4>&1
 # 5> Sends debug messages to specified file
 Write-Debug "Starting" 5> Debug.txt
 # 5>> Appends debug messages to contents of specified file
 Write-Debug "Saving" 5>> Debug.txt
 # 5>&1 Sends debug messages (5) and success output (1) to success output stream
 function Test-Debug
 {
    Get-Process -Name Powershell
    Write-Debug "PS"
 } # end function
 Test-Debug 5>&1
 # *> Sends all ouptut types to specified file
 function Test-Output
 {
    Get-Process -Name powershell, none
    Write-Warning "Test!"
    Write-Verbose "Test Verbose"
    Write-Debug "Test Debug"
 } # end function
 Test-Output *> Test-Output.txt
 # *>> Appneds all output type to contents of specified file
 Test-Output *>> Test-Output.txt
 # *>&1 Sends all output types (*) to success output stream
 Test-Output *>&1
#endregion l2
#endregion Section 2: Streams
#region Section 3: Non-terminatingErrors
#region s3l1
 # Lesson 1: Overview
 <#
    1. Non-Terminating Errors
        Errors do not stop processing
            * Optionally handle error in code
            * Continue with rest of code
            * Does not trigger Trap, Try...Catch...Finally
        Can be converted into terminating errors
            * -ErrorAction Stop or $ErrorActionPreference = 'Stop'
            * Can then utilize Trap, Try...Catch...Finally 
        Handling flow
        1. [Suppress error messages]$ErrroActionPreference = "SilentlyContinue"
        2. [Error and/or Success occurs]*Non-terminating
        3. [Check if we had error]*$? or $Error
        4. [Run Error Handler Code]*Log File, Custom Message, etc.
        5. [Continue with rest of normal code]
 #>
#endregion s3l1
#region l2
 # Lesson 2: ErrorAction
    <#
        Actions to suppress error messages
        $ErrorActionPreference
        * Automatic variable for remaining script/function/session
        -ErrorAction common parameter
        * On all cmdlets and advanced functions/scripts

        ErrorAction values
        0. "SilentlyContinue": Error message is not displayed and execution continues w/o interruption.
        1. "Stop": Raises terminating error and displays and error message and stops command execution.
        2. "Clontinue" [default]: Displays error message and continues execution.
        3. "Inquire": Displays error message and prompts user to continue.
        4. "Ignore": Can only be used with -ErrorAction common parameter (not with $ErrorActionPreference)
        5. "Suspend": Automatically suspends a workflow job. Allows for investigation, can be resumed.

        $ErrorActionPreference
        Variable value affects all subsequent commands in same variable scope
        1. Errors are displayed by default
        $ErrorActionPreference
        2. Visible errors suppressed
        $ErrorActionPreference = "SilentlyContinue"
        or
        $ErrorActionPreference = 0

        ErrorAction Common Parameter
        * Affects only command where used
        * Available on all cmdlets and advanced functions
        * Parameter alias: -EA
    #>
    Get-Process -Name NotValidName
    Get-Process -Name NotValidName -ErrorAction SilentlyContinue
    Get-Process -Name NotValidName -EA 0
#endregion l2
#region l3
 # Lesson 3: TestingForErrors
 <#
    $? - Last operation execution status
    Automatic variable
    * Contains execution status of last operation
    * Applies to both trerminating and non-terminating errors
    * Even applies to external command exit codes
    True = Complete Success
    False = Failure (Partial or complete)
    Typically used in an If() statement, to test and then run error handling code
 #>
 # Exapmple: $?
 $WindowsFolder = Get-Item -Path c:\windows
 $?
 $WindowsFolder = Get-Item -Path c:\NotValidFolderName -ErrorAction SilentlyContinue
 $?
 Get-Process -Name System, NotValidName
 $?
 # Example: $? with External Commands
 ping.exe 2012r2-dc -n 1
 $?
 ping notValidName
 $?
#endregion l3
#region l4
 # Lesson 4: $Error Array
 # $Error - An array of error objects
 # Automatic varaible - Array holds errors that have occured in the current session
 # Control maximum array size:
 $MaximumErrorCount
 # 256
 # The most recent error is the first object in the array
 $Error[0]
 # Prevent an error from being added to the $Error array, bu using "-ErrorAction Ignore"
 # $Error - View all properties
 # By default $Error only displays a summary of the error
 # View all properties using one of the following examples:
 $Error[0] | Format-List -Property * -Force
 $Error[0] | Select-Object -Property *
 # Drill into the object model for more error details
 $Error[0].CategoryInfo
 $Error[0].InvocationInfo
 $Error[0].ScriptStackTrace
 # -ErrorVariable Common Parameter
 # Capture errors from a specific action into a dedicated variable
 # create the variable and store any errors in it:
 Get-Process -Id 6 -ErrorVariable MyErrors
 # Append error messages to the variable:
 Get-Process -Id 6 -ErrorVariable +MyErrors
 # Work with the variable just like $Error
 $MyErrors
 # $Error holds all errors, including those sent to -ErrorVariable
#endregion l4
#region l5
 # Lesson 5: Creating Non-TerminatingErrors
 <#
    Write-Error
    * Creates non-terminating errors
    * Can be handled in-code via $?
    * Automatically stored in $Error
    * Useful for re-usable functions to report errors to caller
 #>
 Write-Error "My Custom Error"
 $Error[0]
#endregion l5
#endregion Section 3: Non-terminatingErrors
#region Section 4: TerminatingErrors
#region s4l1
 # Lesson 1: Overview
 <#
    Terminating Errors
    * Severe errors where processing of the current scope can’t continue
    * Error cannot be handled in the same code block, like non-terminating errors
    * Use Trap or Try{} Catch{} Finally{} to handle
    * Non-Terminating Errors can be re-thrown as terminating errors using "-ErrorAction stop"
    
    Overview of Trap/Try..Catch..Finally
    Trap: Set a Trap, run code, terminating error triggers trap code
    Try/Catch/Finally: Encapsulate CODE into Try Block, Terminating error fires catch block, Finally block always run even during Ctrl-C
 #>
#endregion s4l1
#region s4l2
 # Lesson 2: CreatingTerminatingErrors
    <#
        Throw
        * User-created terminating error
        * Throws a message string or any object type
        * Can be used to enforce mandatory parameters • PowerShell 3.0+, use the [Parameter(Mandatory)] attribute
        * Useful in re-usable code to cause halt and report errors to caller for severe errors
        245
        PS C:\> If ( -not (Test-Path $UserFile)) { Throw "ERROR: File not found" }
    #>

# Example: Basic Throw
if (1 -eq 1)
{
    "Line before the terminating error" 
    Throw "This is my custom terminating error" 
    "Line after the throw" # This line doesn't run because of termination
} # end funciton

# Example: Mandatory Parameter using Throw
Function SampleThrowBasedMandatoryParam 
{ 
    Param ($ComputerName = $(Throw "You must specify a value")) 
    Get-CimInstance Win32_BIOS -ComputerName $ComputerName 
} # end function
SampleThrowBasedMandatoryParam 
SampleThrowBasedMandatoryParam -ComputerName 2012r2-ms
#endregion s4l2
#region s4l3
 # Lesson 3: TryCatchFinally
<#
 Try 
{
    <Code that could cause terminating errors>
} # end try
Catch [Exception Type1], [Exception Type2], [Exception Type3] 
{ 
    <Error handling> 
} # end catch
Catch 
{ 
    <Handle uncaught errors> 
} # end catch
Finally 
{ 
    <Clean up code> 
} # end finally

* One or more catch blocks
* Exception type optional
* Finally block optional
* Must have at least one Catch or Finally block

Try, Catch, Finally Flow
1. The Try block defines a section of a script to monitor for errors 
2. When an error occurs within the Try block, the error is first saved to $Error
3. PowerShell then searches for a Catch block to handle the error
4. If no matching Catch block is found or defined, then parent scopes are searched
5. After the Catch block, the Finally block executes
6. If the error cannot be handled, the error is written to the error stream

Finally Block
Will run even if Ctrl-C is used during the Try block execution
Useful for: 
• Releasing resources 
• Closing network connections 
• Closing database connections 
• Logging 
• Etc.
#>
# Example: Try/Catch/Finally
Try 
{
    $wc = New-Object System.Net.WebClient 
    $wc.DownloadFile("http://www.contoso.com/MyDoc.doc")
} # end try
Catch [System.Net.WebException],[System.IO.IOException] 
{ 
    "Cannot get MyDoc.doc from http://www.contoso.com" 
} # end catch 
Catch 
{ 
    "An error occurred that could not be resolved." 
    $_.Exception.Message # Contains caught error
} # end catch
Finally 
{ 
    If ($wc) 
    { 
        $wc.Dispose() 
    } # end if
} # end finally 
Example
#endregion s4l3
#region s4l4
 # Lesson 4: Trap
<#
    Trap { }
    Specifies a list of statements to run when a terminating error occurs
    Handles terminating errors and allow execution to continue 
    Can catch all, generic (namespace), or specific exception types
    Multiple Trap statements can be specified in a script
    Is "global", applies to all code in the same scope, before or after
#>
# This is a specific trap
Trap [System.DivideByZeroException] 
{   
    "Can not divide by ZERO!!!-->   " + $_.exception.message 
    Continue 
} # end trap
# This is a generic catch all trap
Trap 
{
    "A serious error occurred-->   " + $_.exception.message 
    Continue 
} # end trap
Write-Host -ForegroundColor Yellow "`nAttempting to Divide by Zero" 1 / $null
Write-Host -ForegroundColor Yellow "`nAttempting to find a fake file" Get-Item c:\fakefile.txt -ErrorAction Stop
Write-Host -ForegroundColor Yellow "`nAttempting an invalid command" 1..10 | ForEach-Object {Bogus-Command}
#endregion s4l4
#region s4l5
 # Lesson 5: ErrorHandlingAndScope
 <#
    Exceptions can be re-thrown to the parent scope 
    • i.e. from a function to the calling scope (exception ‘bubbling’) 
    • Unhandled exceptions in any scope will be processed by the Windows PowerShell Host 
    In the code below 
    • The "function3" catch block is executed, which throws a new exception 
    • The new exception is caught by the parent catch block 
    • This affects flow control, as the "function3 was completed" text is NOT executed
 #>
$ErrorActionPreference = SilentlyContinue
Function function3 
{ 
    Try { NonsenseString } 
    Catch {"Error trapped inside function" ; Throw} 
    "Function3 was completed" 
} # end function
Try{ Function3 } 
Catch { "Internal Function error re-thrown: $($_.ScriptStackTrace)" } 
"Script Completed"
#endregion s4l5
#endregion Section 4: TerminatingErrors
#endregion Module6-ErrorHandling
#endregion DAY-02

#region DAY-03
#region Module7-Debugging
#region Section 1: Introduction
<#
Section 1: Introduction 
• Lesson 1: Overview 
• Lesson 2: Customized Debugging Information
Section 2: Debugging your Code 
• Lesson 1: Break Points 
• Lesson 2: ISE Debugging 
• Lesson 3: Command-Line Debugging 
• Lesson 4: Debugging Cmdlets
#>
#region l1
 # Lesson 1: Overview
 <#
    Debugging Overview
        The process of examining code while running to identify and correct errors
        Works with PowerShell scripts, functions, commands, workflows, or expressions
        Windows PowerShell includes cmdlets to manage breakpoints and view the call stack 
        Windows PowerShell ISE includes graphical debugging capabilities
Debugging Features
Runtime code examination Identify errors Debug with Console or ISE v4.0 debugger targets: 
• Scripts 
• Functions 
• Workflows 
• Commands 
• Expressions
Remote debugging (only via console) $DebugPreference -Debug Common Parameter Debugging cmdlets: 
• Breakpoint 
• Call stack 
• Debug 
• StrictMode 
• Trace
 #>
#endregion l1
#region l2
 # Lesson 2: CustomizedDebuggingInformation
 <#
    Custom Debug Messages
    [CmdletBinding()] enables debug common parameter 
    Write-Debug adds custom messages 
    -Debug displays messages and prompts to continue
 #> 
 Function Get-LogNN 
{ 
    [CmdletBinding()] 
    Param ($log, $count) 
    Write-Debug "$(Get-Date -DisplayHint Time):Retrieving $count from $log" Get-EventLog -LogName $log -Newest $count
} # end function
# -Debug Common parameter displays Write-Debug Cmdlet output
Get-LogNN -log System -count 2 -Debug

<#
$DebugPreference automatic variable
* Debug informnation is not displayed by default
#>
$DebugPreference
<#
    To display debug information:
    1. Change $DebugPreference
    2. Use -Debug common parameter
    
    Valid values:
    1. SilentlyContinue (default): Debug messages is not diplayed and execution continues w/o interruption
    2. Stop: Displays debug message and stops execution
    3. Inquire: Displays debug message and prompts
    4. Continue: Displays debug message and continues with execution
#>
#endregion l2
#endregion Section 1: Introduction
#region Section 2: DebuggingYourCode
#region s2l1
 # Lesson l1: BreakPoints
 <#
    A place in the script to pause execution 
    Triggers the debugger environment 
    While paused, command prompt is prefixed with "[DBG]:"

    While paused, you can interact with the debug environment to: 
    • Examine variables 
    • Query runtime state 
    • Test conditions
    Breakpoints can be set at: 
    • Variables (Read / Write / ReadWrite) 
    • Commands (Cmdlet or function) 
    • Line and Column Numbers

    Breakpoint Cmdlets
    1. Get-PSBreakpoint: Gets breakpoints in current session 
    2. Set-PSBreakpoint: Sets breakpoints on lines, variables, or commands 
    3. Disable-PSBreakpoint Turns off breakpoints in current session 
    4. Enable-PSBreakpoint Re-enables breakpoints in current session 
    5. Remove-PSBreakpoint Deletes breakpoints from current session

    The Windows PowerShell ISE includes menu items that map to some of these cmdlets.

    Breakpoints - Automatic Variables
    $NestedPromptLevel: Find prompt nesting level
    $PSDebugContext: Defined in local scope, use presence to determine whether in debugger or not e.g.:
 #>
 # Example
 if ($PSDebugContext)
 {
    "Debugging"
 } # end if
 else
 {
    "Not Debugging"
 } # end else
#endregion s2l1
#region l2
 # Lesson 2: IseDebugging
 <#
    ISE Breakpoints
    * Script must be saved before a breakpoint can be set
 #>
Set-StrictMode -Version latest
function Get-LogNN
{
[CmdletBinding()]
Param($log, $count)
# Set breakpoint below. Enabled breakpoint will be highlighted in red. When hit, it will turn yellow.
Write-Debug "$(Get-Date -DisplayHint Time):Retrieving $count from $log"
Get-EventLog -LogName $log -Newest $count
Get-PSCallStack
} # end function
Get-LogNN -log system -count 2 -Debug

<#
To set a breakpoint:
1. Debug menu
2. Right-click the toggle breakpoint
3. Press F9

To list/remove/enable/disable breakpoints
1. Debug menu
2. Ctrl+Shift+L/Ctrl+Shift+F9

ISE Debugger Commands
Once a breakpoint is reached, the line is highlighted in yellow 
• Check current status of execution 
• Proceed to the next line, or continue to next breakpoint 
• Can step into, over, and out of nested functions or script call

Debug Menu
Step Into (F11)
Step Over (F10)
Step Out (SHIFT+F11)
Continue (F5)

ISE Breakpoints - Variables
#>
Set-StrictMode -Version latest
function Get-LogNN
{
[CmdletBinding()]
Param($log, $count)
# Set breakpoint below. Enabled breakpoint will be highlighted in red. When hit, it will turn yellow. Hover over to see variable value.
Write-Debug "$(Get-Date -DisplayHint Time):Retrieving $count from $log"
Get-EventLog -LogName $log -Newest $count
Get-PSCallStack
} # end function
Get-LogNN -log system -count 2 -Debug
<#
Does not work for:
$_
$input
$PSBoundParameters
$Args
#>
#endregion l3
#region l3
 # Lesson 3: Command-LineDebugging
 <#
    * Full debugging experience in the PowerShell console 
    * Allows debugging of scripts at runtime in production situations without ISE 
    
    For example, if setting a breakpoint on the variable $name 
    * Debugger begins when $name is accessed in any script, command, function or expression in the current session
    
    Example:
    Set-PSBreakpoint -Script .\ScriptHelpExample.ps1 -Variable log -Mode Read

    Debugger Commands
    [DBG]: PS C:\Scripts>> ?
    
    s, stepInto: Single step (step into functions, scripts, etc.)
    v, stepOver: Step to next statements (step over functions, scripts, etc.)
    o, stepOut: Step out of the current functionm script, etc.
    c, continue: continue operation
    q, quit: Stop operation and exit the debugger
    k, Get-PSCallStack: Display call stack
    l, list: List source code from the current script. Use "list" to start form the current line, "list <m>"
        to start from line <m>, and "list <m> <n>" to list <n> lines starting from line <m>
    <enter>, repeat last command if it was stepInto, stepover or list
    ?, h: displays the help message.
 #>

 <#
    Debugging Workflows – Limitations
    * Can view workflow variables, but cannot set from debugger
    * When stopped in debugger Tab completion is not available
    * Works only with synchronous running of workflows from a script, cannot debug workflows that run as a job
    * No nested debugging (e.g. workflow calling workflow, or workflow calling script)
    Console or ISE
 #>
 workflow test-seq 
 {
    parallel 
    {
        sequence 
        {
            Start-Process -FilePath cmd.exe
            Get-Process -Name cmd
        } # end sequence
        sequence 
        {
            Start-Process -FilePath notepad.exe
            Get-Process -Name notepad 
        } # end sequence
    } # end parallel
 } # end workflow
 Set-PSBreakpoint -Script .\WF-TestSequence.ps1 -Line 3
 # Debugging functions: Begin, Process and End blocks. Debugger will automatically break at each section.

 # Debugging functions
 function Test-DebugFunction
 {
    begin 
    {
        Write-Host "Begin"
    } # end begin
    process
    {
        Write-Host "Process"
    } # end process
    end
    {
        Write-Host "End"
    } # end end
 } # end function
 Set-PSBreakpoint -Command Test-DebugFunction
 <#
    Debugging Remote Scripts
    [client]--Enter-PSSession-->[server]
    debug with breakpoints

    If script hits breakpoint, client starts debugger
    If disconnected session is at breakkpoint, Enter-PSSession starts debugger when reconnecting

    Debugging and Scope
    * Breaking into debugger does not change scope
    * Breakpoint in script = script scope
    * Script scope = child of scope in which debugger was run
    * Use Scope parameter of Get-Alias and Get-Variable to find variables and aliases defined in script scope, e.g.:
 #>
 # Returns variables in local (script) scope
 # Useful to find all variables defined in script and sicne debugging started
 Get-Variable -Scope 0
 # Example: Debugging Remote Script
 Enter-PSSession -ComputerName 2012r2-DC
 # [2012r2-DC]: PS C:\> Set-PsBreakpoint -Script .\ScriptEx.ps1 -Line 1
#endregion l3
#region l4
 # Lesson 4: DebuggingCmdlets
 <#
    Turns script debugging features on and off 
    • Sets trace level 
    • Toggles strict mode 
    • Affects global scope
    Set-PSDebug -Off: Turns off all script debugging 
    Set-PSDebug -Step: Steps before each line, user is prompted to: stop, continue, or enter new interpreter level to inspect state of script 
    Set-PSDebug -Strict: Throws exception if a variable is referenced before a value is assigned to it 
    Set-PSDebug -Trace: <int32> Specifies trace level: 
        0 = turns off tracing 
        1 = each line 
        2 = variable assignments, function calls, and script calls
 #>
Set-PSDebug -Trace 1
function Get-LogNN
{
[CmdletBinding()]
Param($log, $count)
# Set breakpoint below. Enabled breakpoint will be highlighted in red. When hit, it will turn yellow. Hover over to see variable value.
Write-Debug "$(Get-Date -DisplayHint Time):Retrieving $count from $log"
Get-EventLog -LogName $log -Newest $count
Get-PSCallStack
} # end function
.\fDebugEx.ps1
<#
Debugging Cmdlets – Set-StrictMode
Set-StrictMode -Version <1 or 2 or Latest>
• Affects only current scope and its child scopes 
• Specifies conditions that cause an error in strict mode 
• Version determines level of enforced coding rules
• Errors when code violates best-practice, i.e. o Reference uninitialized variable 
     Version 1, 2, Latest o Reference non-existent property 
     Version 2, Latest o Incorrectly called function e.g. put arguments in parentheses or, separate arguments using commas 
     Version 2, Latest o Variable w/o a name e.g. ${} 
     Version 2, Latest
Note: ‘Latest’ is strictest version (Useful when new versions are added to PowerShell)

Debugging Cmdlets – Set-StrictMode
Set-StrictMode –Off 
• Turns strict mode off 
• Also turns off "Set-PSDebug -Strict" 
• Uninitialized variables are assumed to have a value of 0 or $null 
• References to non-existent properties return $null 
• Unnamed variables are not permitted

Debugging Cmdlets – Get-PSCallStack
* Data structure with current execution stack
* Designed for use with Debugger (Option k in Breakpoint)
* Use in a script or function outside debugger
#>
function Get-LogNN
{
    [CmdletBinding()]
    Param($log, $count)
    # Set breakpoint below. Enabled breakpoint will be highlighted in red. When hit, it will turn yellow. Hover over to see variable value.
    Write-Debug "$(Get-Date -DisplayHint Time):Retrieving $count from $log"
    Get-EventLog -LogName $log -Newest $count
    Get-PSCallStack
} # end function
Get-LogNN -log system -count 2

<#
Debugging Cmdlets – Trace-Command 
1. Detailed messages about each internal processing step 
2. Traces steps within expressions or commands 
3. Only applies to specified expression or command
-PSHost: Output options
-Debugger: Debugger can be any user-mode or kernel-mode debugger or Visual Studio  
-FilePath: Log file 
-Option: Type of events to trace, E.g. None, Constructor, All, Warning, Error 
-Name: Determines PowerShell components to be traced, Too many to list, and different for each machine
        List with: Get-TraceSource | Sort-Object Name • E.g. parameterbinding, typeconversion, cmdlet
#>
# Example: Trace parameter binding
Trace-Command -PSHost -Expression { Start-Process -FilePath Notepad } -Option All -Name ParameterBinding
#endregion l4
#endregion Section 2: DebuggingYourCode
#endregion Module7-Debugging

#region Module8-IntroductionToDesiredStateConfiguration(DSC)
#region Section 1: Introduction
#region l1
 # Lesson 1: Overview
 <#
 What is Desired State Configuration (DSC)?
    * New management platform in Windows PowerShell 
    * Enables deployment and management of a remote machine’s software and host OS
    * PowerShell language extensions, cmdlets, and resources to declaratively specify state
    * Enforce the desired state and prevent configuration drift
    * No procedural scripting required

Imperative vs. Declarative Language

    Imperative
    Add-WindowsFeature Windows-Server-Backup

    Declarative 
    Configuration BaseBuild 
    { 
        WindowsFeature Backup 
        { 
            Ensure = "Present" Name = "Windows-Server-Backup" 
        } # end resource 
    } # end configuration

When to use DSC?
Automate configuration of a set of computers (target nodes)
* Report desired state
* Repair desired state
Built-In Resources
1. Registry
2. Environment variables
3. Scripts
4. Users and Groups
5. Processes and Services
6. Files and Directories
7. Roles and Features
8. Deploy Software

* Option to create custom resources to configure the state of any application or system setting

What about Group Policy
DSC
+ No domain needed
+ Works with no network at all
+ MOF based (open CIM standards)
+ Resoruces drive scalability
- Not as simple to deploy
+ Authentication flexibility
- Requires PS 4.0+
- Requires PS remoting
- New unknown factor

GPO
- Only works in domain scenario
- Connectivity generally needed
- Born from registry control
+ Fairly easy to setup and deploy
+ Works everywhere
+ Well-known and established

DSC components
1. Configuration
2. Resources
3. MOF Files
4. Local Configuration Manager
5. Optional pull server (Web(IIS) or File(SMB))

DSC Distribution Modes (Push vs. Pull)

1. Authoring
2. Staging
3. Enact (Execute or Apply)

Configuration Script
Defines the desired configuration and separates the configuration logic ("What") from the node data ("Where") 
• Simplifies configuration data reuse 
• Definitions consist of nested hash tables 
• Configuration block (outer wrapper for a complete state) 
• Node blocks (inner wrapper for node(s)) 
• Resource blocks 
• Configuration data
#endregion l1
#region l2
 # Lesson 2: TheConfiguration
 The Configuration
* Declarative end state
* Simpler than a script
* More like an old *.ini
 #>

 Configuration CreatePullServer
 {
    param
    (
        [string[]]$ComputerName = 'localhost'
    ) # end param
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Node $ComputerName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name = "DSC-Service"
        } # end resource

        xDscWebService PSDSCPullServer
        {
            Ensure = "Present"
            EndpointName = "PSDSCPullServer"
            Port = 8080
            PhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbprint = "AllowUnencryptedTraffic"
            ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfiugrationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State = "Started"
            DependsOn = "[WindowsFeature]DSCServiceFeature"
        } # end resource
    } # end node
 } # end configuration
 Set-Location -Path c:\This-is-Where-the-MOFs-Get-Created\
 CreatePullServer -ComputerName WebServer01.contoso.com

#endregion l2
#region l3
 # Lesson 3: Resources
  <#
    DSC Resources

    * Resources implement the configuration
    * Contain the PowerShell code to get to the desired state
    * Configurations generally combine resource settings and dependencies
    * Contained within modules

    Where to get resources
    * Windows PowerShell v4.0 & v5.1 ships with 12 built-in resources
    * Install additional resources from www.powershellgallery.com
    * Create your own custom resources

    Built-in DSC Resources
    1. Archive: Unpacks archive (.zip) files at specific paths 
    2. Environment: Manages system environment variables 
    3. File: Manages files and directories 
    4. Group: Manages local groups 
    5. Log: Logs configuration messages 
    6. Package: Installs and manages Windows Installer and setup.exe packages 
    7. Process: Configures Windows processes 
    8. Registry: Manages registry keys and values 
    9. Role: Adds or removes Windows features and roles 
    10.Script: Runs PowerShell script blocks 
    11.Service: Manages services 
    12.User: Manages local user accounts

    Create Custom Resources
    * Use xDSCResourceDesigner Module (much easier)
    * Create an empty parent module
    * Create resource sub-modules (1 per resource)
    * Standard functions required for each 
        • Get-TargetResource 
        • Set-TargetResource 
        • Test-TargetResource          

    *-TargetResource Functions
    Functions contain PowerShell code necessary to implement the state
    Code will differ based on target technology
    Specific output requirements of each function
    • Get-TargetResource function returns the current state. 
    • Set-TargetResource function sets the system state. 
    • Test-TargetResource function compares the current state to the desired state.
 #>
#endregion l3
#region l4
 # Lesson 4: MOF Files
 # 1. Author configuration
 Configuration SimpleConfig
 {
    $Nodes = '2012r2-ms','2012r2-dc','win8-ws'
    Node $Nodes
    {
        File CreateFolder
        {
            DestinationPath = 'c:\temp'
            Ensure = 'present'
            Type = 'Directory'
        } # end resource
    } # end node
 } # end config

 # 2. Execute Configuration
 SimpleConfig -OutputPath c:\dsc\SimpleConfig

 <#
 Managed Object Format
 * DSC middle man
 * Per node: In Pull mode, node names are abatracted with a GUID
 * Cross platform
 #>
 #endregion l4
#region l5
 # Lesson 5: LocalConfigurationManager(LCM)
 <#
  Local Configuration Manager (LCM)
  Local Configuration Manager is the engine that applies the configuration
  Two ways to apply a configuration to nodes • Manual Push • Automatic Pull
  One configuration per node (v4)
  
  LCM Options
  LCM is confiugred through a DSC configuation (normally pushed once)
 #>
  LocalConigurationmanager
  {
    # Cofiguration to pull
    ConfigurationId = "<guid>"
    ConfigurationModeFrequencyMins = 90
    # ApplyAndAutoCorrect | ApplyAndMonitor | ApplyOnly
    ConfigurtionMode = "ApplyAndAutocorrect"
    RefereshFrequencyMins = 45
    DownloadMangerName = "WebDownloadManager"
    # Push vs. Pull
    RefreshMode = "Pull"
    # Pull Server Location
    DownloadmanagerCustomData =
    (@{ServerUrl="https://$PullServer/psdscpullserver.svc"})
    CertificateID = "<CertID>"
    Credential = $cred
    RebootIfNeeded = $true
    AllowModuleOverwrite = $false
  } # end LCM
#endregion l5
#region l6
 # Lesson 6: ApplyingConfigurations-Push
 <#
 1. Create configuration
 2. Run Configuration to create MOF file(s)
 3. Push confiurttion to target(s)

 Single MOF
 PS> StartDSConfiguration -Path c:\mofs\
 [server1.mof]--ConfigurationPushed-->[Server1]

 Many MOFs
 PS> Start-DscConfiguration -path c:\mofs\
 [server1.mof]--Configuration PUshed-->[server1]
 [server2.mof]--Configuration PUshed-->[server2]
 [server3.mof]--Configuration PUshed-->[server3]
 #>
#endregion l6
#region l7
 # Lesson 7: ApplyingConfigurations-Pull
 <#
    Possible Server Modes 
    • HTTPS Web Server 
    • HTTP Web Server 
    • SMB File Share
    Local configuration manager on target node pulls the configuration

    Overview - Setting up for pull
    1. Create pull server
    2. Create config
    3. Run Config, which creates MOF File(s)
    4. Rename MOFs with GUIDs
    5. Checksum MOFs and Resource Modules
    6. Place MOFs and Modules on Pull Server
    
    [per node]
    1. Configure LCM on targets
    2. Targets pull Config and Apply

    Resources and Clients
    Push Configuration 
    • Resource manually deployed
    Pull Configuration 
    • Pull server stores needed modules 
    • Node downloads modules based on configuration
 #>
#endregion l7
#endregion Section 1: Introduction

#region Section 2: Real-WorldExample
#region l1
 # Lesson 1: Web Site Installating and Configuration (Push)
#endregion l1
#endregion Section 2: Real-WorldExample
<#
    Example 1: Push Mode - Web Site Intallation and Configuration
    0. Preparation: Define goals
    1. Install or Create custom resources (if required)
    2. Define configuration
    3. Create consumable MOF File(s)
    4. Push Configuration to target node(s)

    0. Preparation: Define goals (List settings and desired values)
    Ensure IIS is installed: Yes
    Define Web Server name: Web-Server
    Define DestinationPath: c:\inetpub\wwwroot
    Ensure subdirectories exist: Yes
    Define SourcePath (Path to copy from): Specify with parameter (to make more dynamic)

    1. Create Custom resources (if required)
        * Not required for this example because built-in resources will be used
    2. Define configuration
#>
Configuration MyWebConfig
{
    param ($MachineName, $WebsiteFilePath)
    Node $MachineName
    {
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        } # end resource

        File WebDirectory
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = $WebsiteFilePath
            DestinationPath = "C:\inetpub\wwwroot"
            DependsOn = "[WindowsFeature]IIS"
        } # end resource
    } # end node
} # end config

<#
    3. Create consumable MOF file
        * Run configuration in previous step
        * Create a consumable MOF file
        MyWebConfig -MachineName om12ms -WebsiteFilePath "c:\scripts\inetpub\wwwroot"
        * MyWebConfig directory and 'om12ms.mof' file is created

    4. Push configuration
       Apply MOF File using Push Mode
       Start-DSCConfiguration -Path .\MyWebConfig -Wait -Verbose
       NOTE: The configuration is applied immediately to the target node

       Detecting Configuration Drift
       Compare current and actual configuration
       $Session = New-CimSession -ComputerName "om12ms"
       Test-DscConfiguration -CimSession $session
       * Returns "True" if the configuration matches and "False" if it does not match
#>
#endregion Module8-IntroductionToDesiredStateConfiguration(DSC)
#region Module9-IntroductionToWorkflow
<#
Section 1: Introduction 
• Lesson 1: Overview 
• Lesson 2: Authoring 
• Lesson 3: Activities and Keywords 
• Lesson 4: Workflow Execution 
• Lesson 5: Checkpoints and Failure Recover
#>
#region Section 1: Introduction
#region l1
 # Lesson 1: Overview
 <#
 What is a PowerShell Workflow?
 * Function-like command consisting of an ordered sequence of related activities
 * Can run in parallel
 * Can survive a reboot or failure
 * Can be paused and resumed
 * Looks like PowerShell script

 Based on Windows Workflow Foundation (WF)
    References:
    1. CIMOM: https://docs.microsoft.com/en-us/windows/desktop/WmiSdk/common-information-model
    2. PowerShell Workflow Concepts: https://docs.microsoft.com/en-us/system-center/sma/overview-powershell-workflows?view=sc-sma-1807

    * An extensive product that spans many Microsoft products including Visual Studio and the .NET Framework
    * A mechanism that facilitates running complex activities sequentially or in parallel, with the ability to recover from interruptions
    * Consist of an ordered sequence of related tasks, known as activities
    * Activities are authored in Visual Studio in native Windows Workflow Foundation (WF) Extensible Application Markup Language (XAML) format
    * PowerShell Workflows reap all the benefits, but are authored in PowerShell script.

    Summary of PowerShell Workflow Benefits
    1, Interruptible
        • Disconnection and re-connection 
        • Automated failure recovery (state and data persistence) 
        • Connection and activity retries
    2. Parallelizable
        • Easier to implement than background jobs or runspace pooling
    3. Scalable
        • Leverage the power of the Windows Workflow Foundation (WF) Scalable
    4. Authored using PowerShell Syntax
        • PowerShell converts syntax to WF XAML format 
        • WF native language supports scalable and remote, multi-device management 

    Workflow Prerequisites
    1. PowerShell v3.0+ installed on local workflow host (in-process)
    2. PowerShell v3.0+ installed on remote workflow host (out-of-process)
    3. Enable PowerShell Remoting for remote workflow execution Also required if running workflow locally in a workflow session
    4. Import PSWorkflow module to access workflow help topics

    Workflows Consist Of:
    1. [trigger client] Client computer, which triggers the workflow
    2. [execution host] Local or Remote Session to Run the Workflow
    3. [managed nodes] Managed nodes target computers affected by the workflow activities

    Execution Models
    1. Out-Of-Process
        a. [trigger:workflow-client]-->[host:workflow-server]-->[managed-nodes]
        b. [trigger:workflow-client]-->[host:workflow-server+managed-nodes]
    2. In-Process
        a. [trigger:workflow-client+host:workflow-server]-->[managed-nodes]
        b. [trigger:workflow-client+host:workflow-server+managed-nodes]
    3. Role minimum requirments
        a. [trigger:workflow-client] PowerShell 2.0 + .NET Framework 2.0
        b. [host:workflow-server] PowerShell 3.0 + .NET Framework 4.0
        c. [managed-node] PowerShell 3.0 + .NET Framework 4.0

    In-Process Workflow Architecture
    1. Workflow Engine runs locally within the PowerShell host 
    2. Workflow stops when its host process is terminate

    Out-of-Process Workflow Architecture
    1. Workflow engine executes in a remote workflow session 
    • Client connects to Microsoft.PowerShell.Workflow session configuration on workflow host 
    • Client can disconnect without disrupting workflow

    Functions vs. Workflows
    1. Serial execution | Parallel execution
    2. Run to completion and return | Can be paused, stopped and restarted
    3. State is lost during an unexpected outage | State is maintained, if requested, and is recoverable after outage
    4. Run in the PowerShell Host engine context | Run inthe Windows Workflow engine context
    5. Logging & recovery implemented by author | Logging and recovery are included
    6. Commands, functions and cmdlets run in the same environment | Each activity executes in its own environment
    7. Must be executed remotely using PowerShell remoting | Remote execution is available using -PSComputerName WCP
 #>
#endregion l1
#region l2
 # Lesson 2: Authoring
 <#
    Authoring a Workflow
    <workflow keyword>:<Command Keyword><Common Parameters>
    <Activities/Core Cmdlet/Workflow Script>:<Parallel><ForEach -Parallel><Sequence><Activity Common Parameters>

    Workflow Syntax
    Uses the same syntax as a Windows PowerShell function 
    Supports common function parameters & CmdletBinding 
    Allows workflow common parameters to be specified
 #>
 # Workflow Syntax
 workflow Test-Workflow
 {
    [CmdletBinding()]
    param 
    (
        [Parameter()]$Param1
    ) # end param
    # [<Activity1>]
    # [<Activity2>]
    # ...
 } # end workflow
 <#
    Workflow Common Parameters
    * Available on all workflows and activities 
    * Parameters must be named and not used positionally 
    * Used to configure connection environment

    1. PSParameterCollection
    2. PSConnectionRetryIntervalSec
    3. PSAuthentication
    4. PSUseSSL
    5. PSSessionOption
    6. JobName
    7. PSConnectionRetryCount
    8. PSComputerName *
    9. PSRunningTimeoutSec
    10.PSAuthenticaionLevel
    11.PSConfigurationName
    12.PSCertificateThumbprint
    13.PSPersist *
    14.PSPort
    15.PSCredential
    16.PSElapsedTimoutSec
    17.PSApplicationName
    18.PSConnectionURI
    19.PSPrivateMetadata
    20.PSAllowRedirection
    21.AsJob

    Important Parameters
    * PSPersist - Force workflow to checkpoint workflow state and data after each activity
    * PSComputerName - A list of computers to run workflow against

    Process to Design a Workflow
    Q: Can the task be performed using simpler methods, such as Functions, Remoting or Jobs? 
    1. List Tasks to perform 
    2. Organize Tasks into Activities 
        a. Each activity should use a PowerShell cmdlet or custom function 
        b. Add a Checkpoint after each step 
    3. Identify Sequential Tasks 
    4. Identify Parallel Tasks 
        a. Identify child commands that must be executed sequentially
 #>
#endregion l2
#region l3
 # Lesson 3: ActivitiesAndKeywords
 <#
    Workflow Activities
    Basic unit of workflow 
        • A workflow is composed of one or more activities 
        • Activities run independently of one another 
        • Allows for sequential and parallel execution 
        • Workflows can be nested
    Two groups of activities 
    • Core cmdlet activities 
    • Workflow script activities
 #>
 # Example: Single Activity Workflow
 # Define a workflwo with only one activity
 workflow SingleActivity-WF 
 {
    # Activity 1
    Start-Process -FilePath $env:SystemRoot\notepad.exe
 } # end workflow
 # Run workflow
 Single-Activity-WF
 # Check the type of command
 Get-Command -Name SingleActivity-WF
 
 # Example: Multiple Activity Workflow
 # Define a workflow containing two activities
 workflow MultiActivity-WF
 {
    # Activity 1
    Start-Process -FilePath $env:SystemRoot\notepad.exe
    # Activity 2
    Get-Process -Name notepad
 } # end workflow
 # Run worfklow - Eachactivity runs independently of the other!
 MultiActivity-WF
 <#
    Core Cmdlet Activities

    Core Modules Containing Cmdlet Activities
    Core cmdlets have been packaged as workflow activities 
    • Some cmdlets have been excluded
    All activities are executed within their own workflow session 
    • If an activity matching the cmdlet name is not found, the command is run using the InlineScript Activity

    Core Modules Containing Cmdlet Activities
    • Microsoft.PowerShell.Core (PSSnapin) 
    • Microsoft.PowerShell.Host 
    • Microsoft.PowerShell.Diagnostics 
    • Microsoft.PowerShell.Management 
    • Microsoft.PowerShell.Security 
    • Microsoft.PowerShell.Utility 
    • Microsoft.Wsman.Management
   
    Acitivity Common Parameters
    * Override workflow common parameters
    * Available on InlineScript activity and cmdlets implemented as activities
    1. AppendOutput
    2. PSDesiableSerialization
    3. ErrorAction
    4. PSPort
    5. PSActionRetryCount
    6. PSRemotingBehavior
    7. PSApplicationName
    8. PSUseSSL
    9. PSConnectionURI
    10.PSDebug
    11.DisplayName
    12.PSPersist
    13.MergeErrorToOuput
    14.PSProgressMessage
    15.PSActionRunningTimeoutSec
    16.PSSessionOption
    17.PSCertificateThumbprint
    18.WarningAction
    19.Debug
    20.PSError
    21.Input
    22.PSProgress
    23.PSActionRetryIntervalSec
    24.PSRequiredModules
    25.PSAuthentication
    26.PSVerbose
    27.PSCredential
    28.PSComputerName
    29.PSWarning
    30.PSConfigurationName
    31.Result
    32.PSConnectionRetryCount
    33.UseDefaultInput
    34.PSConnectionRetry-IntervalSec
    35.Verbose
 #>
 # Example: Core cmdlet as activity and activity common parameters
 Get-Process -
 workflow Core-CmdletWF
 {
    # Activity common parameters
    Get-Process - 
 } # end workflow

 # Example: Core cmdlet not packaged as a workflow activity
 Workflow SimpleWF
 {
    Write-Host "Starting workflow..." -ForegroundColor Green
 } # end workflow
 <#
    Workflow Activities and Keywords
    1. InlineScript: Executes 'standard' cmdlets in separate PowerShell runspace
    2. Sequence: Control order of execution of multiple activities
    3. Parallel: Run multiple activities in parallel
    4. ForEach -Parallel: Iterate through a collection and execute each item in parallel
    5. Checkpoint-Workflow: Create on disk representation of workflow state
    6. Suspend-Workflow: Resumed using standard *-Job cmdlets
    7. Get-PSWorkflowData: Return workflow common parameters
    8. Set-PSWorkflowData: Used to modify workflow common parameters
 #>
 <#
    InlineScript Keyword 
    * Executes a script block within a workflow as a regular script 
    * Only valid when declared within a workflow 
    * Useful for calling .NET methods (which is not possible in a native workflow activity) 
    * Runs in its own process 
        - Unless InlineScript value removed from session configuration OutOfProcessActivity property 
        - Workflow features & variables are not inherited 
        - $Using scope variable is supported
    Syntax
    InlineScript
    {
        <ScriptBlock>
        <ActivityCommonParameters>
    } # end InlineScript
 #>

 # Example: Call .NET method in a workflow using InlineScript
 # Define a worfklow that calls a .NET method - without using an InlineScript block
 workflow DotNetMethod
 {
    # Method invocation is not supported in a Windows PowerShell Workflow. 
    # To used .NET scripting, place your commands in an inline script: InlineScript {<commands>}.
    # FullyqualifiedErrorId: MethodInvocationNotSupported
    (Get-Service -Name BITS).Stop()
 } # end workflow

 # Example: Call .NET method in a workflow using InlineScript
 # Define a workflow that calls a .NET method - within an InlineScript block
 workflow DotNetMethod
 {
    InlineScript 
    {
        (Get-Service -Name BITS).Stop()
    } # end InlineScript
 } # end workflow
 # Run workflow
 DotNetMethod

 <#
    Parallel Activity
    * It is possible to run activities in Parallel 
    * Performance benefit Only valid when declared within a workflow 
    * Command execution runs in arbitrary order
    Parallel 
    { 
        [<Activity>] 
        [<Activity>] 
        ... 
    }  # end parallel

    Sequence Activity
    * Forces commands to run in order within a Parallel script block 
    * Only valid when declared within a workflow
    Sequence activity 
    Sequence 
    { 
        [<Activity1>] 
        [<Activity2>] 
        ... 
    } # end sequence
 #>
# Example 1: Parallel and Sequential Execution
workflow test-seq
{
# Script block execute in parallel
# Individual activities execute in order
parallel
{
    sequence 
    {
        Start-Process -FilePath cmd.exe
        Get-Process -name cmd
    } # end sequence
    Sequence
    {
        Start-Process -FilePath notepad.exe
        Get-Process -Name notepad 
    } # end sequence
} # end parallel
} # end workflow

# Example 2: Multiple Activities with Parallel and Sequential Tasks
workflow Test-Workflow
{
    Get-Service -Name Dhcp # workflow activity
    Get-WindowsFeature -Name RSAT # Automatic InlineScript Activity
    # Script block execute in parallel
    # Individual activities execute in order
    parallel
    {
        sequence 
        {
            Stop-Service -name dhcp
            Start-Service -name dhcp
        } # end sequence
        Sequence
        {
            Stop-Service -name bits
            Start-Service -name bits
        } # end sequence
    } # end parallel
} # end workflow
<#
ForEach –Parallel Activity
* Collection items can also be processed in Parallel 
* Only valid when declared within a workflow 
* Commands in the Script Block are run Sequentially 
* ThrottleLimit parameter (v4.0) allows throttling the number concurrent of connections (32 is the default)
# -Parallel Parameter 
ForEach -Parallel ($<item> in $<collection>) 
{ 
    [<Activity1>] 
    [<Activity2>] 
    ... 
} # end foreach  
#endregion l3
#region l4
 # Lesson 4: WorkflowExecution
 Controlling a workflow
[Controlling execution]Execute, Suspend, CheckPoint, Resume
[Workflwo Cmdlets]New-PSWorkflowSession, New-PSWorkflowExecutionOption, Invoke-AsWorkflow
#>
# Execute as Workflow (In-Process)
# Workflows are called by name like a function
# In-Process execution is launched in current local PowerShell session
Worflow Test-Workflow
{
    Get-Process -Name System
} # end workflow
Test-Workflow
<#
Workflow Cmdlets
Run any command or expression as a simple workflow 
* Invoke-AsWorkflow
Create workflow session on Workflow Server Role (same or different machine) 
Cmdlet is basically a New-PSSession against the ‘Microsoft.PowerShell.Workflow’ endpoint 
* New-PSWorkflowSession 
Once the session is established, the workflow is invoked in the session like an in-process workflow
Customize workflow session endpoint 
Creates a new PSWorkflowExecutionOptionobject 
* New-PSWorkflowExecutionOption

Execute a Workflow (Out-of-Process)
Out-of-Process execution is launched in a dedicated PowerShell Session 
• Same computer 
• Different (remote) computer
When launching out-of-process on another machine 
• Workflow must exist on that machine 
• Typically deploy module containing the workflow 
• For simple workflows, define then execute
#>
# Example: Executing Out-Of-Process Workflow
$workflow = { Workflow Test-Workfllow {Get-Process -Name system} }
# Establish a remote workflow session
$wfs = New-PSWorfklowSession -ComputerName 2012r2-ms
# Define the workflow in the session (local or remote)
Invoke-Command -Session $wfs -ScriptBlock $Workflow
# Execute the workflow in the session (local or remote)
Invoke-Command -Session $wfs -ScriptBlock { Test-Workfllow -PSPersist $true }

# Example: Initiating Wrokflow from PSv2.0+ on PSv3.0+ Workflow host
$serverList = Get-ADCompuer -Filter * | Select-Object -ExpandProperty Name
$wfs = New-PSSession -ComputerName 2012r2-ms -ConfigurationName Microsoft.PowerShell.Workflow
# Invoke command in the workflow session on remote host
Invoke-Command -Session $wfs -ScriptBlock {
    myWorkFlow -PSComputerName $using:serverList
} # end scriptblock
#endregion l4
#region l5
 # Lesson 5: CheckpointsAndFailureRecovery
#endregion l5
#endregion Section 1: Introduction
<#
Checkpointing Workflows
A checkpoint is a snapshot of the workflow execution state 
• Variables, Data, Output Used to save state after expensive operations 
Avoids re-executing previous code in the event of crash 
Saved to the machine hosting the workflow session, not on the targets nodes or the out-of-process initiating workflow client system.
Default Location 
• c:\Users\<username>\AppData\Local\Microsoft\Windows\PowerShell\WF\PS\default\<user SID

Checkpoint-Workflow 
* Keyword only valid inside workflows 
* Creates a checkpoint at that moment 
* Cannot be placed within an InlineScript block 
* No parameters (common or otherwise)
#>
Workflow Get-FileData
{
    $LargeResultes = Get-CimInstance -ClassName CIM_DataFile
    # Save workflow after larger WMI query
    Chekpoint-Workflow
    ForEach -parallel ($item in $largeResults)
    {
        [PSCustomObject]@{FileName=$Item.Name; FilePath=$Item.Path}
    } # end foreach
} # end workflow
<#
Workflow Common Parameter -PSPersist
PSPersist workflow common parameters:
* $True: Automatically creates checkpoint after every single activity
* $False: Checkpoints only when explicitly specified in workflow (Checkpoint-Workflow)
#>
Invoke-Command -Session $wfs -ScriptBlock { Test-Workflow }
Invoke-Command -Session $wfs -ScriptBlock { Test-Workflow -PSPersist $true }
<#
    Activity Common Parameter -PSPersist
    * Creates a checkpoint after that activity completes
    * Not valid on expressions or commands in an InlineScript block
    * $True: Adds checkpoint after activity completes
#>
# Example
Workflow Test-Workflow
{
    Get-Process -Name wsmprovhost -PSPersist $true
} # end workflow
<#
    Controlling Workflow Execution – $PSPersistPreference Variable
    * Toggles automatic checkpointing
    * If $True, checkpoint will be created after each activity (same as –PSPersist $True)
#>
# Example 
Workflow Test-Workflow 
{ 
    $WinRm = Get-Service Winrm 
    $PSPersistPreference = $true 
    $Assets = InlineScript {\\Server\Share\Get-Data.ps1} 
    # Activities... 
    $PSPersistPreference = $false 
    Parallel 
    {
        # Activities...
    } # end parallel
<#
    Recovering from Failures
    * Must utilize checkpoint(s)
    * If Workflow host crashes, workflow becomes a suspended workflow job
    * Resume-Job will manually resume the workflow from the last checkpoint
    * Can create a scheduled job (on startup) to automatically resume suspended workflows
        • Restart-Computer –Wait - on remote nodes will automatically resume on node
        • On workflow host, workflow will gracefully checkpoint, and must be resumed
    
    Controlling Workflow Execution – Suspend-Workflow
    Suspends workflow from within Checkpoint created before suspension Resume same as recovering from failure
#>
# Example 
workflow Test-Suspend 
{ 
    $a = Get-Date Suspend-Workflow 
    (Get-Date) - $a 
} # end workflow

# NOTE: A workflow cannot be resumed from within the workflow iteself
<#
    Controlling Workflow Execution – Checkpoints
    * Checkpoint on a set of activities in a pipeline is not taken until pipeline completes
    * Checkpoints on activities in a Parallel script block are not taken until Parallel script block has run on all target computers 
    * Checkpoints on activities in a Sequence script block, are taken after each activity completes on the target computers
#>
#endregion Module9-IntroductionToWorkflow

#region CONCLUSION:PowerShellBestPractices
#region Section 1: Scripts
<#
1. Write your code for someone else to read
2. Comment your code where warranted
3. Add help documentation to your script or function, with examples
4. Use native PowerShell, rather than equivalent external commands
5. One function implements one task (Verb-Noun)
6. Expand all aliases
7. Let the ISE expand the Cmdlet (using <TAB>) for spelling and correct case
8. Use code-signing for production scripts
9. Invoke-Expression can be used for code-injection, so use carefully
10.Declare all variables in scope before use
11.Use the Module concept to group related functions into a single suite
#>
#endregion Section 1: Scripts
#region Section 2: Pipeline
<#
1. Filter to the left, format to the right
2. Accept input from the pipeline and send output to the pipeline
#>
#endregion Section 2: Pipeline
#region Section 3: Functions
<#
1. Use named parameters (avoid positional parameters)
2. Include [CmdletBinding()] to enable common parameters. Requires a Param() statement
3. Use Write-Verbose, Write-Error and Write-Debug cmdlets to leverage Cmdlet binding 
4. Use [OutputType()] in your functions (enables IntelliSense)
5. If a parameter refers to a file path, name the parameter PATH or use an alias of PATH 
6. Name your parameters using the existing cmdlet naming conventions.
7. Assign default values to function parameters
8. Specify validation attributes for function parameters  
9. Use Out-* and Write-* cmdlets properly. Write-Host only emits to the host application
10.Make use of switch parameters to enact different behaviours
11.Implement –WhatIf for dangerous choices
#>
#endregion Section 3: Functions
#region Section 4: Errors
<#
1. Ensure you have error handling in place
2. Use try{} catch{} finally{} blocks rather than $errorActionPreference
3. Avoid single empty catch-blocks
#>
#endregion Section 4: Errors
#endregion CONCLUSION:PowerShellBestPractices
#endregion DAY-03

#region APPENDIX

#region AppendixA:PowerShellAndTheWeb

#region Section 1: WebAccess
 # Lesson 1: PowerShellWebAccess
#endregion Section 2: WebAccess

#region Section 1: WebServices
 # Lesson 1: PowerShellWebServices
#endregion Section 2: WebServices

#region Section 1: WebCmdlets
 # Lesson 1: WebCmdlets
#endregion Section 2: WebCmdlets

#endregion AppendixA:PowerShellAndTheWeb

#region AppendixB:Jobs
#region Section 1: BackgroundJobs
 # Lesson 1: Local
  <#
    What are Background Jobs?
    * PowerShell work running in the background 
    * Multiple jobs can be started 
    * Jobs created by Start-Job cmdlet or –AsJob parameter (some cmdlets)
    
    Sample List of Core Cmdlets that Support –AsJob Parameter
    * Get-WmiObject
    * Invoke-WmiMethod
    * Restart-Computer
    * Stop-Computer 
    * Invoke-Command 
    * Remove-WmiObject
    * Set-WmiInstance
    * Test-Connection
    The full list can be obtained using the expression:
    Get-Command -ParameterName AsJob

    Job Throttling and Queuing
    * Cmdlets with –AsJob Parameter
    * –ThrottleLimit parameter handled automatically (default value is 32)
    * Start-Job starts a single job only
    * When Start-Job leveraged, throttling and queuing completely manual
 #>
 
 # Starting and Viewing Existing Background Jobs
 # Start-Job
 Start-Job -ScriptBlock { dir -path c:\windows -recurse }
 Start-Job -FilePath c:\scripts\sample.ps1 
 Invoke-Command -computername s1 -ScriptBlock { Get-EventLog -LogName System } -AsJob
 
 # Get-Job
 Get-Job
 # Retrieving Job Output
 # * Recieve-Job gets job results (or partial results if the job is incomplete)
 Start-Job -ScriptBlock { Get-Process -Name svc*}
 Receive-Job -id <id> | Format-List -Property cpu
 # * Receive-Job -Keep prevents deletion of the job results so that these results are still avaible for any subsequent retrievals
 
 # Job Management
 Wait-Job
 # * Suppresses the PowerShell prompt until the job is complete
 
 # Stop-Job
 Get-Job -Name n* | Stop-Job 
 Stop-Job -Name *

 # Remove-Job
 # * The job must be stopped before it can be removed
 # Lesson 2: Remote
    <#
        Invoke-Command with -AsJob
        * Invoke-Command supports –AsJob for remote background jobs
        * One local job created
        * Child jobs created for each remote machine used with Invoke-Command
        * Use –ThrottleLimit param for queueing and throttling (default value is 32)
        * Use same job management cmdlets as local jobs once jobs exist • Receive-Job, Remove-Job, Wait-Job, Stop-Job, etc
    #>
#endregion Section 1: BackgroundJobs
#region Section 2: JobScheduling
 # Lesson 1: PSScheduledJobModule
 <#
    Overview
    • Scheduled jobs are a combination of PowerShell jobs and the Windows Task Scheduler 
    • Jobs run asynchronously in the background 
    • Jobs include a rich job triggering mechanism 
    • Scheduled jobs can be run as a different user account 
    • The PSScheduledJob module includes 16 cmdlets 
    • Jobs can be managed using the *-Job cmdlets

    Job Triggers
    * Start jobs on a schedule
    * A job trigger reference is stored in a job object property
    * Each job supports multiple triggers
    
    File Persistence
    * Jobs, job triggers and job options are stored as XML
    * Job instance output is stored as XML
    * Jobs are created and stored per user
    
    Job Options
    * Define conditions for starting and running the jobs
    * A job option reference is stored in a job object property
    
    Job Module
    * PSScheduledJob module
    * Only available in PowerShell 3.0
    * Module must be loaded to manage instances using *-Job cmdlets

    Scheduled Job Object Relationships
    [ScheduledJobDefinition].Options[ScheduledJobOptions] | .JobTriggers[ScheduledJobTrigger]
    [ScheduledJobOptions].JobDefinition[ScheduledJobDefinition]
    [ScheduledJobTrigger].JobDefinition[ScheduledJobDefinition]
 #>
 # Lesson 2: Cmdlets
 <#
    Scheduled Job Cmdlets

    [ScheduledJobDefinition]
    * Register-ScheduledJob
    * Unregister-ScheduledJob
    * Enable-ScheduledJob
    * Disable-ScheduledJob
    * Get-ScheduledJob
    * Set-ScheduledJob

    [ScheduledJobOption]
    * New-ScheduledJobOption
    * Get-ScheduledJobOption
    * Set-ScheduledJobOption

    [ScheduledJobTrigger]
    * Add-JobTrigger
    * Remove-JobTrigger
    * Enable-JobTrigger
    * Disable-JobTrigger
    * New-JobTrigger
    * Get-JobTrigger
    * Set-JobTrigger
 #>
 # Example: Creating new scheduled Jobs and triggers
 # 1. Create a scheduled Job
 Register-ScheduledJob -Name PSJob1 -ScriptBlock { dir c:\ }
 # 2. Create Job Trigger Objects
 $trigger1 = New-JobTrigger -At (Get-Date).AddMinutes(10) -Once 
 $trigger2 = New-JobTrigger -At 3pm -Weekly -DaysOfWeek Monday
 # 3. Associate a Job Trigger Object with a new Job
 Register-ScheduledJob -Name PSJob2 -FilePath $home\script.ps1 -Credential (Get-Credential) -Trigger $trigger2
 # 4. Associate a Job Trigger Object with an existing Job
 Add-JobTrigger -Name PSJob1 -Trigger $trigger1
 <#
    PowerShell Scheduled Jobs in Task Scheduler
    * PowerShell Scheduled Jobs can be viewed in the Task Scheduler GUI 
        • Only jobs in path Microsoft\Windows\PowerShell\ScheduledJobs can be created and managed using PowerShell Scheduled Jobs
        • Use ‘ScheduledTasks’ module to manage all other scheduled tasks (Only available in Windows 8 and Server 2012 and later)
 #>
 # Manage Existing Scheduled Jobs
 # List (current user only)
 Get-ScheduledJob -Name PSJob1
 # Modify
 Get-ScheduledJob -Name PSJob1 | Set-ScheduledJob -ScriptBlock { Get-Process } -RunAs32
 # Disable
 Disable-ScheduledJob -Name PSJob3
 # Enable
 Enable-ScheduledJob -Name PSJob3
 # Delete
 Unregister-ScheduledJob -Name PSJob3
 # Managing Job Triggers
 # List All Job Triggers on a job
 Get-JobTrigger -Name SJob2
 # Modify Single Job Trigger by ID (numbers match trigger creation order)
 Get-JobTrigger -TriggerId 1 -Name SJob2 | Set-JobTrigger -AtStartup -RandomDelay (New-TimeSpan -Minutes 5)
 # Disable All Triggers on a Job
 Get-JobTrigger -Name SJob2 | Disable-JobTrigger
 # Enable One Trigger on a Job
 Get-ScheduledJob -Name SJob | Get-JobTrigger -TriggerId 1 | Enable-JobTrigger 
 # Delete All Job Triggers on a Job
 Get-ScheduledJob -Name SJob2 | Remove-JobTrigger

 # Configuring Job Options
 # Set advanced options for running a job
 # Create Job Option Object
 $option = New-ScheduledJobOption -RunElevated -IdleTimeout 00:05:00 -MultipleInstancePolicy Queue
 # Create Scheduled Job with Opiton Object
 Register-ScheduledJob -Name SJob1 -ScriptBlock { dir c:\ } -ScheduledJobOption $option
 # Display Job Options
 Get-ScheduledJobOption -Name SJob1
 # Modifying Job Options
 Get-ScheduledJob -Name SJob1 | Get-ScheduledJobOption | Set-ScheduledJobOption -RequireNetwork -HideInTaskScheduler

 # Managing Job Instances
 # PSScheduledJob module MUST be loaded
 # Manage Job instances with *-Job cmdlets
 # Listing Scheduled Job Instances
 Get-ScheduledJob # Auto-Imports Module
 Get-Job SJob5 | Format-Table -Property ID, Name, PSBeginTime
 # Job output is saved to disk in an XML file -Keep is requried to access results multiple times
 # Receiveing Job Output
 Receive-Job -Id 6 -Keep

 # Job Definition & Job Output Storage
 # $home\AppData\Local\Microsoft\Windows\PowerShell\ScheduledJobs\<Jobname>\ScheduledJobDefinition.xml
 # $home\AppData\Local\Microsoft\Windows\PowerShell\ScheduledJobs\<Jobname>\Output\
 # $home\AppData\Local\Microsoft\Windows\PowerShell\ScheduledJobs\<Jobname>\<Job Instance Date stamp>\
 # $home\AppData\Local\Microsoft\Windows\PowerShell\ScheduledJobs\<Jobname>\<Job Instance Date stamp>\Results.xml
 # $home\AppData\Local\Microsoft\Windows\PowerShell\ScheduledJobs\<Jobname>\<Job Instance Date stamp>\Status.xml
#endregion Section 2: JobScheduling
#region Section 3: JobsAndWorkflows
 # Lesson 1: RunningWorkflowsAsBackgroundJobs
 <#
    Running Workflows as Background Jobs
    • Use the –AsJob workflow common parameter 
    • Manage workflows using the *-Job cmdlets
 #>
 # Run local workflow on remote machines as a job
 $myWfJob = myWorkFlow -PSComputerName $hostlist -AsJob
 Get-Job
 Receive-Job -Job $myWfJob
#endregion Section 3: JobsAndWorkflows
#endregion AppendixB:Jobs

#region AppendixC:DSCCustomResources

#region Section 1: Introduction
 # Lesson 1: Custom Resources
#endregion Section 1: Introduction

#endregion AppendixC:DSCCustomResources

#endregion APPENDIX

#region ATTENDEE QUESITONS TO RESEARCH
<#
#>
#endregion AQTR