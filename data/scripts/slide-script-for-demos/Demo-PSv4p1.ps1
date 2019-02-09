#requires -version 4.0
#requires -RunAsAdministrator
<#
****************************************************************************************************************************************************************************
PROGRAM		: Demo-PSv4p1.ps1
SYNOPSIS	: To demonstrate various features of PowerShell v4.0
DESCRIPTION	: This master script contains a collection functions or snippets that shows how certain features of PowerShell 4.0 can be used for a variety of scenarios.
REQUIREMENTS: 
LIMITATIONS	: Script samples are based on WMF 4.0 DSC (not WMF 5.0) resources
AUTHOR(S)	: Preston K. Parsard
EDITOR(S)	: Preston K. Parsard
REFERENCES	: https://github.com/PowerShell/PowerShell
KEYWORDS	: DSC
DISCLAIMER  : THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
            : INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, 
            : royalty-free right to use and modify the Sample Code and to reproduce and distribute the Sample Code, provided that You agree: (i) to not use Our name, 
            : logo, or trademarks to market Your software product in which the Sample Code is embedded; 
            : (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, 
            : and defend Us and Our suppliers from and against any claims or lawsuits, including attorneysâ€™ fees, 
            : that arise or result from the use or distribution of the Sample Code.
****************************************************************************************************************************************************************************
#>

<# WORK ITEMS
TASK-INDEX: 000
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
# 10 NOV 2015  00.00.0001 Preston K. Parsard prestopa@microsoft.com Initial release

# INTRODUCTIONS
<#
0. About Me
a. Preston K. Parsard, Brunswick, MD
b. Been in industry 14 years, primarily focused on Windows Technologies
c. Retired from the Army in 2014 (24 yrs of service)
d. Love to script, favorite technology in Windows (automation). 

1. Name:
2. Company Affiliation:
3. Title/Fucntion/AOR
4. Product Experience
5. Expectations for this course
SCHEDULE
Start: 08:00 
Break: 10:00
Lunch: 12:30
Break: 14:45
End:   17:00 

LAB ENVIRONMENT
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


# MODULE 01
#region Module1-Introduction.ModuleOverview
# Section1
# * What is a shell?
# * PowerShell Introduction
# Section 2: PowerShell Features
# * Command-Line Interface (CLI)
# * Scripting Language
# * Interactive Scripting Environment (ISE)
# * PowerShell Web Access (PSWA)
# * PowerShell Workflow Overview
# * Desired State Configuratin (DSC) Overview

# Module1-Introduction.Section1-Shell.Lesson1-What is PowerShell?

# What is a shell?
# * Software enabling OS and Applicaition access through interactive commands or batches of commands (scripts)

# Module1-Introduction.Section1-Shell.Lesson2-PowerShellIntroduction

<#
After this lesson, you will:
* Be able to describe PowerShell, its evolution and availability
* Understand the system requirements for PowerShell v4
* Know how to install PowerShell

What is PowerShell?
*Automation engine
*Command-line Shell
*Scripting Language
*Development Framework:
 -Integrated Scripting Environment
 -PowerShell Embeddd in Host Applications

PowerShell Evolution
2005: Code name - Monad
2006: v1.0 - 130 cmdlets
2008: v2.0 - 230 cmdlets, backward-compatible, Integrated Scripting Environment, Remoting
2012: v3.0 - >2,300 cmdlets, backward-compatible, WinPE, WebAccess, Enhanced ISE, Workflow
2013: 2012R2 4.0 - > >2,300 cmdlets, backward-compatible, DSC

PowerShell default availability
*Windows PowerShell is a Windows Feature
*Windows PowerShell 4.0: Windows 8.1, Windows Server 2012 R2

*Windows PowerShell 3.0: Windows 8, Windows Server 2012
*Windows Powershell 2.0: Windows 7, Windows Server 2008 R2

*Windows PowerShell 1.0: Windows Server 2008

Installing PowerShell versions
*WMF: Windows Management Framework - Grouping of several management related tools such as PowerShell, BITS, and the WinRM service

System Requirements WMFv4.0
*.Net Framework 
 -v4.5
*OS
 -Windows 7 SP1
 -Windows Server 2008 R2 SP1
 -Windows 8.1
 -Windows Server 2012 or 2012 R2
*Other
 -WMI
 -WinRM
 -Server Manager
 -CIM Provider (Included in Windows or WMF)

Known Incompatibilities WMFv4.0
*SCCM 2012 (not including SP1)
*SCVMM 2008 R2 (including SP1)
*MS Exchange Server 2007, 2010 & 2013
*MS SharePoint Server 2010 & 2013

PowerShell 4.0 in Server Core
*Server Core starts in CMD Console upon local logon or RDP connection
*ISE feature not available
*PowerShell 2.0 Engine not enabled by default

Windows Server 2012R2
*Installed  by default

Windows Server 2012
*Install Net 4.5 pre-requisite
*Install Windows Management Framework 4.0 

Windows Server 2008R2
*Install .Net 4.5 pre-requisite
*Install Windows Management Framework 4.0

Enabling PowerShell on Server Core is easy. 

For 2008R2 Core, there is an intermediate helper tool. It is called SCONFIG.CMD or “Server Configuration Tool”.
Simply run it from CMD, and choose the options described : 4 (“Configure remote management features”), then 2 (“Enable Windows PowerShell”), and finally restart the computer.
To execute PowerShell, run it from a CMD.EXE or launch TaskExplorer (Ctrl-Esc) and execute “Run” in the menu. The needed executable continues to be PowerShell.exe
Using Windows 2008 R2 and Windows 2012 is recommended rather than Windows 2008.

Core on Server 2012, PowerShell is ready-to-use, just type “PowerShell” at the cmd prompt.
#>

<#
Module1-Introduction.Section2-PowerShellFeatures.Lesson1-PowerShellHosts

After this lesson, you will be introduced to the command-line interface feature of PowerShell
Command-Line Interface (CLI)
*Interactive mode
*Sample commands to interact with applications and the operating system
*Handy shorcut keys: HOME, END, F&, arrows, CTRL+arrows
#> 
Get-Process

<#
Module1-Introduction.Section2-PowerShellFeatures.Lesson2-ScriptingLanguage

After this lesson, you will:
* Be introduced to the scripting feature of PowerShell

Scripting Language: Interactive Commands batched together
* Automation
* Disaster Recovery
* High Availability
* Deployment
* Auditing
* Health Check
* Monitoring
* Reporting
* GUI over PowerShell
#>

<#
Module1-Introduction.Section2-PowerShellFeatures.Lesson3-IntegratedScriptingEnvironment

Anatomy of the ISE
1. PowerShell tabs
2. Scripts open within a tab
3. Console pane
4. Script pane
5. Show-Command add-on

Integrated Scripting Environment (ISE)
* Development Tool
* Graphical Editor
* Execution and Debugging
* Windows 8.1 / Server 2012 Start Screen Tile
* Taskbar title
See get-help about_Windows_PowerShell_ISE  to get complete information about its features.
ISE has also some limitations :
It can’t emulate a previous version. You can’t provide a -Version X parameter to it.
#>

<#
Module1-Introduction.Section2-PowerShellFeatures.Lesson4-PowerShellWebAccess(PSWA)

PowerShell Web Access will be covered in detail in PowerShell v4.0 for Administrators Part 2

After this lesson, you will: Be introduced to the web access feature of PowerShell

PowerShell Web Access
1. Windows PowerShell console hosted in IIS: PowerShell console in any modern browser
2. Access the PowerShell console securely (HTTPS) through any browser from any OS: Built for tablets and mobile devices as well as PCs
3. Targets a remote internal computer specified at sign-in
4. Provides access to PowerShell from anywhere
5. Gateway hosted on Perimeter network (PSWAG)
6. Gateway can also be hosted on internal network for internal browser-based access
7. Cross-platform support:  such as Firefox, Safari, Chrome, Unix, Linux, OSX (anything that talks HTTPS)
8. Included with Server 2012 at no extra cost or license
9. PSWA role can only be installed on Server 2012/2012 R2
10.Automatically installs and configures IIS 8.0 Web Role
11.Gateway can be Internet or intranet facing
12.Included with Server 2012 at no extra cost or license

PSWA Browser Exerience
* Authentication
* Browser
* Phone
#>

<#
Module1-Introduction.Section2-PowerShellFeatures.Lesson5-PowerShellWorkflowOverview

After this lesson, you will:
* Be introduced to the sripting feature of PowerShell
* Extended PowerShell Features
* PowerShell Workflow
  -Affect multiple managed computers or devices at the same time
  -Sequences of long running tasks
  -Leverages Windows Workflow Foundation
  -Covered in depth in the WorkShop Plus: PowerShell v4.0 for IT Administrators Part 2
* What is a Workflow?
* -Commands consiting of an ordered sequence of related activities
* -Can run in parallel
* -Can survive a reboot or failure (on targets)
* -Workflows can be paused and resumed
* -Looks like a PowerShell script
# Criteria
1. You need to perform a long-running task that combines multiple steps in a sequence
2. You need to perform a task that runs on multiple devices
3. You need to perform a task that requires checkpointing or persistence
3. You need to perform a long-running task that is asynchronous, restartable, parallelizable, or interruptible
4. You need to run a task on a large scale, or in high availability environments, potentially requiring throttling and connection pooling
Basic Syntax:
PowerShell converts this syntax to native Windows Workflow (WWF) XAML format  - WWF native language Support scalable & remote multi-device management

Workflow elements
1. Client computer, which triggers the workflow
2. Local or remote session to run the workflow on managed systems
3. Managed nodes - target comptuers affected by the workflow activties

When to use Workflow?
1. Performing a long-running task that combines multiple steps in a sequence
2. Performing a task that runs on multiple devices
3. Performing a task that requires check-pointing or persistence
4. Perform a long-running task that is asynchronous, re-startable, parallelizable, or interruptible
5. Run a task ona large scale requiring throttleing and connection pooling

Syntax

Workflow <name>
{
 param ($parameter1, $parameterN)
 <Activity List>
} #end Workflow
#>

<#
Module1-Introduction.Section2-PowerShellFeatures.Lesson6-DesiredStateConfiguration(DSC)Overview

Covered in detail in Windows PowerShell 4.0 for the IT Professional - Part 2
What is Desired State Configuration
1. Enables deploying and managing software configuration
2. Ensures software has correct configuration
2. Prevents configuration drift
3. Resources specify how software is configured
4. Automate Configuration of a set of computers (target nodes) e.g.:
   a. Enabling or disabling server roles and features
   b. Managing registry settings
   c. Managing files and directories
   d. Starting, stopping, and managing processes and services
   e. Managing groups and user accounts
   f. Deploying new software
   g. Managing environment variables
   h. Running Windows PowerShell scripts
   i. Fixing a configuration that has drifted away from the desired state
   j. Discovering actual configuration state on a given node
5. In addition, you can create custom resources to configure the state of any application or system setting.
6. DSC is introduced in Windows PowerShell 4.0.

For detailed information about DSC, see "Windows PowerShell Desired State Configuration" in the TechNet Library at
http://go.microsoft.com/fwlink/?LinkId=311940 or type Get-Help about_DesiredStateConfiguration

Example: Use WindowsFeature and File Resources to manage software configuration

Configuration MyWebConfig
{
 Node "2012R2-MS"
 {
  WindowsFeature IIS
  {
   Ensure = "Present"
   Name = "Web-Server"
  } #end Resource
  File WebDirectory
  {
   Ensure = "Present"
   Type = "Directory"
   Recurse = $true
   SoucePath = $WebsiteFilePath
   DestinationPath = "C:\inetpub\wwwroot"
   DependsOn = "[WindowsFeature]IIS"
  } #end Resource
 } #end Node
}#end Configuration

Labout_DesiredStateConfiguration
TOPIC
    about_Desired_State_Configuration

SHORT DESCRIPTION
    Provides a brief introduction to the Windows 
    PowerShell Desired State Configuration (DSC) feature.
    
LONG DESCRIPTION
    DSC is a management platform in Windows PowerShell that enables deploying
    and managing configuration data for software services, and managing the
    environment in which these services run.

    DSC provides a set of Windows PowerShell language extensions,
    new cmdlets, and resources that you can use to declaratively specify
    how you want the state of your software environment to be configured. It
    also provides a means to maintain and manage existing configurations. 

    DSC is introduced in Windows PowerShell 4.0.

    For detailed information about DSC, see 
    "Windows PowerShell Desired State Configuration Overview" in the TechNet
    Library at http://go.microsoft.com/fwlink/?LinkId=311940.

DEVELOPING DSC RESOURCES WITH CLASSES
    Starting in Windows PowerShell 5.0, you can develop DSC resources by using
    classes. For more information, see about_Classes, and "Writing a custom
    DSC resource with PowerShell classes" on Microsoft TechNet
    (http://technet.microsoft.com/library/dn948461.aspx).
 
USING DSC
    To use DSC to configure your environment, first define a Windows 
    PowerShell script block using the Configuration keyword, followed by an
    identifier, which is in turn followed by the pair of curly braces delimiting
    the block. Inside the configuration block you can define node blocks that
    specify the desired configuration state for each node (computer) in the
    environment. A node block starts with the Node keyword, followed by the name
    of the target computer, which can be a variable. After the computer name, come
    the curly braces that delimit the node block. Inside the node block, you can
    define resource blocks to configure specific resources. A resource block starts
    with the type name of the resource, followed by the identifier you want to
    specify for that block, followed by the curly braces that delimit the block,
    as shown in the following example.
          
    Configuration MyWebConfig
    {
       # Parameters are optional
       param ($MachineName, $WebsiteFilePath)

       # A Configuration block can have one or more Node blocks
       Node $MachineName
       {
          # Next, specify one or more resource blocks
          # WindowsFeature is one of the resources you can use in a Node block
          # This example ensures the Web Server (IIS) role is installed
          WindowsFeature IIS
          {
             # To ensure that the role is not installed, set Ensure to "Absent"
              Ensure = "Present" 
              Name = "Web-Server" # Use the Name property from Get-WindowsFeature  
          }

          # You can use the File resource to create files and folders
          # "WebDirectory" is the name you want to use to refer to this instance
          File WebDirectory
          {
             Ensure = "Present"  # You can also set Ensure to "Absent“
             Type = "Directory“ # Default is “File”
             Recurse = $true
             SourcePath = $WebsiteFilePath
             DestinationPath = "C:\inetpub\wwwroot"
            
             # Ensure that the IIS block is successfully run first before
             # configuring this resource
             Requires = "[WindowsFeature]IIS"  # Use Requires for dependencies     
          }
       }
    }

    To create a configuration, invoke the Configuration block the same way you would
    invoke a Windows PowerShell function, passing in any expected parameters you may
    have defined (two in the example above). For example, in this case:

    MyWebConfig -MachineName "TestMachine" –WebsiteFilePath "\\filesrv\WebFiles" `
         -OutputPath "C:\Windows\system32\temp" # OutputPath is optional

    This generates a MOF file per node at the path you specify. These MOF files specify
    the desired configuration for each node. Next, use the following cmdlet to parse the
    configuration MOF files, send each node its corresponding configuration, and enact
    those configurations. Note that you do not need to create a separate MOF file for
    class-based DSC resources.

    Start-DscConfiguration –Verbose -Wait -Path "C:\Windows\system32\temp"

USING DSC TO MAINTAIN CONFIGURATION STATE
    With DSC, configuration is idempotent. This means that if you use DSC to enact the 
    same configuration more than once, the resulting configuration state will always
    be the same. Because of this, if you suspect that any nodes in your environment
    may have drifted from the desired state of configuration, you can enact the same
    DSC configuration again to bring them back to the desired state. You do not need 
    to modify the configuration script to address only those resources whose state has
    drifted from the desired state.
    
    The following example shows how you can verify whether the actual state of 
    configuration on a given node has drifted from the last DSC configuration enacted
    on the node. In this example we are checking the configuration of the local computer.

    $session = New-CimSession -ComputerName "localhost"
    Test-DscConfiguration -CimSession $session 

BUILT-IN DSC RESOURCES
    You can use the following built-in resources in your configuration scripts:

    Name                   Properties
    ----                   ----------
    File                   {DestinationPath, Attributes, Checksum, Contents...}
    Archive                {Destination, Path, Checksum, Credential...}
    Environment            {Name, DependsOn, Ensure, Path...}
    Group                  {GroupName, Credential, DependsOn, Description...}
    Log                    {Message, DependsOn, PsDscRunAsCredential}
    Package                {Name, Path, ProductId, Arguments...}
    Registry               {Key, ValueName, DependsOn, Ensure...}
    Script                 {GetScript, SetScript, TestScript, Credential...}
    Service                {Name, BuiltInAccount, Credential, Dependencies...}
    User                   {UserName, DependsOn, Description, Disabled...}
    WaitForAll             {NodeName, ResourceName, DependsOn, PsDscRunAsCredential...}
    WaitForAny             {NodeName, ResourceName, DependsOn, PsDscRunAsCredential...}
    WaitForSome            {NodeCount, NodeName, ResourceName, DependsOn...}
    WindowsFeature         {Name, Credential, DependsOn, Ensure...}
    WindowsOptionalFeature {Name, DependsOn, Ensure, LogLevel...}
    WindowsProcess         {Arguments, Path, Credential, DependsOn...}

    To get a list of available DSC resources on your system, run the
    Get-DscResource cmdlet.

    The example in this topic demonstrates how to use the File and WindowsFeature
    resources. To see all properties that you can use with a resource, insert the
    cursor in the resource keyword (for example, File) within your configuration
    script in Windows PowerShell ISE, hold down CTRL, and then press SPACEBAR.

FIND MORE RESOURCES
    You can download, install, and learn about many other available DSC resources that
    have been created by the PowerShell and DSC user community, and by Microsoft.
    Visit the PowerShell Gallery (https://www.powershellgallery.com/) to browse and learn
    about available DSC resources.

SEE ALSO
   "Windows PowerShell Desired State Configuration Overview"
   (http://go.microsoft.com/fwlink/?LinkId=311940)
   "Built-In Windows PowerShell Desired State Configuration Resources"
   (http://technet.microsoft.com/library/dn249921.aspx)
   "Build Custom Windows PowerShell Desired State Configuration Resources"
   (http://technet.microsoft.com/library/dn249927.aspx) 
#>

#endregion Module1-Introduction.ModuleOverview

# MODULE 02
# Module2-Commands1.Section1-CommandIntroduction.Lesson1-ExternalCommands

<# 
External Commands
* Use traditional tools like sc.exe, netsh.exe, reg.exe in PowerShell.exe
* Runs in a separate process
* Difficult to discover with no standard naming convention or syntax
NOTE: Execuatable commands do not run unless located in a folder listed in the Path environment variable, or unless the path is specified. To run a *.exe,
specify the full path, or type a dot (.) for hte current directory. For example, .\MPViewer.exe

Conflicts will occur when you attempt to run external commands in a PowerShell console or ISE. Some examples include:
COMMAND  CONFLICT
Sc       PowerShell alias for Set-Content
Set      Common PowerShell verb, so the PowerShell parser expects the "-" followed by a noun, which represents a complete cmdlet.
 
#>

# Module2-Commands1.Section1-CommandIntroduction.Lesson2-Cmdlets
<#
After this lesson, you will be able to :
* Describe what a cmdlet is
* Interpret the syntacx diagram for any cmdlet

Characteristics of a Cmdlet
1. Single purpose: Parsing & formatting, etc. is automatic or achieved with other cmdlets
2. Verb-Noun naming: Reduces the need to memorize commands (etymology) and are provided by PowerShell core and extension modules
3. Used interactively, in pipelines, or in scripts
4. Parameters to control Cmdlet behaviour
5. Native PowerShell command
6. Does not launch in a separate process

Anatomy of a Cmdlet

[Command Name] [Parameter Name] [Parameter Value] [Switch Parameter]
Stop-Service   -Name            Spooler           -Force
#>

# Cmdlet Examples

# S055: Force and PassThru switch parameters
Stop-Service -Name BITS -Force                                                                                                                                                     
Stop-Service -Name BITS -PassThru                                                                                                                                                  
Start-Service -Name BITS -PassThru 
Test-Connection -ComputerName localhost -Count 1 -Quiet  

# S056: Syntax
<# The values in the braces are separated by vertical bars ( | ). These bars indicate an "exclusive or" choice, meaning that you can choose only
   one value from the set of values that are listed inside the braces. For example, the syntax for the New-Alias cmdlet includes the following
   value enumeration for the Option parameter:
   -Option {None | ReadOnly | Constant | Private | AllScope}
   The braces and vertical bars indicate that you can choose any one of
   the listed values for the Option parameter, such as ReadOnly or AllScope.
   -Option ReadOnly

    The syntax diagrams use the following symbols:


    -- A hyphen (-) indicates a parameter name. In a command, type the hyphen
       immediately before the parameter name with no intervening spaces, as
       shown in the syntax diagram.

       For example, to use the Name parameter of New-Alias, type:

           -Name 

    -- Angle brackets (<>) indicate placeholder text. You do not type the
       angle brackets or the placeholder text in a command. Instead, you replace
       it with the item that it describes. 

       Angle brackets are used to identify the .NET type of the value that
       a parameter takes. For example, to use the Name parameter of the New-Alias
       cmdlet, you replace the <string> with a string, which is a single word or a
       group of words that are enclosed in quotation marks.
      
        
    -- Brackets ([ ]) indicate optional items. A parameter and its value can be
       optional, or the name of a required parameter can be optional. 
 
       For example, the Description parameter of New-Alias and its value are
       enclosed in brackets because they are both optional. 
 
   [-Description <string>]
       
       
       The brackets also indicate that the Name parameter value (<string>) is
       required, but the parameter name, "Name," is optional. 

         [-Name] <string>


    -- A right and left bracket ([]) appended to a .NET type indicates that
       the parameter can accept one or multiple values of that type. Enter the 
       values in a comma-separated list.

       For example, the Name parameter of the New-Alias cmdlet takes only 
       one string, but the Name parameter of Get-Process can take one or 
       many strings.

          New-Alias [-Name] <string>

               New-Alias -Name MyAlias

          Get-Process [-Name] <string[]>

               Get-Process -Name Explorer, Winlogon, Services
               

    -- Braces ({}) indicate an "enumeration," which is a set of valid values
       for a parameter. 
 
       The values in the braces are separated by vertical bars ( | ). These bars       
       indicate an "exclusive or" choice, meaning that you can choose only
       one value from the set of values that are listed inside the braces. 

       For example, the syntax for the New-Alias cmdlet includes the following
       value enumeration for the Option parameter:

          -Option {None | ReadOnly | Constant | Private | AllScope}

       The braces and vertical bars indicate that you can choose any one of
       the listed values for the Option parameter, such as ReadOnly or AllScope.

          -Option ReadOnly



  Optional Items
      Brackets ([]) surround optional items. For example, in the New-Alias 
      cmdlet syntax description, the Scope parameter is optional. This is 
      indicated in the syntax by the brackets around the parameter name 
      and type:

          [-Scope <string>]


      Both the following examples are correct uses of the New-Alias cmdlet:

          New-Alias -Name utd -Value Update-TypeData
          New-Alias -Name utd -Value Update-TypeData -Scope global


      A parameter name can be optional even if the value for that parameter is 
      required. This is indicated in the syntax by the brackets around the 
      parameter name but not the parameter type, as in this example from the 
      New-Alias cmdlet:

          [-Name] <string> [-Value] <string>


      The following  commands correctly use the New-Alias cmdlet. The commands 
      produce the same result.

          New-Alias -Name utd -Value Update-TypeData
          New-Alias -Name utd Update-TypeData
          New-Alias utd -Value Update-TypeData
          New-Alias utd Update-TypeData


      If the parameter name is not included in the statement as typed, Windows 
      PowerShell tries to use the position of the arguments to assign the 
      values to parameters.


      The following example is not complete:

          New-Alias utd


      This cmdlet requires values for both the Name and Value parameters.


      In syntax examples, brackets are also used in naming and casting to 
      .NET Framework types. In this context, brackets do not indicate an 
      element is optional. 
#>

<#
Syntax Legend
<verb-noun>   Command name
-<parameter>  Required parameter name
<value>       Required parameter value
[-<> <>]      Optinal parameter and/or value
<value[]>     Multiple parameter values

Get-Command -Name Add-Computer -Syntax

Add-Computer [-DomainName] <string> -Credential <pscredential> [-ComputerName <string[]>] [-LocalCredential <pscredential>] [-UnjoinDomainCredential <pscredential>] [-OUPath <string>] [-Server <string>] [-Unsecure] 
[-Options <JoinOptions>] [-Restart] [-PassThru] [-NewName <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Add-Computer [-WorkgroupName] <string> [-ComputerName <string[]>] [-LocalCredential <pscredential>] [-Credential <pscredential>] [-Restart] [-PassThru] [-NewName <string>] [-Force] [-WhatIf] [-Confirm] 
[<CommonParameters>]
#>
# S065: Parameter Sets
Get-Command -Name Stop-Process -Syntax
<#
Stop-Process [-Id] <int[]> [-PassThru] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Stop-Process -Name <string[]> [-PassThru] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Stop-Process [-InputObject] <Process[]> [-PassThru] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

NOTE: 'Name', 'InputObject' and 'Id' parameters cannot be used together and are required (value only for '-Id' & 'InputObject') in their respective parameter set
#>

<#
Module2-Commands1.Section1-CommandIntroduction.Lesson3-CommonParameters

After this lesson, you will: Understand that all cmdlets have a set of common parameters
Common Parameters
*Parameters are automatically available with any cmdlet
* Implemented by Powershell, not cmdlet developer
* Override system defaults or preferences, i.e. $ErrorActionPreference
[DEEVOOPW2+WC]
-Debug (db):          Displays programmer-level detail
-ErrorAction (ea):    Determines how cmdlet responds to errors
-ErrorVariable (ev):  Stores error messages in a specified variable
-OutVariable (ov):    Stores output in a specified variable
-OutBufer (ob):       Determines number of output objects to accumulate in a buffer
-PipelineVariable(pv):Stores value of current pipeline* element as a variable
-Verbose(vb):         Displays detailed information
-WarningAction(wa):   Determines how cmdlet responds to warnings
-WarningVariable (wv):Stores warnings ina specified variable
* Pipeline is discussed in module 3
#>

Get-Process notepad -ErrorAction -SilentlyContinue
Restart-Service -Name BITS
Restart-Service -Name BITS -Verbose
Get-Process Netlogon

# Automatic variables
$ErrorActionPreference
$Error

# Common parameter: OutVariable
$HostsFile = "C:\WINDOWS\System32\drivers\etc\hosts"
$FileHas = Get-FileHash $HostsFile
Get-FileHash -Path $HostsFile -OutVariable OriginalHostsFileHash
$OriginalHostsFileHash

# Common parameter: Verbose
Restart-Service -Name Netlogon
Restart-Service -Name Netlogon -Verbose

# Common parameters: Error Action
Get-Process Netlogon -ErrorAction
Get-Process Netlogon -ErrorAction Continue

# Common parameters: Error Variable
Get-Process Netlogon -ErrorAction SilentlyContinue -ErrorVariable ErrVar
Get-Process Netlogon -ErrorAction Inquire -ErrorVariable ErrVar [suspend]
Get-Process Netlogon -ErrorAction Stop -ErrorVariable ErrVar
$ErrVar

<#
Risk Mitigation Parameters
*Many cmdlets also offer risk mitigation parameters
*Typically when the cmdlet changes the system or application
-WhatIf (wi): Displays message describing the effect of the command, instead of executing the command
-Confirm(cf): Prompts for confirmation before executing command
#>

<#
Example: WhatIf
Can be used while creating scripts to gain confidence that a command will execute properly, but does not actually change the system or application during
the development and testing phase. If systems or applications are changed during testing, the original pre-change conditions would have to be reset.
#>
Stop-Service -Name BITS -WhatIf
Stop-Process -Name * -WhatIf

# Example: Confirm
Stop-Service -Name BITS -Confirm

<#
Are you sure you want to perform this action?
Performing the operation "Stop-Service" on target "Background Intelligent Transfer Service (BITS)".
Yes
Yes to All
No
No to All
Suspend

Module2-Commands1.Section1-CommandIntroduction.Lesson4-CommandTerminationAndLineContinuation

After this lesson, you will be able to: Use command termination characters

Termination Characters:
* To complete a command use either a:
  1. Newline character (enter), or a 
  2. Semi-colon ";"
  3. A semi-colon can be used to execute more than one statement on a single line
#>

# Example: Command termination character
Get-Service BITS ; Get-Process System

<#
Line Continuation:
1. When a statement is not antactically complete and there is a newline character, PowerShell enters a line continuation
>>
2. Still in the same statement
3. Complete syntax and include an empty line to finish the statement and execute
4. Ctrl-C to break out and abort statement and line continuation
5. Useful when line continuation is accidental (Ctrl-C followed by Up-Arrow gets you back)

"This is a multi-line
>> sting that continues
>> on several lines
>> until the syntax is completed"
>>

This is a multi-line 
string that continues 
on several lines
until the syntax is completed
#>

<#
Module2-Commands1.Section2-CoreCmdlets.Lesson1-Get-CommandAndShow-Command

After this lesson, you will be able to:
* Find commands with the Get-Command cmdlet

Get-Command
*Discover commands (cmdlets, functions, scripts, aliases)
*Can show command syntax
*Can also discover external commands (.exe, .clp, .msc)
#>

Get-Command -Name *.msc

# How many commands are available on your system?
Get-Command
(Get-Command).Count
# How many cmdlets?
# How many functions?
# How many applications?

Get-Command -Name *user*
# This command can be used if you need to perform an operation on a user, but don't quite remeber the exact syntax of the cmdlet

Get-Command -Verb *Get*
# Recall that there is a verb component, as well as a noun component for cmdlets

Get-Command -Noun Service

Get-Command -CommandType Cmdlet
# How many Cmdlets are available on your system?
(Get-Command -CommandType Cmdlet).Count

# Length vs. Count method 

# Example: List Cmdlet syntax with Get-Command
Get-Command Get-WinEvent -Syntax
Show-Command

<#
Module2-Commands1.Section2-CoreCmdlets.Lesson2-Get-Help

After this lesson, you will be able to:
* Get help using the Get-Help cmdlet

Get-Help
*Cmdlet help
*Concept help
*Command Examples
*Detailed Syntax
#>

# Get-Help
Get-Help Get-Process -ShowWindow
Get-Help Get-ChildItem
Get-Help Get-ChildItem -Full
Get-Help Get-ChildItem -Examples
Get-Help Get-ChildItem -Detailed
Get-Help -Name about_CommonParameters -ShowWindow
Get-Help Get-Counter -Parameter Counter
Get-Help * -Parameter ComputerName

<#
Default Help Sections (no params) All Help Sections (-Full)
NAME                              NAME
SYNOPSIS                          SYNOPSIS
SYNTAX                            SYNTAX
DESCRIPTION                       DESCRIPTION
RELATED LINKS                     PARAMETERS
REMARKS                           INPUTS
                                  OUTPUTS
                                  NOTES
                                  EXAMPLES
                                  RELATED LINKS
#>

# NOTE: The following command does not work:
Get-ChildItem /? 

# Example: Help for Specified Cmdlet Parameter(s)
Get-Help Get-ChildItem -Parameter Path
Get-Help Get-Counter -Parameter Counter

<#
Module2-Commands1.Section3-CmdletAlternateNames.Lesson1-Aliases
After this lesson, you will be able to: Understand cmdlet default aliases

#>

# Example: Listing Aliases
Get-Alias

<# 
Built-In Aliases
* PowerShell provides short names for frequenctly used cmdlets
* Ease of PowerShell adoption for Windows cmd.exe and *Nix administrations
* Saves time when typing interactive commands
#>

# Example: Built-in Aliases
Get-Alias dir
Get-Alias ls
Get-Alias gci

<#
Module2-Commands1.Section3-CmdletAlternateNames.Lesson1-Aliases

After this lesson, you will be able to: Understand cmdlet user-defined aliases

#>
# Example: Creating a custom alias
New-Alias -Name list -Value Get-ChildItem
New-Alias lst Get-ChildItem
Get-Command -Name New-Alias -Syntax

# Bookmark: S100; 30 MAY 2016

<#
Module3-Pipeline1.Section1-PipelineIntroduction.Lesson1-WhatIsAPipeline?

After this lesson, you will be able to: Explain what a pipeline is
1. Series of commands connected by the pipeline character
2. Represented by a vertical bar character
3. Sends output from one command as input to another command (left to right)
4. Passes Objects, not text
5. Allows Filtering, Formatting and Outputting
6. Cmdlets are designed to be chained together into ‘pipelines’
#>

# Module3-Pipeline1.Section2-PipelineInput.Lesson1-GetCmdletsExternalCommdndsTextFileInput

# The Get Cmdlets
# * Typically placed first in the pipeline
# * Provides the input to be processed
# [Retuns schedule and bits svc]   [Takes action on svcs]
Get-Service -Name Schedule, BITS | Start-Service -Verbose

# External commands
# * Can be used as input to the pipeline
whoami.exe
# [external command]
whoami.exe | Split-Path -Parent
whoami.exe | Split-Path -Leaf

# Text File Input
# Text files provide input to be processed by the pipeline

$NewFile = "c:\data\services\service.txt"
New-Item -Path $NewFile -ItemType File -Force
(Get-Service).Name | Select-Object -First 10 | Out-File -FilePath $NewFile
# [Reads a text file]  [Takes action on each line in the file]
Get-Content $NewFile | Get-Service 

<#
Import Cmdlets
Import structured text data into Windows PowerShell
Data can be processed by subsequent commands
Import-Csv <-Path><> <-Delimiter><> <-Header><>
Import-CliXml <-Path><> <-First><>
#>

$UsersFilePath = "C:\data\scripts\users.csv"
$Users = Import-Csv -Path $UsersFilePath
$Users

# Module3-Pipeline1.Section3-PipelineObjectManipulation.Lesson1-ObjectCmdlets

<#
Object Cmdlets
After this lesson, you will: Understand pipeline manipulation with object cmdlets

Name            Description
Sort-Object     Sorts objects by property values
Select-Object   Selects object properties
Group-Object    Groups objects that contain the same value for specified properties
Measure-Object  Calculates numeric properties of objects, and the characters, words, and lines in string objects, such as text files
Compare-Object  Compares two sets of objects
#>

# Example: Sort-Object, Select-Object, Group Object
Get-Process | Sort-Object VM -Descending | Select-Object -First 2
Get-EventLog -LogName Security | Group-Object EntryType
$Users | Sort-Object Office
$Users | Group-Object Office
$Users | Group-Object Office | Sort-Object Count -Descending
$Users | Group-Object Office | Sort-Object Name -Descending

# Example: Measure-Object
# This command displays the minimum, maximum, and average sizes of the working sets of the processes on the computer.
get-process | measure-object -property workingset -minimum -maximum -average
# How long does it take for my system to count to 10 million?
Measure-Command { 1..10000000 }

# Example: Compare-Object
$Svr1 = "C:\DATA\scripts\servers1.txt"
$Svr2 = "C:\DATA\scripts\servers2.txt"
Write-Host("")
Write-Host("="*20)
$Svr1
Write-Host("="*20)
Get-Content -Path $Svr1 -OutVariable ref 
Write-Host("")
Write-Host ("="*20)
$Svr2
Write-Host ("="*20)
Get-Content -Path $Svr2 -OutVariable diff 
Compare-Object -ReferenceObject $ref -DifferenceObject $diff

<#
(-Reference Object)  (-DifferenceObject)
$Srv1                $Srv2
InputObject          SideIndicator
-----------          -------------
server11.contoso.lab =>           
server12.contoso.lab =>           
server13.contoso.lab =>           
server14.contoso.lab <=           
server15.contoso.lab <=    
#>

# Module3-Pipeline1.Section4-PipelineOutput.Lesson1-FormatCmdlets

<#
After this lesson, you will: Understand pipeline output with the format cmdlets
Convert pipeline objects into formatted output, typically for human consumption
Should be last Cmdlet on the pipeline (only followed by Out-* Cmdlets)
#>

# Example: Format Cmdlets
Get-Process -Name powershell | Format-List
Get-Process -Name powershell | Format-List -Property *

Get-Process -Name powershell | 
Format-List -Property Name, BasePriority, PriorityClass 

# SessionId (SI): Identifier that an operating system generates when a session is created. A session spans a period of time from logon until logoff from a specific system.
# Ref: https://msdn.microsoft.com/en-us/library/system.diagnostics.process.sessionid(v=vs.110).aspx
Get-Process | Format-Table -GroupBy SI
Get-Process | Group-Object SI
Get-Process | Format-Table -Property name,workingset,handles -AutoSize
Get-Process | Format-Table -Property name,workingset,handles,path -AutoSize
# Path property is line wraped, working set still lost in this case
Get-Process | Format-Table -Property name,path,workingset,handles,path -AutoSize -Wrap
Get-Process | Format-Table -Property name,workingset,handles,path -AutoSize
Get-Process | Sort-Object -Property BasePriority | Format-Table -GroupBy BasePriority -Wrap -AutoSize
# Processes are grouped by BasePriority (need to sort by groupby property first)
# Autosize minimizes data truncation, wrap eliminates it
Get-ChildItem | Format-Wide 
# Output is displayed in 2 columns by default
Get-ChildItem | Format-Wide -AutoSize
Get-Alias | Format-Wide -AutoSize
# Output displayed in max numbers of columns based on widest data
# Column and Autosize parameters are mutually exclusive!
Get-ChildItem | Format-Wide -Column 5
# Output is displayed in 5 columns

# Module3-Pipeline1.Section4-PipelineOutput.Lesson2-ExportAndImportCmdlets

<#
After this lesson, you will: Understand pipeline output with export cmdlets
Export Cmdlets
* Export pipeline objects to text file
* Should be last cmdlet on the pipeline
Export-Csv -Path <> -Delimiter <>
Export-CliXml -Path <> -Depth <>
#>

# Example: Export-CliXml
$ProcessXml = "c:\data\csv\process.xml"
Get-Process | Export-CliXml -Path $ProcessXml
$OrigProcessList = Import-Clixml -Path $ProcessXml
$OrigProcessList

# S137: Out Cmdlets
Get-Process | Out-GridView 
Get-Process | Out-GridView -PassThru
Get-Process | Out-GridView -PassThru | Export-Csv c:\data\scripts\Process.csv 

# -NoTypeInformation parameter avoids the object type, i.e. #TYPE System.ServiceProcess.ServiceController 
Get-Service | Export-Csv -Path C:\data\scripts\services.csv -NoTypeInformation

# Example: Import-Csv
Import-Csv C:\data\scripts\services.csv | Select-Object Name

Get-Alias | Select-String "Get-Command"
Get-Alias | Out-String -Stream | Select-String "Get-Command"
Get-Alias | Out-String -Stream | Select-String "Get-ChildItem"

# Module3-Pipeline1.Section4-PipelineOutput.Lesson3-OutCmdlets

<#
After this lesson, you will be able to: Understand pipeline output with out cmdlets

Out Cmdlets: Sends command output to a specified device

Name          Description
----          ----------- 
Out-Default   Sends output to default formatter and to default output cmdlet (Out-Host)
Out-File      Sends output to a file, append switch parameter, encoding parameter allows control of the character encoding
Out-GridView  Sends output to an interactive table in a separate GUI
Out-Host      Default. Sends output to PowerShell host. Paging switch parameter displays one page at a time
Out-Null      Deletes output instead of sending it down the pipeline
Out-Printer   Sends output to a printer
Out-String    Sends objects to the host as a series of strings
#>

Import-Csv C:\data\scripts\services.csv | Out-GridView -PassThru

# Pipline Output
# Storing pipelie output in a variable
# Pipeline output can be stored in a user-defined variable using the = assignment operator

$ProcessObject = Get-Process | Group-Object SI

# Module4-Commands2.Section1-ScriptBlocks.Lesson1-WhatIsAScriptBlock?
{<statement list>}

{
 param ($parameter1,$parameterN)
 <statement list>
} #end Script

# Module4-Commands2.Section2-Functions.Lesson1-FunctionsIntroduction
function <name>
{
param ($parameter1,$parameterN)
<statement list>
} #end function

# Function without parameters
Function Get-ServiceInfo
{
 Get-Service -Name Spooler -RequiredServices -ComputerName localhost 
} #end function
Get-ServiceInfo

# Function with parameters
Function Get-ServiceInfo
{
 Param ($svc, $computer)
 Get-Service -Name $svc -RequiredServices -ComputerName $computer
} #end function
Get-ServiceInfo -svc spooler -computer localhost

# Module4-Commands2.Section3-Remoting.Lesson1-IntroductionToPowerShellRemoting
# Which commands support PowerShell remoting?
Get-Command -ParameterName ComputerName
# How many commands support PowerShell remoting?
(Get-Command -ParameterName ComputerName).Count

# Module4-Commands2.Section3-Remoting.Lesson2-UsingPowerShellRemoting

# Temporary session
Enter-PSSession -ComputerName 2012R2-DC
Hostname
Exit-PSSession
# Permanent session
# 1-1
Invoke-Command -ComputerName 2012R2-DC -ScriptBlock { Get-Culture }
# 1-Many
Invoke-Command -ComputerName 2012R2-DC, WIN8-WS -ScriptBlock { Get-Culture }
Invoke-Command -ComputerName 2012R2-DC, WIN8-WS -Credential contoso\administrator -ScriptBlock { Get-Culture }

New-PSSession -ComputerName 2012R2-DC -OutVariable dcps
Get-PSSession $dcps
Invoke-Command -Session $dcps -ScriptBlock { Get-Culture }

New-PSSession -ComputerName 2012R2-DC, WIN8-WS -OutVariable multips
Invoke-Command -Session $multips -ScriptBlock { Get-Culture }

# Module5-Scripts.Section1-IntroductionToScripts.Lesson1-WhatIsAScript?

# Sample Script
Write-Host "Start of script" -ForegroundColor White -BackgroundColor Green
Write-Host "Display the % CPU Time utilized by the ISE" -ForegroundColor White -BackgroundColor Green
Get-Counter "\Process(powershell_ise)\% Processor Time"

# Module5-Scripts.Section2-RunningScripts.Lesson1-ExecutionPolicies
<# Restricted
    * Default
    * Script cannot be run
    * PowerShell interactive mode only
   AllSigned
    * Runs a script only if signed
    * Signature must be trusted on local machine
   RemoteSigned
    * Recommended Minimum
    * Runs all local scripts
    * Downloaded scripts must be signed by trusted source
   Unrestricted
    * All scripts from all sources can be run without signing
   Bypass
    * Same as unrestricted

Remote Policies
#>

<# Execution Policy Scopes [P]olicy[P]rocess[R]egistry
    * AD Group Policy - Computer
        -Affects all users on targeted computer [Turn On Script Execution]
    * AD Group Policy - User
        -Affects users targeted only
    * Process
        -Console or ISE Command-line Parameter: i.e.: c:\> Powershell.exe -executionpolicy remotesigned
        -Affects current powershell host session only
        -Lost upon exist of session
    * Registry - User
        -Affects current user only
        -Stored in HCKU registry subkey
    * Registry - Computer
        -Affects all users on computer
        -Stored in HKLM registry subkey (Admin access needed to change)
#>

# Determine current execution policy
Get-ExecutionPolicy
# List available execution policies
Get-ExecutionPolicy -List
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Script signing
$CodeSigningCertThumbPrint = "BE785E2D2F1D27946E626AE77CA33AE2070E0A92"
$CodeSigningCert = Get-ChildItem Cert:\CurrentUser\my -CodeSigningCert -recurse | Where-Object { $_.Thumbprint -eq "$CodeSigningCertThumbprint" }
$ScriptToSign = "C:\DATA\scripts\HelloWorld.ps1"
# Sign the script
Set-AuthenticodeSignature -FilePath $ScriptToSign -Certificate $CodeSigningCert

# Module5-Scripts.Section2-RunningScripts.Lesson2-LaunchingAScript

# Spaces in path
& "c:\scripts\my script.ps1"

# Outside PowerShell (cmd.exe)
powershell.exe -NoExit -File "c:\scripts\isecputtime.ps1"

# Module5-Scripts.Section3-ScriptParameters.Lesson1-TheParamStatement
param ($ComputerName)
$result = Test-Connection -ComputerName $ComputerName -Quiet -Count 1
Write-Host $result -ForegroundColor Green

.\ScriptParamExample.ps1 -ComputerName localhost
.\ScriptParamExample.ps1 -ComputerName DoesNotExist

# Module5-Scripts.Section4-ScriptComments.Lesson1-SingleLineAdBlockComments

# Single line comment

<#
 Multi-line
 Comments
#>

# Module5-Scripts.Section4-ScriptComments.Lesson2-#RequiresStatement

# Special comment
# Prevents script from running without required elements
# Can only be used in scripts, not functions

#Requires -Version <N>[.<n>]
#Requires -PSSnapin <PSSnapin-Name> [Version <N>[.<n>]]
#Requires -ShellId <ShellId>
#Requires -Modules { <Module-Name>|<Hashtable> }
#Requires -RunAsAdministrator

# Get-Help about_Requires

# Module5-Scripts.Section5-CommandPrecedence.Lesson1-ExploreCommandPrecedenceRules

# Command Lookup Precedence (When there is more than one command with the same name)
# * Path (Powershell)
# * Alias (Allows)
# * Function (Fixing)
# * Cmdlet (Complex)
# * External (Environments)

ping 2012r2-dc
New-Alias -Name ping -Value Test-Connection
ping 2012r2-dc

# Normal cmdlet
Get-Process system

# Create function with same name
Function Get-Process { "This is't Get-Process" }

# Command precedence runs function instead of cmdlet
Get-Process

# Module qualify command name (OK)
Microsoft.PowerShell.Management\Get-Process -Name System

# S203: Module5-Scripts.Section6-IntegratedScriptingEnvironment.Lesson1.ISE

# Ref: http://powershell.com/cs/blogs/tips/archive/2012/08/27/sharing-powershell-ise-v3-code-snippets.aspx
# All custom snippets are stored as XML files in this location:
Join-Path (Split-Path $profile) 'Snippets'

# So if you want to share snippets or copy them from one machine to another, simply open the folder and copy the files to wherever you want:
Invoke-Item (Join-Path (Split-Path $profile) 'Snippets')

# Show snippets
$psISE.CurrentPowerShellTab.Snippets

Switch (Get-ChildItem -Path c:\)
{
"program*" {Write-Host $_ -ForegroundColor Green}
"windows" {Write-Host $_ -ForegroundColor Cyan}
} # end switch

Switch -Wildcard (Get-ChildItem -Path c:\)
{
"program*" {Write-Host $_ -ForegroundColor Green}
"windows" {Write-Host $_ -ForegroundColor Cyan}
} # end switch

# ISE
# To see your ise profile
ise $profile

# Integrated context sensitive help

# Auto-Save
# * Automatically saves script to alternate location
# * Default save interval is 2 mins (configurable)
# Crash Recovery
# * Uses alternate auto-saved files to restore un-saved scripts

$psise.Options.AutoSaveMinuteInterval

#region tags
# Region tags must be lower case
# Optional text following the # region tag can help with code documentation
#endregion

# Brace matching {}, (), []
# Edit - Go to Match (CTRL+])

# For more information about snippets, see: https://www.petri.com/working-with-the-powershell-ise-and-script-snippets
# There are 3 kinds of snippets [Ctrl+J]
# * Default
# * User-Defined
# * Module-Based

Get-IseSnippet
New-IseSnippet
Import-IseSnippet -Module ModuleName

# Compiled Add-Ons
# WPF based controls, i.e. Show-Command Add-On

# Module6-HelpSystem.Section1-BeyondCmdletHelp.Lesson1-GettingHelpForPowerShellConcepts

Get-Help about_Common_Parameters

# How many conceptual help topics are available ?
(Get-Help about_).Count

# Module6-HelpSystem.Section2-MaagingTheHelpSystem.Lesson1-UpdatableHelp

Update-Help
# Downloads help content for cmdlets and modules in current session
# Only downloads updated help topics
# For system modules, administrative elevation is required
# Help can only be updated every 24 hours, even if cmdlet is run multiple times, unless -Force switch parameter is used

Update-Help -Module ModuleName
Update-Help -Module *
Get-Module ActiveDirectory | Update-Help

Get-Help about_Updatable_Help
Get-Help Update-Help -Full
Get-Help Update-Help -Online

Save-Help
# Optional Default soruce path location GPO setting
# ComputerConfiguration\Policies\AdministrativeTemplates\WindowsComponents\WindowsPowerShell\[Set the default source path for Update-Help]

# Module6-HelpSystem.Section3-UsingTheHelpSystem.Lesson1-UsingHelp
Get-Help -ShowWindow
Get-Help Get-Process -ShowWindow

# Module6-HelpSystem.Section3-UsingTheHelpSystem.Lesson2-Comment-BasedHelpTopicForFunctionsAndScripts

# Comment based help keywords
<#
.SYOPSIS
.DESCRIPTION
.PARAMETER <parameter name>
.EXAMPLE
.INPUTS
.OUTPUTS
.NOTES
 Examples are indexed automatically
.LINK
.COMPONENT
.ROLE
.FUNCTIONALITY
#>

# Customized
<#
.SYOPSIS
.DESCRIPTION
.PARAMETER <parameter name>
.EXAMPLE
.INPUTS
.OUTPUTS
.NOTES
.LINK
.COMPONENT
.ROLE
.FUNCTIONALITY
.REQUIREMENTS
.LIMITATIONS
.AUTHOR(S)
.EDITOR(S)
.REFERENCES
.KEYWORDS
.LICENSE
.DISCLAIMER
#>

# To get help for a script
Get-Help .\ScriptelpExample.ps1 -Full

# Module7-ObjectModels.Section1-ObjectsInPowerShell.Lesson1-WhatIsAnObject?

# What is an object?
# * Structured data
# * Collection of parts (nouns) and operations that can be performed (verb)
# An object is an instantiation of a class

# The bike object
# Properties
# * FrontWheel
# * BackWheel
# * Pedals
# * Color
# * Size
# Methods
# * Pedal()
# * Brake()
# SteerLeft()
# SteerRight()
# Wheelie()

$BikeObject = [PSCustomObject]@{
 pFrontWheel = "FrontWheel"
 pBackWheel = "BackWheel"
 pPedals = "Pedals"
 pColor = "Green"
 pSize = "Small"
} #end PSCustomObject

# members = properties + methods
# type = class

Get-Service | Get-Member 

# Retrieving a property using dot notation
$FileHash = Get-FileHash C:\data\aclfile.log
$FileHash.Hash

# Call method on an object
(Get-Process -Name spoolsv) | Get-Member -MemberType Method
(Get-Process -Name spoolsv).Kill()

# Find the type of an object
(Get-Date).GetType()

# 1. Object models are assocated with .NET, COM and WMI
# 2. Schemas are a collection of classes
# 3. Object Models are collections of types (i.e. data types)

# ISE member completion (.)


# S272 Operators

# Comparison
# Non-case sensitive
# -eq, -ne, -gt, -ge, -lt, -le
# Case sensitive
# -ceq, -cne, -cgt, -cge, -clt, -cle

1 -eq 1
1 -eq 2
10 -gt 20
10 -gt 5

'PowerShell' -gt 'CMDPrompt'
'a' -lt 'b'
'a' -lt 'aa'
$service = Get-Service bits
$service.Status -eq 'Running'

# Wildcards
# -like, -clike
# -notlike, -cnotlike
# *
# ?
# [1az9]
# [a-l]

'Pear' -eq 'p*'
'Pear' -like 'p*'
$Process = Get-Process -Name Sys*
$Process
$Process.Name -like '???????*'

# Regular expressions
# Input validation with parameters
# -match, -cmatch
# -notmatch, -cnotmatch

'Digit 5 in this string' -match '\d'
'hello there' -match '^there'

# Arrays'Di
# -contains, -ccontains
# -in, -cin
# -notin, -cnotin

1,2,3 -contains 2
"a","b","c" -notcontains "a"
2 -in 1,2,3
"a" -notin "a","b","c"
(Get-Process).Name -contains 'Notepad'
$ServerList -contains 'Server10'
'Server20' -in $ServerList

Get-Help about_Regular_Expressions

# Logical (compound conditions)
# -and, -or, -xor, -not or !

# Range
1..10
11..20
5..-5
# Range of characters operator
Get-ChildItem $home\[a-d]*

# Specified characters operator
Get-ChildItem $home\[ad]*

# Numeric multipliers [bytes]
2kb
100mb
1.5gb
2tb
2pb

# Pipeline Variable
# Built-in ($_ and $PSItem)
# Use -PipelieVariable common parameter to name your own
Get-Process | Where-Object { $psitem.ws -gt 100MB }
Get-Process | Where-object { $_.s -gt 100MB }
Get-Process -PipelieVariable CurrentProcess | Where-Object { $CurrentProcess.ws -gt 100MB } 

# % is an alias for ForEach
# ? is an Alias for Where-Object

Get-Service net* | ForEach-Object { "Hello " + $_.Name }

Get-ChildItem -Path *.txt | 
 Where-Object { $_.length -gt 10kb } | 
  Sort-Object -Property Length | 
   Format-Table -Property Name, Length

# S301
# Where-Object (v1.0+)
Get-ChildItem | Where-Object { $_.Length -gt 1mb }
Get-ChildItem | Where-Object { $_.PsIsContainer }
Get-Service | Where-Object { $_.Status -eq "Running" -and $_.CanShutdown }

# [Simplified Syntax] v3.0+: No compound conditions allowed
Get-ChildItem | Where-Object Length -gt 1mb
Get-ChildItem | Where PSIsContainer
Get-Service | Where Status -eq Running

# Slow (~42ms)
Get-Process | Where-Object { $_.Name -eq "explorer" }
Measure-Command { Get-Process | Where-Object { $_.Name -eq "explorer" } }
# Fast (~11ms)
Get-Process -Name explorer
Measure-Command { Get-Process -Name explorer } 

# S362: Variable Cmdlets
New-Variable zipcode -Value 90210
Clear-Variable -Name zipcode
Remove-Variable -Name zipcode
Set-Variable -Name desc -Value "Description"
Get-Variable -Name m*

# Automatic member enumeration without using ForEach-Object (v3.0+)
(Get-Process).ID
(Get-Process).Name

# Multiple levels
(Get-EventLog -Log System).TimeWritten.DayOfWeek | Group-Object

# Module9-Pipeline2.Section3-PipelineProcessing.Lesson1-BeginProcessEndBlocks

Get-EventLog -LogName Application -Newest 5 | ForEach-Object { $_.Message | Out-File -FilePath Events.txt -Append }
Get-EventLog -LogName Application -Newest 5 | ForEach-Object -Process { $_.Message | Out-File -FilePath Events.txt -Append }

# ForEach-Object cmdlet supports Begin, Process and End Parameters
# Begin block -> run once before any items are processed
# Process block -> run for each object on pipeline
# End block -> run once after all items have been processed
Get-EventLog -LogName Application -Newest 5 | 
ForEach-Object `
-Begin { Remove-Item .\events.txt ; Write-Host "Start" -ForegroundColor Red }
-Process { $_.Message | Out-File -FilePath Events.txt -Append }
-End { Write-Host "End" -ForegroundColor Green; notepad.exe events.txt }

# Named Blocks in Functions/ScriptBlocks
# -Statements can be in an unnamed block or in one or more named blocks
# -Allows custom processing of collections coming from pipelines
# -Can be defined in any order
# Begin Block: Statements executed once, before first pipeline object
# Process Block: Statements executed for each pipeline object delivered
# -If a collection of zero elements is sent via the pipeline, the process block is not executed at all
# -If called outside a pipeline context, the block is executed exactly once
# End block
# -Statements executed once, after last pipeline object
# Default if unnamed

Function My-Function
{

 Begin
 {
  Remove-Item .\events.txt
  Write-Host "Start" -ForegroundColor Red 
 } #end begin

 Process
 {
  $_.Message | Out-File -FilePath events.txt -Append
 } #end process

 End
 {
  Write-Host "End" -ForegroundColor Green
  notepad.exe events.txt 
 } #end end

} #end Function

Get-EventLog -LogName Application -Newest 5 | My-Function

# Module9-Pipeline2.Section4-CmdletParameterPipelineInput.Lesson1-TwoWaysToAcceptPipelineInput

# Cmdlet parameters can accept pipeline input in one of two ways:
# ByValue (Object Data Type)
# ByPropertyName (Object Property Name)
# Cmdlet parameters may accept pipelined objects by value, by property name or both

# Does a parameter accept pipeline input?
Get-Help Restart-Computer -Parameter ComputerName
# Accept pipeline input?       True (ByValue, ByPropertyName)
# For parameters that accept pipeline input ByValue, piped [objects] will bind or be associated...
# -To a parameter of the same [data]TYPE, i.e. 'System.String' that DOES accept pipelined input by value.
# -Note that -Protocol and -WsmanAuthentication parameters of the Restart-Computer cmdlet also requires the string data type, but they do not accept pipeline input.
# -To a parameter that can be converted to the same type, i.e. 

# ByValue
'2012r2-ms', '2012r2-dc' | Restart-Computer -WhatIf

# https://blogs.technet.microsoft.com/heyscriptingguy/2016/01/12/incorporating-pipelined-input-into-powershell-functions/
# Version 00.00.0001
# Advanced functions - use the [CmdletBinding()] method
Function Get-Something 
{
 [CmdletBinding()]
 Param($item)
 # 
 Write-Host "You passed the parameter $item into the function"
} #end funciton
'abc123' | Get-Something

# Version 00.00.0002
# Passing a simple string object through the pipeline
Function Get-Something 
{
 [CmdletBinding()]
 Param(
 [Parameter(ValueFromPipeline)]$item)
 
 Write-Host "You passed the parameter $item into the function"
} #end funciton
'abc123' | Get-Something

# Version 00.00.0003
# If input value is convertable to parameter value data type, it will still work
# This example also shows how to deliberately change the default behavior of scopes
Function Get-Something 
{
 [CmdletBinding()]
 Param(
 [Parameter(ValueFromPipeline)]
 [string]$Script:item)
 
 Write-Host "You passed the parameter $item into the function"
} #end funciton
1 | Get-Something
$item.GetType()

# Version 00.00.0004
# System.ServiceProcess.ServiceController object type returned
Function Get-Something 
{
 [CmdletBinding()]
 Param(
 [Parameter(ValueFromPipeline)]
 $item)
 # 
 Write-Host "You passed the parameter $item into the function"
} #end funciton
Get-Service | Get-Something

Get-Service | Get-Member

# Version 00.00.0005
# Error: ParameterBindingException
# The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input.
Function Get-Something 
{
 [CmdletBinding()]
 Param(
 [Parameter(ValueFromPipelineByPropertyName)]
 $item
 )
  Write-Host "You passed the parameter $item into the function"
} #end funciton
Get-Service | Get-Something

# Version 00.00.0006
# Correct: All service object name properties are listed
Function Get-Something 
{
 [CmdletBinding()]
 Param(
 [Parameter(ValueFromPipelineByPropertyName)]
 $Name )
 # 
 Process {
  Write-Host "You passed the parameter $Name into the function"
 } #end Process
} #end funciton
Get-Service | Get-Something

# Version 00.00.0007
# Correct: Either individual values or object properties are listed
Function Get-Something 
{
 [CmdletBinding()]
 Param(
 [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
 $Name )
 # 
 Process {
  Write-Host "You passed the parameter $Name into the function"
 } #end Process
} #end funciton
'abc123', 'def456' | Get-Something
Get-Service | Get-Something

# ByPropertyName
# For parameters that accept pipeline input ByPropertyName, piped object [properties] will bind:
# -To parameter(s) of the same name
$machine = [PSCustomObject]@{ 
ComputerName = "localhost"
ip = "192.168.1.200"
os = "Windows Server 2012 R2"
} #end PSCustomObject
$machine

# ByValue (Object)
$machine | Restart-Computer -WhatIf
# ByPropertyName (Property)
$machine.ComputerName | Restart-Computer -WhatIf

# Example: Pipeline Input ByValue
# Start-Service InputObject Parameter
Get-Help Start-Service -Parameter InputObject
# Accept pipeline input?       true (ByValue)
Get-Service -Name "Spooler" | Start-Service

# Parameter Binding Steps
# 1. Bind all named parameters
# 2. Bind all positional paramters
# 3. Bind from the pipeline by value with exact match
# 4. Bind from the pipeline by value with conversion
# 5. Bind from the pipeline by name with exact type match
# 6. Bind from the pipeline by name with type conversion

# Additional reference(s): 
# 1. https://blogs.technet.microsoft.com/heyscriptingguy/2016/01/12/incorporating-pipelined-input-into-powershell-functions/

# S363: Constant Variables
# * Can only be made constant at creation (can not use "=")
# * Can not be deleted
# * Can not be changed
New-Variable -Name cnPi -Value 3.1415926 -Option Constant -WhatIf

# Module10-Providers.Section1-ProvidersIntroduction.Lesson1-WhatAreProviders?

# Define the logic to access, navigate and edit a data store
# Functionally resemble a file system hierarchy
# Common interface to different data stores

# Where to get providers
# 1. PowerShell ships with built-in providers
# 2. Providers can be imported via modules
# 3. Examples of well-known imported providers:
# 3.a ActiveDirectory
# 3.b SQLServer

# Module10-Providers.Section2-BuiltInProvidersIntroduction.Lesson1-BuiltInProviders

Get-PSProviderGet

<#
Name                 Capabilities                                                                                       Drives                                                                                            
----                 ------------                                                                                       ------                                                                                            
Registry             ShouldProcess, Transactions                                                                        {HKLM, HKCU}                                                                                      
Alias                ShouldProcess                                                                                      {Alias}                                                                                           
Environment          ShouldProcess                                                                                      {Env}                                                                                             
FileSystem           Filter, ShouldProcess, Credentials                                                                 {C}                                                                                               
Function             ShouldProcess                                                                                      {Function}                                                                                        
Variable             ShouldProcess                                                                                      {Variable}                                                                                        
Certificate          ShouldProcess                                                                                      {Cert} 
#>

# Module10-Providers.Section2-ProviderCmdlets.Lesson1-ProviderCmdlets

# Provider capabilities
<#
Name               Description
----               -----------
Credentials        Credentials can be passed to provider
Exclude            Items can be excluded from data store based on a wildcard string
ExpandWildcards    Wildcards are handled within a provider internal path
Filter             Additinal filtering based on some provider-specific string is supported
Include            Items can be included in data store based on a wildcard string
None               Only features provided by base class and implemented interfaces are supported
ShouldProcess      Allow use of the WhatIf and Confirm (Risk Mitigation) parameters
Transactions       Allows user to accept/reject actions of provider cmdlets

ref: https://technet.microsoft.com/en-us/library/ff730971.aspx
When you start a transaction that transaction runs in the background, waiting for you to make explicit use of it. For example, suppose we use this command to add a new registry value named NontransactedValue to HKCU\Test:

New-ItemProperty -path HKCU:\Test -name NontransactedValue -value "This is a test."

Will this operation become part of our transaction? No, it will not. The command will run just fine, and the new registry value will be created. But the new registry value will be created immediately, without being stored as part of the transaction. And there will be no way to automatically roll back the creation of this new registry value.
So what went wrong here? Nothing; like we said, unless you specifically indicate that a command is supposed to be part of your transaction then that command won’t be part of your transaction; instead, it will just run like any old PowerShell command. If you want a command to be part of a transaction then you need to add the –useTransaction parameter, like so:

New-ItemProperty -path HKCU:\Test -name TransactedValue -value "This is a test." -useTransaction
PS HKCU:\Test> Start-Transaction
PS HKCU:\Test> 1..2 | ForEach-Object {New-ItemProperty -path HKCU:\Test -name $_ -useTransaction}

These commands will start a new transaction and create 2 new registry values as part of that transaction. You can use Get-ItemProperty (don’t forget the –useTransaction parameter) to view the transaction, and use Undo-PSTransaction and Complete-PSTransaction to rollback and complete the transaction, respectively.
Give it a try; after all, what do you have to lose?
Hey, that’s right: as long as you use a transaction then you’ve got nothing to lose, do you?                      
#>

# Module10-Providers.Section3-ProviderCmdlets.Lesson2-DriveCmdlets

Get-PSDrive

<#
Name           Used (GB)     Free (GB) Provider      Root                                                                                                                                                  CurrentLocation
----           ---------     --------- --------      ----                                                                                                                                                  ---------------
Alias                                  Alias                                                                                                                                                                              
C                 166.93         69.97 FileSystem    C:\                                                                                                                                                    Users\prestopa
Cert                                   Certificate   \                                                                                                                                                                    
Env                                    Environment                                                                                                                                                                        
Function                               Function                                                                                                                                                                           
HKCU                                   Registry      HKEY_CURRENT_USER                                                                                                                                                    
HKLM                                   Registry      HKEY_LOCAL_MACHINE                                                                                                                                                   
Variable                               Variable                                                                                                                                                                           
WSMan                                  WSMan    
#>

# Create a user-defined drive
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

# Creates a user-defined drive (use only single letter name with persist)
New-PSDrive -Name H -PSProvider FileSystem -Root \\2012R2-MS\HomeShare -Persist -Credential (Get-Credential contoso\DanPark)

# Removes a PowerShell drive (user or built-in)
Remove-PSDrive -Name HKCR

# Module10-Providers.Section3-ProviderCmdlets.Lesson3-ItemCmdlets

# Item Cmdlets

# Remove-Item
Get-ChildItem * -Include *.mp3 -Recurse | Remove-Item
# Set-Item
Set-Item -Path env:UserRole -Value Administrator
# Invoke-Item 
Invoke-Item -Path "c:\data\scripts\servers1.txt"
# New-Item 
New-Item -ItemType file -Path "c:\data\scripts\servers3.txt", "c:\data\scripts\servers4.txt"
# Rename-Item 
Rename-Item HKLM:\Software\Company -NewName Marketing -WhatIf

# Module10-Providers.Section4-ProviderCmdlets.Lesson4-ItemPropertyCmdlets

# Registry values are considered item properties, not items
Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1
Copy-ItemProperty -Path HKCU:\AppEvents\EventLabels -Destination HKCU:\AppEvents\EventLabels -Name MyProperty -WhatIf -Confirm
Get-ChildItem -Path "c:\data\scripts\servers1.txt" | Set-ItemProperty -Name IsReadOnly -Value $true -WhatIf -Confirm
Get-Item -Path HKCU:\AppEvents\EventLabels | New-ItemProperty -Name NoOfLocations -Value 3 -WhatIf -Confirm
Rename-ItemProperty -Path HKCU:\AppEvents\EventLabels -Name Close -NewName NewClose -WhatIf -Confirm

# Module10-Providers.Section4-ProviderCmdlets.Lesson5-ContentCmdlets
Get-Content "c:\data\scripts\servers2.txt" -TotalCount 5
Get-Content env:\CommonProgramFiles
Get-Content Function:\Get-IseSnippet
                                                                                                                                
$ContentPath = "c:\data\scripts\client1.txt"
Add-Content $ContentPath -Value "client1"
Clear-Content $ContentPath
Get-Content $ContentPath
Set-Content $ContentPath -Value "cient11"
Get-Content $Contentpath
Get-Date | Set-Content "c:\data\scripts\date.csv"
Get-Content -Path "c:\data\scripts\date.csv"

# Module10-Providers.Section4-ProviderCmdlets.Lesson6-LocationCmdlets

Get-Location
Set-Location -Path HKLM:\SOFTWARE
Set-Location $home
Push-Location
Set-Location c:\
Pop-Location

# Module10-Providers.Section4-ProviderCmdlets.Lesson7-PathCmdlets

# Use path cmdlets for navigation with various providers

Test-Path C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NewerThan "July 13, 2009"
Join-Path -Path c: -ChildPath Temp
Split-Path -Path $profile -Leaf
Resolve-Path c:\prog*T
Convert-Path .
Convert-path ~
Convert-Path HKLM:\SOFTWARE\Microsoft

# Variable syntax - access PSDrive items
$alias:dir
$env:windir
$function:more
$variable:ref

# Module11-VariablesAndDataTypes.Section1-Variables.Lesson1-WhatAreVariables?

# Unit of memory
# Defined and accessed using a dollar sign prefix ($)
# Holds object or collection of objects
# Variable names can include spaces and special characters
# Non case-sensitive
# Types
# 1. Automatic (built-in): $home
# 2. Preference: $ErrorActionPreference
# 3. User-defined
# NOTE: Variable names that include special characters and/or spaces are difficult to use and should be avoided

# Module11-VariablesAndDataTypes.Section2-KindsOfVariables.Lesson1-AutomaticVariables
# 1. Built-in
# 2. Created and maintained by PowerShell
# 3. Store PowerShell state
# Examples
$Error # List of all errors
$? # Execution status of last command
$HOME # Users' home directory
$host # Current host application for PowerShell
$null # NULL or empty value
$PSHOME # Full path of installation directory for PowerShell
$true # Represents TRUE in commands
$false # Represents FALSE in commands

# Module11-VariablesAndDataTypes.Section2-KindsOfVariables.Lesson2-UserDefinedVariables

# 1. Created and maintained by user
# 2. Exist only in current session
# 3. Lost when session is closed

# Variable Cmdlets
New-Variable ZipCode -Value 98033
$ZipCode
$ZipCode.GetType()
Clear-Variable -Name ZipCode
$ZipCode
Remove-Variable -Name ZipCode -WhatIf
Set-Variable -Name ZipCode -Value 30045
$ZipCode
Set-Variable -Name desc -Value "Description"

# Constant Variables
# 1. Variables can only be made constant at creation (can not use "=")
# 2. Cannot be deleted
# 3. Cannot be changed

New-Variable -Name pi -Value 3.1415926 -Option Constant -WhatIf

# S364: ReadOnly Variables
# * Can not mark variable ReadOnly with "="
# * Can not be easily deleted (must use Remove-Variable with -Force)
# * Can not be changed with "=" (must use Set-Variable with -Force)
New-Variable -Name roMaxVal -Value 256 -Option ReadOnly

# S365: User-Defined Variable
$svcs = Get-Service
$svcs

# S366: Variables and Data Types
# In PowerShell:
# * Everything is an OBJECT
# * Each OBJECT has a TYPE
# * Variables reference OBJECTS

# Module11-VariablesAndDataTypes.Section3-StringType.Lesson1-LiteralStrings

# S368: Literal Strings
# Create a variable
$a = 123
# Include the variable in a literal string (single-quotes)
$b = 'As easy as $a'
# Notice that $a is not expanded
$b

# Module11-VariablesAndDataTypes.Section3-StringType.Lesson2-ExpandableStrings

# S370: Expandable Strings
# Create a varaible
$a = 123
# Include the variable in an expandable string (double-quotes)
$b = "As easy as $a"
# Notice that $a is expanded
$b

# S372: Literal or Expandable String Spanning Multiple Lines
# Literal string (CRLF only works from PowerShell console, not from ISE)
$LString = '
As
Easy
as
$a
'
$LString

# Expandable String (CRLF only works from PowerShell console, not from ISE)
$EString = "
As
easy
as 
$a
"
$EString

# Module11-VariablesAndDataTypes.Section3-StringType.Lesson3-HereStrings
# S373: Here Strings
# Example: 
# * Simplify use of longer, more complex string assignments
# * Here String cann contain quotes, @ sign, etc.
$LHere = @'
As
'easy'
as
$a
'@

$LHere

$EHere = @"
As
"easy"
as
$a
"@

$EHere

# Example - Custom 01
# C:\Users\prestopa\OneDrive\02.00.00.GENERAL\02.15.00.IT\02.15.02.SW\SOLUTIONS\00-GIT-PRV\FILE-SYSTEM\Add-NewDirectoryAndFilesWithContent.ps1

# Module11-VariablesAndDataTypes.Section3-StringType.Lesson4-VariableSub-Expression

# S376: Variable Sub-Expression $(...)
#* Returns the result of one or more enclosed statements
#* Can be used to access an object property and concatenate its value with an expanding string
# Create a variable
$a = Get-Service -Name ALG
# Determine the variable type
$a.GetType().FullName
# Use variable in a string-Retuns the type
Write-Host "Service: $a"
# Try to use a property of the variable in a string -The property is not expanded
Write-Host "Service: $a.name"
# Create a variable sub-expression that includes the property
Write-Host "Service: $($a.name)"

# Module11-VariablesAndDataTypes.Section4-OtherTypes.Lesson1-OtherTypes

# S378: Other Data Types
# Alias    Full Name       Description
# Object   System.Object   Every type in PowerShell is derived from object
# Boolean  System.Boolean  $true and $false
# Char     System.Char     Stores UTF-16-ecoded 16-bit Unicode point
# Int      System.Int32    -2147483658 to 2147483647
# Long     System.Int64    -9223372036854775808 to 9223372036854775807
# Double   System.Double   Double-precision floating-point number
# Enum     System.Enum     Defines a set of named constants
# Array    System.Array    One or more dimensions ith 0 or more elements
# DateTime System.DateTime Store date and time values

# Module11-VariablesAndDataTypes.Section5-UsingTypes.Lesson1-UsingTypes

# 380: What object type am I using?
(1024).GetType().FullName
(1.6).GetType().FullName
(1tb).GetType().FullName

# S381: Type Casting
# * You can control object types
# * [Square Brackets' in front of an object will force that type
# * In ste brackets use any valid object type name
# * Some common types have simpler type alias'
[system.int32]1.6
$MyNumber = [int]"000123"
$MyNumber
$MyNumber.GetType().FullName

# S382: Variables can by Strongly Typed
# * Variables are weakly typed by default
# * Type cast the variable name during creation to strongly type
# * Variable will only hold that type of object
# Weekly Typed Variable
$var1 = [int]1.3
$var1

$var = 1.2
$var

# Strongly Typed Variable
[int]$var1 = 1.3
$var1
$var1 = 1.2
$var1

# S383: Strong Typig a Variable
[int]$var1 = 123.5
$var1
[string]$var2 = 987.6
$var2
$var1.GetType().FullName; $var2.GetType().FullName
System.Int32
System.String
$var1 = "Fred"

# S384: Static Members
# * Callable w/o having to create an instance of a type
# * Accessed by type name (not instance name)
# * Accessed using the Static Operator ::

# S385: Discover Static Members
# A type can be used in PowerShell using square brackets
[char]
# Use Get-Member -Static to discover 'useful' members
[char] | Get-Member -Static
# Get-Member w/o -Static discovers members that provide information about the type
[char] | Get-Member 
# Calling a STATIC member
$c = "c"
[char]::IsUpper($c)
[char]::IsWhiteSpace(" ")

# S386: Print ASCII Table
33..126 | ForEach-Object {
Write-Host "Decimal: $_ = Character: $([char]$_)"
}

# Function to create a random string of 12 characters from each of the password complexity requirements set (Uppercase, Lowercase, Special and Numeric)
Function Create-RandomString
{
 # Initialize array consisting of all possible complexity rules characters
 $CombinedCharArray = @()
 # Initialize array of each complexity rule set (Uppercase, Lowercase, Special and Numeric)
 $ComplexityRuleSets = @()
 # Initialize constructed password consisting of a total of 12 characters, with 3 characters from each of the 4 complexity rules
 $PasswordArray = @()
 # Number of samples taken from each of the 4 complexity rules to construct the generated password string
 $PCRSampleCount = 3

 # Alphabetic uppercase complexity rule
 $PCR1AlphaUpper = ([char[]]([char]65..[char]90))
 # Special characters complexity rule
 $PCR2SpecialChar = ([char[]]([char]33..[char]47)) + ([char[]]([char]58..[char]64)) + ([char[]]([char]92..[char]95)) + ([char[]]([char]123..[char]126))
 # Alphabetic lowercase complexity rule 
 $PCR3AlphaLower = ([char[]]([char]97..[char]122))
 # Numeric complexity rule
 $PCR4Numeric = ([char[]]([char]48..[char]57))
 # Combine all complexity rules arrays into one consolidated array for all possible character values
 $CombinedCharArray = $PCR1AlphaUpper + $PCR2SpecialChar + $PCR3AlphaLower + $PCR4Numeric
 # Construct an array of all 4 complexity rule sets
 $ComplexityRuleSets = ($PCR1AlphaUpper, $PCR2SpecialChar, $PCR3AlphaLower, $PCR4Numeric)

 # Generate a specified set of characters from each of the 4 complexity rule sets
 ForEach ($ComplexityRuleSet in $ComplexityRuleSets)
 {
  Get-Random -InputObject $ComplexityRuleSet -Count $PCRSampleCount | ForEach-Object { $PasswordArray += $_ }
 } #end ForEach

 [string]$RandomStringWithSpaces = $PasswordArray
 $RandomString = $RandomStringWithSpaces.Replace(" ","") 
 Write-Host "Randomly generated 12 character complex password: " $RandomString
} #end Function

# Module11-VariablesAndDataTypes.Section6-TypeOperators.Lesson1-TypeOperators

# S388: Type Operators - Test Object Types
$Now = Get-Date 
($Now) -is [DateTime]
($Now) -isnot [DateTime]

# S389: Type Cast via Operator
"12/27/2013" -as [datetime]
[datetime]"12/27/2013"

# Module11-VariablesAndDataTypes.Section7-Parsing.Lesson1-ParsingModes

# S391: Parsing Modes
# * Parser divides commands into "tokens"
# * Parser is in either EXPRESSION or ARGUMENT(command) mode depending on token
# * In expression mode, the parsing is conventional: strings must be quoted, numbers are always numbers
# * In argument mode, numbers are treated as numbers, but all other arguments are treated as expandable strings unless they begin with $, @, ', ", or (, which then becomes expressions.
2+2 # exp: 4
Write-Output -InputObject 2+2 # arg: "2+2"
Write-Output -InputObject (2+2) # exp: 4
$a = 2+2; $a # exp: 4
Write-Output $a # exp: 4
Write-Output $a/H # arg: "4/H" (treated as expandable string)
Get-ChildItem "C:\Program Files" # exp:
<#
 For more information, see: 
 1. Get-Help about_Parsing
 2. https://technet.microsoft.com/en-us/library/hh847892.aspx
 3. https://rkeithhill.wordpress.com/2007/11/24/effective-powershell-item-10-understanding-powershell-parsing-modes/
#>

# S393: Turn Argument Mode into Expression Mode with $()
# Get-Date is a token interpreted as an ARGUMENT by the parser and is not treated as an expression
Write-Host "The date is: Get-Date"
# $ changes the parsing mode to EXPRESSION
Write-Host "The date is: $(Get-Date)"
# NOTE: When a result is evaluated to it's value, it uses EXPRESSION mode

# S394: Turn Expression Mode into Argument Mode with &
$cmd = "Get-Process"
$cmd
& $cmd

# Module11-VariablesAndDataTypes.Section7-Parsing.Lesson2-EscapeCharacter

# S397: Escape Character
# * Assigns a special interpretation to characters that follow
# * Backtick (grave accent) `
# * ASCII 96
# Force a special character to be literal
$a = 123
Write-Host "`$a is $a"
# Force a literal character to be special
Write-Host "There are two line breaks 
`n `nhere. "
# Line continuation (must be last character on line)
Get-Service |
Where-Object name -EQ `
alg

# S398: Special Characters
# * Case sensitive
# * Only have effect within double quotes
# `0 Null
# `a Alert
# `b Backspace
# `f Form feed
# `n New line
# `r Carriage return
# `t Horizontal tab
# `v Vertical tab
Write-Host "1`t HTAB"
Write-Host "1 
`v`v`v VTAB"
# Send two beeps
# LOOKUP
for ($i = 0; $i -le 1; $i++){"`a"}

Get-Help about_Special_Characters

# Module11-VariablesAndDataTypes.Section7-Parsing.Lesson3-StopParsing

# S400: Stop Parsing
# * Stops PowerShell from interpreting input
# * Use when entering external command arguments (instead of escape characters)
# * Only takes effect until next newline or pipe character
# --%
icacls  c:\scripts/grant northamerica\prestopa: (CI)F
# Parenthases cause problems
# Use --% to stop PowerShell parsing

icacls c:\scripts --% /grant northamerica\prestopa:(CI)F

# sends the following command to the icacls program
C:\scripts /grant northamerica\prestopa:(CI)F

# Module12-Operators2.Section1-ArithmeticOperators.Lesson1-ArithmeticOperators

# S407: Arithmetic Operators
# + Adds integers; concateates strings, arrays & hash tables
6+2
"file" + "name"
# - Subtracts values, indicates negative values
6-2
-6+2
# * Multiplies integers; copies strings and arrays
6 * 2
"ABC" * 3
# / Divides values
6/2
# % Returns remainder of division (modulus)
7%2
# -shl Shift-left bitwise. 100 in binary is 1100100 -shl 2 = 110010000 (400)
100 -shl 2
# -shr Shift-right bitwise. 100 in binary is 1100100 -shr 1 = 110010 (50)
100 -shr 1

# Module12-Operators2.Section2-AssignmentOperators.Lesson1-AssignmentOperators

# = Sets variable
$integer = 100
# += Increases variable
$integer += 1
# -= Decreases variable
$integer -= 1
# *= Multiplies variable
$integer *= 2
# /= Divides variable
$integer /= 2
# %= Divides variable and assigns remainder to variable
$integer %= 3
# ++ Unary operator. Increases variable by 1
$integer++
# -- Unary operator. Decreases variable by 1
$integer--

# Module12-Operators2.Section3-BinaryOperators.Lesson1-BinaryOperators

# S411: Binary Operators
# Note: For an example of how this is use to determine or set file attributes, see http://powerschill.com/uncategorized/bitwise-operators/

<#
MemberName BinaryValue DecimalValue
-----------------------------------
ReadOnly   00000001          1 
Hidden     00000010          2 
System     00000100          4 
Directory  00010000         16 
Archive    00100000         32 
Device     01000000         64 
Normal     10000000        128 
Temporary  100000000       256 
SparseFile 1000000000      512 
Compressed 10000000000    2048 
Offline    100000000000   4096 
Encrypted  1000000000000 16384 
-----------------------------------
#>

# Checking an attribute (Hidden, -band)
# Archive 00100000
# Hidden  00000010
# ----------------
# Attribs 00100010 (Archive + Hidden) -bor
# Hidden  00000010 (Hidden)
# ----------------
# Result  00000010 (Hidden) -band

$File = Get-ChildItem C:\data\scripts\client1.txt -Force
$File.Attributes
If ($File.Attributes -band [System.IO.FileAttributes]::Hidden)
{
 Write-Host "Hidden Attribute Set"
} #end if
$File.Attributes
          
# Setting an attribute (Hidden, -bor)
# Archive 00100000 (Archive)
# Hidden  00000000 ()
# ----------------
# Attribs 00100000 (Archive)
# Hidden  00000010 (Hidden) -bor
# ---------------- 
# Atribs  00100010 (Archive + Hidden)
$File = Get-ChildItem C:\data\scripts\client1.txt -Force
$File.Attributes
$File.Attributes = ($File.Attributes -bor [System.IO.FileAttributes]::Hidden)
$File.Attributes

# Toggling an attribute (Hidden, -bxor)
$File = Get-ChildItem C:\data\scripts\client1.txt -Force
$File.Attributes
$File.Attributes = ($File.Attributes -bxor [System.IO.FileAttributes]::Hidden)
$File.Attributes

# Turn on
# Archive 00100000 (Archive)
# Hidden  00000000 ()
# ----------------
# Attribs 00100000 (Archive)
# Hidden  00000010 (Hidden) -bxor
# ---------------- 
# Attribs 00100010 (Archive)

# Turn off
# Attribs 00100010 (Archive + Hidden)
# Hidden  00000010 (Hidden) -bxor
# ---------------- 
# Attribs 00100000 (Archive)

# Removing an attribute (Hidden, -band, -bxor)
$File = Get-ChildItem C:\data\scripts\client1.txt -Force
$File.Attributes
If ($File.Attributes -band [System.IO.FileAttributes]::Hidden)
{ 
 $File.Attributes = ($File.Attributes -bxor [System.IO.FileAttributes]::Hidden)
} #end if
$File.Attributes

# Bitwise AND 1010 (10) -bAnd 0011 (3) = 0010 (2)
10 -band 3
# Bitwise OR (inclusive) 1010 (10) -bor 0011 (3) = 1011 (11)
10 -bor 3
# Bitwise OR (exlusive) 1010 (10) -bxor 0011 (3) = 1001 (9)
10 -bxor 3
# Bitwise NOT -bnot 1010 (10) = 0101 (-11)

# Module12-Operators2.Section4-SplitJoinAndReplaceOperators.Lesson1-SplitOperator

# S413: Split Operator
# Unary split -split <string>. Space is the default delimiter
-split "1 a b"
# Binary split <string -split <delimiter>. Splits on comma as delimiter
"1,a b" -split ","

# Module12-Operators2.Section4-SplitJoinAndReplaceOperators.Lesson2-JoinOperator

# S415: Join Operator
# Unary join: -join <string[]>
-join ("a", "b", "c")
# Binary join: <String[]> -Join <Delimiter>
"Windows", "PowerShell", "4.0" -join [char]2
"Windows", "PowerShell", "4.0" -join ""
"Windows", "PowerShell", "4.0" -join "+"
"How","are","you","doing?" -join " "

# Module12-Operators2.Section4-SplitJoinAndReplaceOperators.Lesson3-ReplaceOperator

# S417: Replace Operator. <String[]> -Replace <Delimiter>
"Windows PowerShell 4.0" -replace "4.0","5.0"

# Module12-Operators2.Section5-FormatOperators.Lesson4-FormatOperator

# S419: Format Operator (-f)
# * Formats strings by using the format method of string objects
# * Format string on the left side of the operator
# * Objects to be formatted on the right side of the operator
# * Format specifiers enable the value to take multiple forms

# S420: Quick Examples
$MyArray = 'Smith','John',123.456
"Custom Text" -f $MyArray
"First name is: {1} Last name is: {0}" -f $MyArray
"{2}" -f $MyArray
"Using a Format Specifier {2:N2}" -f $MyArray

# Send output to both the console and log file and include a time-stamp
# http://windowsitpro.com/blog/what-does-powershells-cmdletbinding-do
Function LogWithTime
{
[CmdletBinding()] 
Param(
[Parameter(Mandatory=$True)]$LogEntry,
[Parameter(Mandatory=$True)]$LogPath
)
# Construct log time-stamp for indexing log entries
 # Get only the time stamp component of the date and time, starting with the "T" at position 10
$TimeIndex = (get-date -format o).ToString().Substring(10)
$TimeIndex = $TimeIndex.Substring(0,17)
"{0}: {1}" -f $TimeIndex,$LogEntry | Tee-Object -FilePath $LogPath -Append
# $Output | Tee-Object -FilePath $FilesObj.pLog -Append
} #end LogWithTime

$Log = "c:\data\logs\log.txt"

LogWithTime("Logging with time") -LogPath $Log
notepad $Log

# output
# T22:03:51.3998658: Logging with time
# T22:06:40.1688680: Logging with time

# S421: Format Operator - Index Example: {index[,alignmet][:FormatSpecifier]} -f "string(s)", "to be formatted"
"{1}{0}{2}{0}{3}{0}{4}" -f "-","Text","separated","with","dash"
# S422: Format Operator - Alignment Example:
"{1}{0,5}{2}" -f "-","Text","separated","with","dash"
# S423: Format Operator - FormatString Example 1
"{0:p} {1:p} {2:p}" -f 0.3,0.56,0.99
# S424
"{0:p0} {1:p1} {2:p2}" -f 0.3,0.56,0.99
# S425
"{0:n2}" -f 3.1415926
# S426
'{0:c} {1:c} {2:c}' -f 100.67,34,1340.78
# S427
'{0:hh}:{0:mm}:{0:ss}' -f (Get-Date)
'{0:HH}:{0:mm}:{0:ss}' -f (Get-Date)
# http://msdn.microsoft.com/en-us/library/26etazsy(v=vs.110).aspx

# Module13-Arrays.Section1-ArrayIntroduction.Lesson1-WhatAreArrays?

# S433: What are arrays?
# * Data structure storing a collection of items
# * Each item is in its own compartment
# * Items can be the same type or diferent types
# * Items can be accessed using index positions

# Module13-Arrays.Section2-UsingArrays.Lesson1-CreatingArrays

# S435: Creating Arrays
# Cmdlets that return multiple items
$processarray = Get-Process
# Assigning multiple values to a variable
$array = 22,5,10,8,12,9,8
# Array sub-expression operator. Typically used for initializing arrays to a null value
$b = @()

# Module13-Arrays.Section2-UsingArrays.Lesson2-AccessingArrayItems

# S437: Accessing Array Items
# Display all items in an array
$array
# First item in array - using index position
$array[0]
# Last item in array - using index position
$array[-1]
# Display first 3 items in array
$array[0..2]
# Display first item and last item in array
$array[0,-1]

# S438: Determine number of items in array
$array.Count
$array.Length

# Module13-Arrays.Section2-UsingArrays.Lesson3-AddingArrayItems

# S440: Add items to an array
$array += 999
$array

# Module13-Arrays.Section2-UsingArrays.Lesson4-SortingArrays

# S442: Sorting Array
# Sort-Object only sorts the console output - Array order is not changed internally
$array | Sort-Object -Descending
# Static method. Default sort order is ascending
# [array]::Sort($MyArray) <Lookup>
$myarray

# Module13-Arrays.Section2-UsingArrays.Lesson5-ModifyingArrayItems

# S445: Manipulating items in an array 
# Using an assignment operator
$array[0] = 100
$array
# Using array method
$array.Set(0,200)

# Module13-Arrays.Section2-UsingArrays.Lesson6-DetermineArrayObjectMembers

# S447: Determine array object members

# Piping to Get-Member discover item members - not array members

$array = 1,2,"cat"

# CORRECTION: Piping the array to the Get-Member Cmdlet returns the data type information of the objects containd within the array, not the array itself
$array | Get-Member

# In this case, $genArray | Get-Member would yield both System.Int AND System.String

<#
Output
----------------------
TypeName: System.Int32
#>

# To view the members (properties and methods) of the array itself (not the array contents), use the Get-Member Cmdlet's -Input Object parameter or
# $<array>.GetType()
Get-Member -InputObject $array

<#
Output
----------------------
TypeName: System.Object[]
#>

# Type-constrained array: Cast to a type whereby it contains an array of integers
[int[]]$intArray = 1,2,3,4,5,6,7,8,9,10


# Module14-HashTables.Section1-HashTableIntroduction.Lesson1-WhatAreHashTables?

# S453: What are hash tables?
# * Dictionary array form
# * Stores one or more key(name)/value pairs
# * Access value using corresponding key
# * Key must be unique
# * Efficient for retrieving data - constant search time
# * Get-Help about_Hash_Tables
# * See also: https://en.wikipedia.org/wiki/Hash_table
# * NOTE: The order of keys within a hash table is not determined, as they are based upon the hashes of the key string

# Module14-HashTables.Section1-HashTableIntroduction.Lesson2-CreatingHashTables?

# S455: Creating hash tables
# Initialize an empty hash table
$hash = @{}
# Create and populate a hash table
$Server = @{'HV-SRV-1'='192.168.1.1' ; Memory=64GB ; Serial='THX1138'}
$Server
# Create a hash table from here string data
$string = @"
Msg1 = Hello
Msg2 = Enter an email alias
Msg3 = Enter a username
Msg4 = Enter a domain name
"@ # end here string
$HashTable = ConvertFrom-StringData -StringData $string

$svcshash = Get-Service |
Group-Object Status -AsHashTable -AsString

$svcshash.Stopped
$svcshash.Running

# DIRECTORIES (DirsObj)
# Populate directories object 
# Add properties and values 
 $DirsObj = [PSCustomObject]@{
  # Non-Citrix enabled directories
  pSoftwarePath = "\\contoso.lab\wodc\oc\OIM\DOI\TO2\Windows\Deployment\Software"
  pLocalSW = "C:\Software"
  pDeployPath = "\\contoso.lab\wodc\oc\OIM\DOI\TO2\Windows\Deployment\DeploymentScript"
  pLogPath = "\\contoso.lab\wodc\OC\OIM\DOI\TO2\Common\DCSERVICESTEAM\TO1_TO_TO2_TURNOVER\SERVER\WINDOWS\DEPLOY_LOGS"
  pPrgmFilesX86 = "C:\Program Files (x86)"
  pEmetDir = "\\contoso.lab\wodc\oc\oim\doi\TO2\Windows\Software\Microsoft\EMET"
  pInstallDirNetIQx64 = "C:\Program Files (x86)\NetIQ\"
  pWMF4Path = "\\contoso.lab\wodc\OC\OIM\DOI\TO2\Windows\Software\Microsoft\WindowsManagementFramework4.0"
  pNBUx64ClientRemPath = "\\fdswp00301\x$\Software\NetBackup_7.6.0.1_Win\PC_Clnt\x64"
  pNBUx64PatchRemPath = "\\fdswp00301\x$\Software\NetBackup_7.6.0.1_Win\_NB_7.6.0.2.winnt.x64"
 } #end $DirsObj

 # Module14-HashTables.Section1-HashTableIntroduction.Lesson4-AccessingHashTableItems

 # S459: Access hash table items
 # Display all items in hash table
 $Server
 # Return value using dot notation
 $Server.'HV-SRV-1'
 $Server.Serial 
 # Return value using index notation
 $Server["Serial"]
 # Display all keys in hash table
 $Server.Keys 
 # Display all values in hash table
 $Server.Values
 
 # Module14-HashTables.Section1-HashTableIntroduction.Lesson4-ModifyingHashTableItems

 # S463: Manipulate hash table items
 # Add or set key and value using index notation
 $Server["CPUCores"] = 4
 # Add or set key and value using dot notation
 $Server.Drives = "C", "D", "E"
 # Add key and value using hash table ADD method
 $Server.Add("HotFixCount", (Get-HotFix -ComputerName $Server["HV-SRV-1"]).Count) 
 # Remove key
 $Server.Remove("HotFixCount")
 $Server.Remove("Serial")

 # Module14-HashTables.Section1-HashTableIntroduction.Lesson5-SortingHashTables
 # S465: Sorting hash tables
 # * Hash tables are intrinsically unordered
 # * It is not possible to sort a hash table
 # * GetEnumerator() method used with Sort-Object Cmdlet
 # Sort has table display by key
 $Server.GetEnumerator() | Sort-Object -Property key

 # Module14-HashTables.Section1-HashTableIntroduction.Lesson6-SearchingHashTables

 # S467: Searching a hash table
 $hash = @{"John"=23342;"Linda"=54345;"James"=65467}
 # Fast hashed key search
 $hash.ContainsKey("Linda")
 # Slow non-hased search
 $hash.ContainsValue(19)
 $hash.ContainsValue(65467)
 
 # Module14-HashTables.Section2-HashTableUseCases.Lesson1-HashTableExamples

 # S469: Calculated property
 # * Customizing property value on pipeline with Select-Object and a hash table
 # * Length property is in kilobytes and limited to 2 decimal points before displayed
 Get-ChildItem C:\Windows -File | Select-Object -Property FullName, @{Label="Size (KB)";Expression={"{0:N2}" -f ($_.Length/1kb)}}
 
 # S470: Splatting
 # Passing a hash table as parameters to a cmdlet, function or script
 $params = @{
 LogName = "application"
 Newest = 10
 EntryType = "Warning"
 } #end hash-table
 Get-EventLog @Params
 Get-EventLog -LogName Application -Newest 10 -EntryType Warning

 # S471: Custom PSObject (PS v2.0) - Ordering not Preserved
 $props = @{
  Computer = (Get-WmiObject -Class Win32_ComputerSystem).Name
  Name = (Get-NetAdapter -Physical | Where-Object {$_.Status -eq "up"}).Name
  Speed = (Get-NetAdapter -Physical | Where-Object {$_.Status -eq "up"}).LinkSpeed
 } #end hash-table
 $NewObj = New-Object PSObject -Property $Props
 $NewObj

 # S472: Custom PS object (PS v3.0+) - Ordering Preserved
 $props = [PSCustomObject]@{
  Computer = (Get-WmiObject -Class Win32_ComputerSystem).Name
  Name = (Get-NetAdapter -Physical | Where-Object {$_.Status -eq "up"}).Name
  Speed = (Get-NetAdapter -Physical | Where-Object {$_.Status -eq "up"}).LinkSpeed
 } #end hash-table
 $props

 # Module14-HashTables.Section3-OrderedDictionary.Lesson1-OrderedDictionary

 # S474: Ordered Dictionary
 # * Alternative to regular hash tables
 # * Works similarly to a hash table but order is preserved
 # * Ordered dictionaries differ from hash tables in that the keys always appear in the order in which you inserted them.
 # Order not preserved
 @{firstname = "John"; lastname = "smith"}
 # Insertion order preserved
 [ordered]@{firstname = "John"; lastname = "smith"}
 
 # See also: https://msdn.microsoft.com/en-us/library/system.collections.specialized.ordereddictionary(v=vs.110).aspx
 
 # Q1. What happens when you try to cast an existing hash table to [ordered]?
 # A1. Error. You cannot use the [ordered] attribute to convert or cast a hash table. If you place the ordered attribute before the variable name, the command fails.

 # Module15-FlowControl.Section1-Looping.Lesson1-TheFiveLoops
 
 # Loops in PowerShell repeat code
 # Five different logical variations
 # Name      Type          Features
 # --------------------------------
 # While     Conditional   Tests for $true condition
 # Do While  Conditional   Tests for $true condition. Code block runs at least once
 # Do Until  Conditional   Tests for $false condition. Code block runs at least once
 # For       Conditional   Tests for $true condition. Includes initialization and repeat blocks
 # ForEach   Enumeration   Runs code once for each item in collection/array. Choose automatic variable name
 
 # Module15-FlowControl.Section1-Looping.Lesson2-While
 # Runs script block while conditional test = true
 # (start)->[true]->yes:{run code} ->[true], no:->(end)
 $a = 0
 while ($a -lt 10) {$a; $a++}
 # Performing a numerical comparison against an unitialized variable will cause PowerShell to treat that number as 0.
 # When attempting to increment an uninitialized variable, PowerShell will start with a value of zero
 $ComputerName = '2012R2-DC'
 Restart-Computer -ComputerName $ComputerName
 Start-Sleep -Seconds 30
 While (-not(Test-Connection -ComputerName $ComputerName -Quiet))
 {
  "Waiting on restart: $ComputerName"
  Start-Sleep -Seconds 30
 } #end While
 # PowerShell v3.0 Restart-Computer introduced the -Wait parameter

 # While: Runs script block while conditional test = true
 While ($a -lt 10) {$a; $a++}
 # Do While: Condition is evaluated AFTER script block runs. Runs script block while conditional test = true
 Do {$a} While ($a++ -le 5)
 # Do Until: Condition evaluated AFTER script block runs
 Do {$a} Until ($a++ -gt 10)
 # (start)->{run code} ->[true], yes:->{run code}, no:->(end)

 # Module15-FlowControl.Section1-Looping.Lesson3-DoWhile

 # Condition is evaluated AFTER script block runs at least once. Run script block if conditional test = true
 $a = 0
 Do {$a; $a++} While ($a -le 5)
 
 # Module15-FlowControl.Section1-Looping.Lesson4-DoUntil
 
 # Condition evaluated AFTER script block runs at least once. Runs script block if conditional test = false
 Do {$a; $a++} Until ($a -gt 10)
 # (start)->{run code} ->[true], yes:->{run code}, no:->(end)
 $ComputerName = '2012R2-DC'
 Restart-Computer -ComputerName $ComputerName
 Do
 {
  "Waiting on restart: $ComputerName"
  Start-Sleep -Seconds 30
 } #end
 Until (Test-Connection -ComputerName $ComputerName -Quiet)
  
 # Module15-FlowControl.Section1-Looping.Lesson5-For

 # Runs script block while conditinal test = true. Useful when targeting a subset of array values
 # Syntax: For (<init>; <condition>; <increment>) {<statement list>}
 For ($a=1; $a -lt 10; $a++) {$a}
 # (start)->initialize->[true], yes:{run code}, increment->[true], no:End
 $Computers = @(Get-ADComputer -Filter {Operatingsystem -like "*server*"]}).Name 
 For ($i=0; $i -lt $Computers.Length; $i++)
 {
  "Computer $($i+1): $($Computers[$i])"
 } #end for

 # Module15-FlowControl.Section1-Looping.Lesson6-ForEach
 # Syntax: ForEach ($<item> in $<collection>) {<statement list>}
 ForEach ($File in Get-ChildItem $env:SystemRoot -File) {$File.Name}
 # (start)->ItemsInArray?-yes->Set Value of $<item> to current array/collection element->RunCode,no:end
 $Services = Get-Service
 'There are a total of ' + $Services.Count + ' services. '
 ForEach ($Service in $Services)
 {
  $Service.Name + ' is ' + $Service.Status
 } #end ForEach

 # Module15-FlowControl.Section2-Branching.Lesson1-IfStatement
 
 # Branching structure chooses which cod to run 
 # Optional - ElseIf(s) used for additional test(s)
 # Optional - Else code runs if test(s) fail
 # Only one code block will run
 # If (<test1>) {<statement list 1>}
 # [ElseIf (<test2>) {<statement list 2>}]
 # [ElseIf (<test3>) {<statement list 3>}]
 # [Else             {<statement list 4>}]

 # If
 $Language = (Get-CimInstance -ClassName Win32_OperatingSystem).OSLanguage
 if ($Language -eq "1033")
 {
  Write-Host "Language = English US" -ForegroundColor Magenta
 } #end if

# If...Else
$Language = (Get-CimInstance -class win32_operatingsystem).OSLanguage
if ($Language -eq "1033")
{
 write-Host "Language = English US" -ForegroundColor Magenta
} #end if
else
{
 Write-Host "Another Language" -ForegroundColor Cyan
} #end else

# If...[ElseIf]
$Language = (Get-CimInstance â€“ClassName Win32_OperatingSystem).OSLanguage
if ($Language -eq "1033")
{
 Write-Host "Language = English US" -ForegroundColor Magenta
} #end if
ElseIf ($Language â€“eq "1078")
{
 Write-Host "Language = Afrikaans" -Foregroundcolor Green
} #end elseif

# If...[ElseIf...Else]
$Language = (Get-CimInstance â€“ClassName Win32_OperatingSystem).OSLanguage
if ($Language -eq "1033")
{
 Write-Host "Language = English US" -ForegroundColor Magenta
} #end if
elseif ($Language â€“eq "1078")
{
 Write-Host "Language = Afrikaans" -Foregroundcolor Green
} #end elseif
else
{
 Write-Host "Another Language" -ForegroundColor Cyan
} #end else 

# Module15-FlowControl.Section2-Branching.Lesson2-BasicSwitchStatment

# SimpleSwitch
# Switch (<test-value>)
# { 
#  <condition 1> {<action 1>}
#  <condition 2> {<action 2>}
# } #End Switch

$DomainRole = (Get-CimInstance -class Win32_ComputerSytem).DomainRole
Switch ($DomainRole)
{
 0 { Write-Host "standalone workstation" }
 2 { Write-Host "standalone server" }
} #end switch
 
# Module15-FlowControl.Section2-Branching.Lesson3-SwitchStatmentDefaultCondition

# Switch (<test-value>)
# {
#  <condition 1> {<action 1>}
#  <condition 2> {<action 2>}
#  Default       {<action 3>} 
# } #end Switch 

$DomainRole = (Get-CimInstance -class Win32_ComputerSystem).DomainRole
Switch ($DomainRole)
{
 0 { Write-Host "standalone workstation" }
 2 { Write-Host "standalone server" }
 Default { Write-Host "other domain role" }
} #end Switch

# Module15-FlowControl.Section2-Branching.Lesson4-SwitchStatmentMultipleInputs

# Switch (<test-value-array>)
# {
#  <condition 1> {<action 1>}
#  Default       {<action 2>} 
# } #end Switch

$FileNames = (Get-ChildItem $env:SystemRoot).FullName
Switch -Wildcard ($FileNames)
{
 "*.exe" {"Found executable: $_"}
 Default {"Not an exe: $_"}
} #end Switch

Switch (123,200)
{
 123 { Write-Host $_ -ForegroundColor Green }
 200 { Write-Host $_ -ForegroundColor Cyan }
} #end Switch

# Switch with $_
$DomainRole = (Get-CimInstance -ClassName Win32_ComputerSystem).DomainRole
Switch ($DomainRole)
{
 1 {Write-Host "$_ : Member Workstation" }
 2 {Write-Host "$_ : Standalone Server"  }
} #end Switch

# Module15-FlowControl.Section2-Branching.Lesson5-SwitchStatement:Case

# Case-insensitive by default
Switch ("HELLO")
{
 "hello" {"lowercase"}
 "HELLO" {"UPPERCASE"}
} #end Switch

# Case-insensitive by default
Switch -CaseSensitive ("HELLO")
{
 "hello" {"lowercase"}
 "HELLO" {"UPPERCASE"}
} #end Switch

# Module15-FlowControl.Section2-Branching.Lesson6-SwitchStatement:Wildcard

# Without wildcard parameter
Switch (Get-ChildItem -Path c:\)
{
 "program*" { Write-Host $_ -ForegroundColor Green }
 "windows"  { Write-Host $_ -ForegroundColor Cyan  } 
} #end Switch

# With wildcard parameter
Switch -Wildcard (Get-ChildItem -Path c:\)
{
 "program*" { Write-Host $_ -ForegroundColor Green }
 "windows"  { Write-Host $_ -ForegroundColor Cyan  } 
} #end Switch

# Module15-FlowControl.Section2-Branching.Lesson7-SwitchStatement:Regex

Switch -Regex (Get-ChildItem -Path c:\)
{
 "^program" { Write-Host $_ -ForegroundColor Green } # Matches beginning character(s)
 "s$"       { Write-Host $_ -ForegroundColor Cyan  } # Matches end character(s)
} #end Switch
# Get-Help about_Regular_Expressions

# Module15-FlowControl.Section2-Branching.Lesson8-SwitchStatement:ExpressionMatch

Switch (123) 
{
 { $_ -lt 124 } { Write-Host $_ -ForegroundColor Green }
 { $_ -gt 200 } { Write-Host $_ -ForegroundColor Cyan }
} #end Switch

# Module15-FlowControl.Section2-Branching.Lesson9-SwitchStatement:FileProcessing

Switch -File C:\data\scripts\servers1.txt
{
 "server01" { Write-Host "$_ is in file" -ForegroundColor Green }
 "server10" { Write-Host "$_ is in file" -ForegroundColor Cyan }
} #end Switch


# Module15-FlowControl.Section2-Branching.Lesson10-IfAndSwitchStatementDifferences

# IF and SWITCH Differences
# IF statement terminates when a match is found
# SWITCH statement does not terminate when a match is found
# SWITCH is more suitable when multiple conditions are evaluated

# Module15-FlowControl.Section2-Branching.Lesson11-FlowControlKeywords

# Break: Immediately exits loop. Breaks afer 1 match to avoid multiple matches
Switch -Wildcard ("WMF 5.0")
{
 "WMF 5.0" { "Matched First" ; Break }
 "W*" { "Matched Second" }
} #end Switch

Switch -Wildcard ("WMF 5.0")
{
 "WMF 5.0" { "Matched First" }
 "W*" { "Matched Second" }
} #end Switch

# Continue: Not appliclable for conditional statements, but is more appropriate for loops
Switch -Wildcard ("WMF 5.0")
{
 "WMF 5.0" { "Matched First" ; Continue }
 "W*" { "Matched Second" }
} #end Switch

# Continue: Immediately returns to top of loop. Example skips over 2 (Write-Host $c) so there is no output to the console when c = 2
$c = 0
While ($c -lt 3)
{
 $c++
 if ($c -eq 2) { continue }
 Write-Host $c
} #end While

# Return: Exists curret 'scope', which can be a function, script, or script block
Function Test-Return ($val)
{
 if ($val -ge 5) { return $val }
 Write-Host "Reached end of function"
} #end Function
Test-Return 1

Function Test-Return ($val)
{
 if ($val -ge 5) { return $val }
 Write-Host "Reached end of function"
} #end Function
Test-Return 6

# Exit: Exits current script or session - Optional ErrorLevel Numeric Code

# Module16-Scope.Section1-ScopeIntroduction.Lesson1-WhatAreScopes?
# 1. Created when launching scripts or funcitons
# 2. Separate items in memory (like variables)
# 3. Avoid naming collisions
# 4. Terminates when script or function finishes
# 5. Determines lifetime and visibility of
#    a. Variables
#    b. Fuctions
#    c. Aliases
#    d. PSDrives
# Scope Rules
# 6. Items are visible: In the scope in which they are created and any child scope unless explicitly made 'private'
# 7. Items are changed/created: In current scope unless the scope is overridden
# 8. Lifetime expires when scope terminates
# 9. Global
#    a. When PowerShell starts
#    b. Includes automatic variables
#    c. Includes variables, aliases and functions in profiles
# 10.Local: Current scope, which can be global or any other scope
# 11.Script: Created when script runs
#    a. To commands in script, the script scope is the local scope
# 12.Private: Items cannot be seen outside of the current scope, including child scopes
# 13.Numbered
#    a. Scope 0 = current, or local
#    b. Scope 1 = immediate parent
#    c. Scope 2 = Parent of parent, etc
# Scope Modifiers Generic Syntax [<scope-modifier>]:<name>
# Keywords
# Global: Highest level scope per host
# Script: Nearest script scope
# Local: Current scope (Default)
# Private: Current scope, unavailable to children
# Variable Scope Modifier Syntax: $[<scope-modifier>]:<name> = <value>
# Example - Change or create a variable in global scope from another scope
$global:a = "one"
# Function Scope Modifier Syntax: function [<scope-modifier>]:<name> { <function-body> } 
# Make a function visible in global scope from a child scope
function global:Hello-World
{ Write-Host "Hello-World" }
 
# List items in a scope
Get-Variable -Scope Local
Get-PSDrive -Scope Local
Get-Alias -Scope Global
 
# Module16-Scope.Section3-DotSourceNotation.Lesson1-DotSourceNotation
# 1. By default, a child scope is created when a script or function runs
# 2. Dot-source does not create a child scope
# 3. Script or function runs in current scope and also subsequetly creates any new items in current scope
# 4. Item visibility does not terminate with the script or function
. C:\DATA\scripts\HelloWorld.ps1
Get-Content C:\DATA\scripts\HelloWorld.ps1

# Dot Source Function 
function Get-SysLogNN
{
 param($Log, $NumberOfEvents)
 $Logevts = Get-EventLog -LogName $Log -Newest $NumberOfEvents
} #end function

 . Get-SysLogNN -log System -NumberOfEvents 2

# $logevts variable is now available in scope where function was called from

$DemoPath = "C:\Users\prestopa\OneDrive\02.00.00.GENERAL\02.15.00.IT\02.15.02.SW\SOLUTIONS\00-GIT-PRV\DEMO\PSp1-v4.0"
$ScriptScope = "0.Global"
Write-Host -ForegroundColor Green "Before invoking script; Current Scope: " $ScriptScope
. $DemoPath\Demo-ScriptScope.ps1
Write-Host -ForegroundColor Green "After invoking script; Current Scope: " $ScriptScope

# Module16-Scope.Section4-Profiles.Lesson1-Profiles

# To create your profile:

New-Item -path $Profile -ItemType File -Force

# To open your current profile in the ISE
ise $Profile.CurrentUserCurrentHost

# Profile Paths Common to ISE and Console
# Scope: CurrentUser,AllHosts Name:$Home\Documents\WindowsPowerShell\profile.ps1
# Scope: AllUsers,AllHosts Name:$PsHome\profile.ps1

# ISE Only Profile Paths
# Scope: CurrentUser,CurrentHost Name:$Home\Documents\WindowsPowerShell\MicrosoftPowerShellISE_profile.ps1
# Scope: AllUsers,CurrentHosts Name:$PsHome\MicrosoftPowerShellISE_profile.ps1

# Console Only Profile Paths [Note - no "ISE" in the filenames]
# Scope: CurrentAUser,CurrentHost Name: $Home\Documents\WindowsPowerShell\MicrosoftPowerShell_profile.ps1
# Scope: AllUsers,CurrentHost Name: $PsHome\Microsoft.PowerShell_profile.ps1

# Listing profile paths
$profile | Format-List -Property * -force

# A start-up script that runs every time PowerShell starts
# Any valid PowerShell script can be in a profile
# Profiles are not exempt from execution policy
# Four possible profile scripts for host
# 1. Start PowerShell
# 2. Execute Profile Scripts
# 2a.Profile1.AllUsers,AllHosts
# 2b.Profile2.AllUsers,CurrentHost
# 2c.Profile3.CurrentUser,AllHosts
# 2d.CurrentUser,CurrentHost [Last run has highest priority]
# PS:/>

# $Profile
# $Profile (automatic variable) holds expected path for all four profiles
# Paths are relative to each host/computer
# Profile must be created manually
# Profile Scopes:
# Scope:CurrentUser,CurrentHost Name:$Profile or $Profile.CurrentUserCurrentHost
# Scope:CurrentUser,AllHosts Name: $Profile.CurrentUserAllHosts
# Scope:AllUsers,CurrentHosts Name: $Profile.AllUsersCurrentHosts
# Scope:AllUsers,AllHosts Name: $Profile.AllUsersAllHosts 

# Static Methods
$AvailableConsoleColors = [Enum]::GetValues([ConsoleColor])

# Change console foreground color 
$host.ui.RawUI.ForegroundColor = "Green"