# Couldn't get this to work yet on the $PSDebugContext

Function Test-DebugMode {
[CmdletBinding()]
Param(
    $Param1 = "foo"
)

    $MySpecialVariable = "zoo"
    Write-Debug $PSDebugContext
    If ($PSDebugContext -ne $null) {
        Get-Variable -Scope local > .\var.txt
    }
}

#cd $HOME\Documents\Demos
#Test-DebugMode
Test-DebugMode -Debug
