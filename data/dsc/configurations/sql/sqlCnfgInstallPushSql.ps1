#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Configure an SQL server using push DSC and an external configuration data file

.DESCRIPTION
This script includes a DSC configuration to build a set of SQL servers for an AlwaysOn AG cluster of 3 servers in an existing domain.

.PARAMETER domainAdminCred
Domain administrator username and password.

.EXAMPLE
Complile configuration
adsCnfgInstallPushSql -OutputPath $sqlMofPath -domainAdminCred $domainAdminCred -ConfigurationData $ConfigDataPath

# Configure target LCM
Set-DscLocalConfigurationManager -Path $devMofPath -ComputerName $targetNode -Verbose -Force

# Apply configuration to target
Start-DscConfiguration -Path $sqlMofPath -ComputerName $targetNode -Wait -Verbose -Force

.NOTES
The MIT License (MIT)
Copyright (c) 2019 Preston K. Parsard

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.LINK
1. https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-with-powershell-desired-state-configuration?view=sql-server-2017
2. https://colinsalmcorner.com/post/install-and-configure-sql-server-using-powershell-dsc
3. Getting Started with PowerShell DSC: Securing domainAdminCreds in MOF Files | packtpub.com: https://youtu.be/2nsCQ32Ufx0
4. https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
.COMPONENT
Windows PowerShell Desired State Configuration, ActiveDirectory

.ROLE
SQL DBA
SQL Developer
Systems Engineer
DevOps Engineer
Active Directory Engineer

.FUNCTIONALITY
Configures a member server as a new sql server in an existing domain.
#>

# 1. Pre-installation task for the OS
# Set the source installation path for SQL 2016 developer edition
$targetSqlServer = "cltsql1003.dev.adatum.com"

$sqlInstallPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\0000-apps\sql\SqlServer2016x64"
$targetDirRemote = $sqlInstallPath | Split-Path -leaf
$testTargetPath = "\\" + $targetSqlServer + "\c$\" + $targetDirRemote
$sqlFileName = "setup.exe"
$ssmsInstallPath = "\\cltdev1001.dev.adatum.com\apps\sql"
# $isoFileName = "en_sql_server_2016_developer_with_service_pack_1_x64_dvd_9548071.iso"
# https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
$ssmsFileName = "SSMS-Setup-ENU.exe"
# $localInstallPath = "c:\sql2016"
$ssmsFilePath = Join-Path -Path $ssmsInstallPath -ChildPath $ssmsFileName -Verbose
$sqlFilePath = Join-Path -Path $sqlInstallPath -ChildPath $sqlFileName -Verbose
$sqlFilePathTarget = "C:\"

# 1.1 Copy installation files to target

$targetSession = New-PSSession -ComputerName $targetSqlServer
if (-not(Test-Path -Path $testTargetPath))
{
    Copy-Item -ToSession $targetSession -Path $sqlInstallPath -Destination $sqlFilePathTarget -Recurse
} # end if
Remove-PSSession -Session $targetSession 

# 2. Add modules
$moduleList = "dbatools","SqlServer","SqlServerDsc","xStorage","xPendingReboot","xComputerManagement"
# 3. Trust PowerShell Gallery for downloading and installing modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$targetUserOU = "OU=service,OU=accounts,DC=dev,DC=adatum,DC=com"

# Install ActiveDirectory PowerShell module if required
If (-not(Get-WindowsFeature -Name RSAT-AD-PowerShell).InstallState)
{
    Install-WindowsFeature -Name RSAT-AD-PowerShell
} # end if

$adDomainObject = Get-ADDomain
# Get DNS root for server parameter
$adsServer = $adDomainObject.DnsRoot
# Find target SQL service account
$targetSqlUser = (Get-ADUser -Filter { SamAccountName -eq 'svc.sql.user' } -SearchBase $targetUserOU -server $adsServer).SamAccountName

# Write-Debug "$targetSqlUser `t $targetSqlSamAccountName" -Debug
# Abort if SQL service accout isn't found
If (-not($targetSqlUser))
{
    Write-Output "The SQL service account $targetSqlUser was not found in the $targetUserOU in Active Directory"
    Write-Output "Please add this user and try again"
    Write-Output "Press any key to terminate script"
    Pause
    Exit
} # end if

