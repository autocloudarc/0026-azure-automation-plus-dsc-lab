
Function Get-Example {
Param (
  [parameter(ParameterSetName="Machine")]
  [String[]]$MachineName,
  [parameter(ParameterSetName="User")]
  [String[]]$UserName,
  [parameter()]
  [String[]]$Destination
) 

    If ($MachineName) {
        "Do x"
    }

    If ($UserName) {
        "Do y"
    }

}

Get-Help Get-Example
