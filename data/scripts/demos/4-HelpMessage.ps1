Function Test-Help {
Param (
  [parameter(Mandatory=$true,
             HelpMessage="Enter computer names separated by commas.")]
  [String[]]$ComputerName
) 

    "Hello $ComputerName"
}

# Note the !? prompt
Test-Help
Get-Help Test-Help -Full




Function Test-CommentHelp {
<#
.SYNOPSIS
Test function
.PARAMETER ComputerName
Enter computer names separated by commas.
#>
Param (
  [parameter(Mandatory=$true)]
  [String[]]$ComputerName
) 

    "Hello $ComputerName"
}

Test-CommentHelp
Get-Help Test-CommentHelp -Full