ForEach ($module in $moduleList)
{
    If (-not(Get-InstalledModule -Name $module -ErrorAction SilentlyContinue))
    {
        Install-Module -Name $module -Verbose -Force
    } # end if
    else
    {
        Update-Module -Name $module -Verbose -Force
    } # end else
} # end for

#region DSC Configuration
Configuration sqlCnfgInstallPush03
{
	Param
	(
        [Parameter(Mandatory=$true)]
        [pscredential]$sqlCredential,
        [Parameter(Mandatory=$true)]
        [pscredential]$adminCredential,
        [Parameter(Mandatory=$true)]
        [string[]]$dscResourceList,
        [string]$ensure = "present",
        [Parameter(Mandatory=$true)]
        [string]$sqlFilePath,
        [Parameter(Mandatory=$true)]
        [string]$ssmsFilePath
	) # end param

    # Convert $sqlCredentials to NetBIOS format [NETBIOSdomainname\username]
    # $domainSqlUserNetBIOS = $sqlCredenital.UserName

    Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Import-DscResource -ModuleName PSDesiredStateConfiguration, xComputerManagement, xStorage, xPendingReboot, sqlServerDsc

	Node $AllNodes.NodeName
	{
  		LocalConfigurationManager
		{
			ConfigurationMode = 'ApplyAndAutoCorrect'
			RebootNodeIfNeeded = $true
			ActionAfterReboot = 'ContinueConfiguration'
			AllowModuleOverwrite = $true
		} # end LCM

        WindowsFeature "NET-Framework-45-core"
        {
            Ensure = $ensure
            Name = "NET-Framework-45-core"
        } # end resource

        WindowsFeature "Failover-Clustering"
        {
            Ensure = $ensure
            Name = "Failover-Clustering"
            DependsOn = "[WindowsFeature]NET-Framework-45-core"
        } # end resource
        
		xDisk ConfigureDataDisk
		{
			DiskId = $node.dataDiskNumber
			DriveLetter = $node.dataDiskDriveLetter
            FSFormat = $node.FSFormat
            FSLabel = $node.dataFsLabel
		} # end resource

		xDisk ConfigureLogsDisk
		{
			DiskId = $node.logsDiskNumber
			DriveLetter = $node.logsDiskDriveLetter
            FSFormat = $node.FSFormat
            FSLabel = $node.logsFsLabel
		} # end resource

		xDisk ConfigureTempDisk
		{
			DiskId = $node.tempDiskNumber
			DriveLetter = $node.tempDiskDriveLetter
            FSFormat = $node.FSFormat
            FSLabel = $node.tempFsLabel
		} # end resource

		xDisk ConfigureMstrDisk
		{
			DiskId = $node.mstrDiskNumber
			DriveLetter = $node.mstrDiskDriveLetter
            FSFormat = $node.FSFormat
            FSLabel = $node.mstrFSLabel
        } # end resource

        File DataPath
        {          
            Ensure = $ensure
            # DestinationPath = $node.SQLUserDBDir
            # DestinationPath = "s:\data"
            DestinationPath = "$($node.SQLUserDBDir)"
            Type = 'Directory'
            DependsOn = "[xDisk]ConfigureDataDisk"
        } # end resource

        File LogsPath
        {
            Ensure = $ensure
            # DestinationPath = $node.SQLUserDBLogDir
            # DestinationPath = "l:\logs"
            DestinationPath = "$($node.SQLUserDBLogDir)"
            Type = 'Directory'
            DependsOn = "[xDisk]ConfigureLogsDisk"
        } # end resource

        File TempPath
        {
            Ensure = $ensure
            # DestinationPath = $node.SQLTempDBDir
            # DestinationPath = "t:\temp"
            DestinationPath = "$($node.SQLTempDBDir)"
            Type = 'Directory'
            DependsOn = "[xDisk]ConfigureTempDisk"
            } # end resource

        File MstrPath
        {
            Ensure = $ensure
            # DestinationPath = $node.sqlinstalldatadir
            # DestinationPath = "m:\mstr"
            DestinationPath = "$($node.InstallSQLDataDir)"
            Type = 'Directory'
            DependsOn = "[xDisk]ConfigureMstrDisk"
        } # end resource

        File BckpPath 
        {
            Ensure = $ensure
            # DestinationPath = $node.SQLBackupDir
            # DestinationPath = "c:\bckp"
            DestinationPath = "$($node.SQLBackupDir)"
            Type = 'Directory'
        } # end resource

        # Add SQL service account to local adminstrators group
        # TASK-ITEM: This is a non-priviledged domain user account that must have already been provisioned
        # https://docs.microsoft.com/en-us/powershell/dsc/resources/resources
        # https://blogs.msdn.microsoft.com/brian_farnhill/2017/07/04/getting-ids-to-use-with-the-package-dsc-resource/
        # http://itproguru.com/expert/2014/09/how-to-fix-login-failed-for-user-microsoft-sql-server-error-18456-step-by-step-add-sql-administrator-to-sql-management-studio/

        # TASK-ITEM: comment out to test adding sql service account via Add-LocalGroupMember cmdlet
        Group AddSqlUserToAdmins
        {
            GroupName = "$($node.sqlSysAdminAccounts)"
            Ensure = $ensure
            MembersToInclude = @("$($node.SqlServiceAccount)")
            Description = "SQL domain level service account"
            Credential = $adminCredential
            PsDscRunAsCredential = $adminCredential
        } # end resource

        # https://github.com/PowerShell/SqlServerDsc#sqlsetup
        # https://chrislumnah.com/2017/03/07/dsc-install-of-sql-server/

        SqlSetup "InstallDefaultInstance"
        {
            InstanceName = "$($node.instanceName)"
            Features = "$($node.sqlFeatures)"
            SourcePath = "$($node.InstallFromPath)"
            SQLSysAdminAccounts = @("$($node.SqlServiceAccount)")
            SqlSvcStartupType = "$($node.SqlSvcStartupType)"
            SQLUserDBDir = "$($node.SQLUserDBDir)"
            SQLUserDBLogDir = "$($node.SQLUserDBLogDir)"
            SQLTempDBDir = "$($node.SQLTempDBDir)"
            SQLTempDBLogDir = "$($node.SQLTempDBLogDir)"
            InstallSQLDataDir = "$($node.InstallSQLDataDir)"
            SQLBackupDir = "$($node.SQLUserDBDir)"
            ForceReboot = $false
            DependsOn = @("[File]MstrPath","[File]TempPath","[File]LogsPath","[File]DataPath","[Group]AddSqlUserToAdmins")
        } # end resource

        # https://enterinit.com/sql-server-2016-windows-server-2016-firewall-rule-step-by-step/
        SqlServerLogin ServiceAccount
        {
            Ensure = $ensure 
            InstanceName = "$($node.instanceName)"
            ServerName = $targetSqlServer
            Name = "$($node.SqlServiceAccount)"
            LoginType = "$($node.loginType)"
            PsDscRunAsCredential = $adminCredential
            DependsOn = "[SqlSetup]InstallDefaultInstance"
        } # end resource

        # TASK-ITEM add SMSS installation
        # https://powershell.org/forums/topic/installing-an-exe-with-powershell-dsc-package-resource-gets-return-code-1619/
        # https://sqlwhisper.wordpress.com/2016/06/05/install-ssms-from-command-prompt/
        # https://www.msigeek.com/715/how-to-troubleshoot-the-error-1603-fatal-error-during-installation

        Package "SMSS"
        {
            Ensure = $ensure
            Name = "SMSS"
            Path = $ssmsFilePath
            ProductId = ""
            Arguments = '/Install /quiet /norestart' 
            LogPath = 'c:\Windows\Temp\log.txt'
            DependsOn = "[SqlSetup]InstallDefaultInstance"
        } # end resource 

        xPendingReboot Reboot1
        {
           Name = "RebootServer"
           DependsOn = "[Package]SMSS"
        } # end resource
	} # end node
} # end configuration
#endregion

