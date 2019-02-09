
# Primary reference
Get-Help New-PSSessionConfigurationFile -ShowWindow
# Secondary references
Get-Help about_Language_Modes -ShowWindow
Get-Help about_Session_Configurations -ShowWindow
Get-Help about_Session_Configuration_Files -ShowWindow
Get-Help Set-PSSessionConfiguration -ShowWindow


<#
Windows PowerShell supports the following language modes:
-FullLanguage
    -Default
-ConstrainedLanguage (introduced in Windows PowerShell 3.0)
    -Designed to support User Mode Code Integrity (UMCI) on Windows RT.
    -Full language but limits types
-RestrictedLanguage
    -Commands but not scriptblocks
    -Allowed variables: $PSCulture, $PSUICulture, $True, $False, $Null
    -Allowed comparison operators: -eq, -gt, -lt
    -Not allowed: assignments, property refernces, method calls
-NoLanguage
    -Commands only
    -No language elements

The default value of the LanguageMode parameter depends on the value
of the SessionType parameter.
-- Empty                   :  NoLanguage
-- RestrictedRemoteServer  :  NoLanguage
-- Default                 :  FullLanguage


SessionType

-- Empty: No modules or snap-ins are added to session by default. Use
the parameters of this cmdlet to add modules, functions, scripts, and
other features to the session. This option is designed for you to
create custom sessions by adding selected command. If you do not add
commands to an empty session, the session is limited to expressions
and might not be usable.

-- Default: Adds the Microsoft.PowerShell.Core snap-in to the session.
This snap-in includes the Import-Module and Add-PSSnapin cmdlets that
users can use to import other modules and snap-ins unless you
explicitly prohibit the use of the cmdlets.

-- RestrictedRemoteServer: Includes only the following proxy
functions:  Exit-PSSession,Get-Command, Get-FormatData, Get-Help,
Measure-Object, Out-Default, and Select-Object. Use the parameters of
this cmdlet to add modules, functions, scripts, and other features to
the session.



Visible

The Visible parameters, such as VisibleCmdlets and VisibleProviders,
do not import items into the session. Instead, they select from among
the items imported into the session.

#>

# Only returns LanguageMode for session configurations having a PSSC file.
(Get-PSSessionConfiguration -Name Test).LanguageMode

# Current session
$ExecutionContext.SessionState.LanguageMode



<#
RESTRICTED ENDPOINT
Connect as DanPark
Run as Administrator
Import AD module
Unlock accounts
Reset passwords
#>

$Parameters = @{
    Path = '.\HelpDeskAD.pssc'
    SessionType = 'RestrictedRemoteServer'
    ModulesToImport = 'ActiveDirectory'
    VisibleProviders = 'ActiveDirectory'
    VisibleCmdlets = 'Unlock-ADAccount','Set-ADAccountPassword'
}

New-PSSessionConfigurationFile @Parameters
ise .\HelpDeskAD.pssc
Test-PSSessionConfigurationFile .\HelpDesk.pssc

Register-PSSessionConfiguration `
    -Path .\HelpDeskAD.pssc `
    -Name HelpDeskAD `
    -ShowSecurityDescriptorUI `
    -RunAsCredential (Get-Credential Contoso\Administrator) `
    -Force -Confirm:$false

Get-PSSessionConfiguration -Name HelpDeskAD | fl *

Enter-PSSession -ConfigurationName HelpDeskAD -ComputerName . -Credential Contoso\DanPark

Get-Command

Unlock-ADAccount Guest

Exit-PSSession


Unregister-PSSessionConfiguration HelpDeskAD -Force -Confirm:$false
Remove-Item .\HelpDeskAD.pssc
