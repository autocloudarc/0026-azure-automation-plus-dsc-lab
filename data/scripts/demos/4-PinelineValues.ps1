Get-PSProvider
Get-PSProvider | gm



Function Get-PipelineObject {
param(
    [parameter(ValueFromPipeline)]
    [System.Management.Automation.ProviderInfo[]]$Provider
)

Process {
    "Process each provider: $($_.Name)"
}

}

Get-PSProvider | Get-PipelineObject




Function Get-PipelineProperty {
param(
    [parameter(ValueFromPipelineByPropertyName)]
    [System.Management.Automation.PSDriveInfo[]]$Drives
)

Process {
    "Process each provider:"
    ForEach ($Drive in $Drives) {
        "    $($Drive.Name)"
    }
}

}

Get-PSProvider | Get-PipelineProperty




Function Get-Pipeline {
param(
    [parameter(ValueFromPipeline)]
    [System.Management.Automation.ProviderInfo[]]$Provider,
    [parameter(ValueFromPipelineByPropertyName)]
    [System.Management.Automation.PSDriveInfo[]]$Drives
)

Process {
    "Process each provider: $($_.Name)"
    ForEach ($Drive in $Drives) {
        "    $($Drive.Name)"
    }
}

}

Get-PSProvider | Get-Pipeline