#region Intialize values
# 4. Set MOF path
$sqlMofPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\mof"
# 5. Set ConfigData path
$ConfigDataPath = "F:\data\OneDrive\02.00.00.GENERAL\repos\git\0026-azure-automation-plus-dsc-lab\data\dsc\ConfigData\sql\sqlDataInstallPushSql.psd1"
<#
TASK-ITEM: Turn on print and file sharing (SMB-in) in group policies for target nodes using GROUP POLICY advanced firewall settings
Scope: Computer node
Group: File and Print Sharing
Direction: Inbound
1. Echo Request - ICMPv4-In
2. Echo Request - ICMPv6-In
3. LLMNR-UDP-In
4. SMB-In
#>
# 6. Select target node to configure by looking for the 01 series DC patter for dev.adatum.com the .. represents a 2 digit number that can vary by deployments
# TASK-ITEM: Change the filter to match a specific node for demonstration, otherwise filter for multiple nodes to demonstrate multiple simultaneous configurations 
$targetNodes = (Get-ADComputer -Filter *).DNSHostName | Where-Object {$_ -match 'cltsql1003'}
# 7. Get list of resources required for this configuration so that can be copied to the target node
$dscResourceList = @("xActiveDirectory", "xComputerManagement", "xStorage", "xPendingReboot", "sqlServerDsc")
# TASK-ITEM: Create array of module paths to copy to each node
#endregion 

