#requires -version 4.0
#requires -RunAsAdministrator
<#
****************************************************************************************************************************************************************************
PROGRAM		: Provision-NewDiskOnJmp01.ps1
SYNOPSIS	: Provision a previously created empted disk.
DESCRIPTION	: Provision a disk by initializing, partitioning, formating and adding a top level folder.
DISCLAIMER  : THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
            : INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive,
            : royalty-free right to use and modify the Sample Code and to reproduce and distribute the Sample Code, provided that You agree: (i) to not use Our name,
            : logo, or trademarks to market Your software product in which the Sample Code is embedded;
            : (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless,
            : and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys� fees,
            : that arise or result from the use or distribution of the Sample Code.
****************************************************************************************************************************************************************************
#>

<# WORK ITEMS
TASK-INDEX: 000
#>

[CmdletBinding()]
param
(
    [string]$partitionStyle = 'raw',
    [string]$label = "data"
    [string[]]$paths = @('f:\data','f:\data\scripts')
) # end param

# FUNCTIONS

# MAIN
# Initialize, partition and format disk
Get-Disk |
Where-Object { $_.partitionstyle -eq $partitionStyle } |
	Initialize-Disk -PartitionStyle MBR -PassThru |
	New-Partition -DriveLetter F -UseMaximumSize |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel $label -Confirm:$false -Verbose
# Create a new directory structure
New-Item -Path $paths -ItemType Directory -Force -Verbose
# FOOTER