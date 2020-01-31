#requires -PSEdition Desktop
#requires -Version 5.1
#requires -RunAsAdministrator

<#
.SYNOPSIS
Install and configure a new development server.

.DESCRIPTION
This script prepares a new development server for the Desired State Configuration Push/Pull roles, as well as the CA role.
The configuratin are accomplished using Desired State Configuration in push mode by installing the pre-requisite roles, features, directories and DSC resources locally.

.PARAMETER domainAdminCred
Domain administrator credentials

.EXAMPLE
# Dot source script
. .\New-DevServerPreReqs.ps1

# Compile configuration
ServerPrereq -OutputPath $devMofPath

# Apply configuration
Start-DscConfiguration -Path $devMofPath -Wait -Verbose -Force

.NOTES
The MIT License (MIT)
Copyright (c) 2018 Preston K. Parsard

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.Â 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.Â 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

.LINK
1. Prepare Data Drive: https://blogs.msdn.microsoft.com/timomta/2016/04/23/how-to-use-powershell-dsc-to-prepare-a-data-drive-on-an-azure-vm/

.COMPONENT
ActiveDirectory,PKI, CA

.ROLE
Systems Engineer
Security Engineer
DevOps Engineer
Infrastructure Engineer

.FUNCTIONALITY
Configure prerequistes on a dev server for DSC pull/push and CA roles
#>

# TASK-ITEM: Turn into funciton or use DSC file resource?
#region Initalize values
$devServerSourceFolder = "c:\devServer\data"
$targetDrive = "f:\"
$devServerTargetFolder = "f:\devServer\data"
$devMofPathInitial = "c:\devServer\data\dsc\mof"
    
# Configure prerequisites
Configuration configDevServerDataDrive
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xStorage

    Node localhost
    {
        # Check for disk
        xWaitForDisk Disk2
        {
            DiskId = '2'
            RetryIntervalSec = 10
            RetryCount = 3
        } # end resource

        # Create F Volume
        xDisk FVolume
        {
            DiskId = '2'
            DriveLetter = 'F'
            FSLabel = 'data'
            DependsOn = '[xWaitForDisk]Disk2'
        } # end resource

        # Copy directory from c:\ to f:\
        File CopyTopLevelDirectory
        {
            Ensure = "Present"
            Type =   "Directory"
            Recurse = $true
            SourcePath = $devServerSourceFolder
            DestinationPath = $devServerTargetFolder
            MatchSource = $true
        } # end File
    } # end node
} # end configuration

# Compile configuration
configDevServerDataDrive -OutputPath $devMofPathInitial -Verbose
# Apply configuration
Start-DscConfiguration -Path $devMofPathInitial -Wait -Verbose -Force

If (Test-Path -path $devServerTargetFolder)
{
    Remove-Item -Path $devServerSourceFolder -Recurse -Force
} # end if
else
{
    Write-Ouput "An error occured while attempting to copy the contents of $devServerSourceFolder to $devServerTargetFolder" -Verbose
    Remove-Item -Path $devServerTargetFolder -Recurse -Force -Verbose
} # end else