#region main
# 8. Create a session to prepare the target node, i.e Install pre-requisite features
# TASK-ITEM: Create a function for the loop below
$separatorSingle = ("-"*100)
ForEach ($targetNode in $targetNodes)
{
    $targetNodeSession = New-PSSession -Name $targetNode
    # Obtain local source and remote destination resource modules paths to copy resources to target node
    $resourceModulePath = $env:PSModulePath -split ";" | Where-Object {$_ -match 'C:\\Program Files\\WindowsPowerShell'}
    $targetModulePaths = (Get-ChildItem -Path $resourceModulePath -Directory | Where-Object {$_.Name -in $dscResourceList}).FullName
    $uncTargetPath = $resourceModulePath.Replace('C:\',"\\$targetNode\C$\")
    # Copy resources to target node
    ForEach ($targetModulePath in $targetModulePaths)
    {
        $separatorSingle
        $resourceName = $targetModulePath | Split-Path -Leaf
        $uncTargetPathFull = Join-Path $uncTargetPath -ChildPath $resourceName
        Write-Verbose "`$resourceName: $resourceName" -Verbose
        Write-Verbose "`$targetmodulePath: $targetModulePath" -Verbose 
        Write-Verbose "`$uncTargetPath: $uncTargetPath" -Verbose
        If (-not(Test-Path -Path $uncTargetPathFull))
        {
            Write-Output "Copying DSC resources from local system to remote target..."
            # TASK-ITEM: Remove WhatIf for release
            Copy-Item -Path $targetModulePath -Destination $uncTargetPath -Recurse -Verbose
        } # end if
    } # end for

    # Install Dsc-service on target node if required
    If (-not(Get-WindowsFeature -ComputerName $targetNode -Name Dsc-Service).InstallState -eq 'Installed')
    {
        Invoke-Command -Session $targetNodeSession -ScriptBlock {
        Install-WindowsFeature -Name Dsc-service
        } # end scriptblock
    } # end if 
    Invoke-Command -Session $targetNodeSession -ScriptBlock {
        if (-not(Get-PackageProvider -Name Nuget -ErrorAction SilentlyContinue))
        {
            Install-PackageProvider -Name NuGet -Force
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        } # end if
    } # end scriptblock
    <#
    TASK-ITEM:
        CAUTION; sqlCredentials will not be encrypted. To understand the requi rements and see demo for how to encrypt, see:
        Getting Started with PowerShell DSC: Securing sqlCredentials in MOF Files | packtpub.com
        https://youtu.be/2nsCQ32Ufx0
    #>
    # Remove Session
    Remove-PSSession -Session $targetNodeSession
} # end foreach

# 9. Complile configuration
# TASK-ITEM: Change the configuration name here to match the configuration name above [after the 'Configuration keyword']
$sqlCred = (Get-Credential -Message "Enter password for:" -UserName $targetSqlUserNetBIOS)
$daCred = Get-Credential -Message "Enter domain or target server administrative username and password using the format: $nbDomainName\<adminUserName>"
sqlCnfgInstallPush03 -OutputPath $sqlMofPath -sqlCredential $sqlCred -adminCredential $daCred -dscResourceList $dscResourceList -sqlFilePath $sqlFilePath -ssmsFilePath $ssmsFilePath -ConfigurationData $ConfigDataPath

# 10. Configure target LCM
Set-DscLocalConfigurationManager -Path $sqlMofPath -Verbose -Force

# 11. Apply configuration to target
Start-DscConfiguration -Path $sqlMofPath -ComputerName $targetNode -Wait -Verbose -Force

Restart-Computer -ComputerName $targetSqlServer -Wait -Verbose -Force
#endregion