function Get-Numbers {
    [CmdletBinding(SupportsPaging = $true)]
    param(
    [int]$itemCount
    ) #end param

    # 
    $FirstNumber = [Math]::Min($PSCmdlet.PagingParameters.Skip, $itemCount)
    # If the -First parameter isn't specified the value of $PSCmdlet.PagingParameters.First will be 18446744073709551615, which ensures that the last number will be the total item count.
    # If the -First parameter is less than the total item count, then this value is added to the skip value and selected as the last number.
    $LastNumber = [Math]::Min($PSCmdlet.PagingParameters.First + $FirstNumber - 1, $itemCount)
    
    Write-Debug -Message "Skip: $($PSCmdlet.PagingParameters.Skip)" -Debug
    Write-Debug -Message "First: $($PSCmdlet.PagingParameters.First)" -Debug
    Write-Debug -Message "`$FirstNumber: $FirstNumber"  -Debug
    Write-Debug -Message "`$LastNumber: $LastNumber" -Debug

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $TotalCountAccuracy = 1.0
        $TotalCount = $PSCmdlet.PagingParameters.NewTotalCount($itemCount,$TotalCountAccuracy)
        Write-Output $TotalCount
    }
    # $FirstNumber..$LastNumber | Write-Output
}

$directory = "c:\windows"
$objectCount = (Get-ChildItem -Path $directory).Length

Get-Numbers -itemCount $objectCount -Skip 100 -First 10 -IncludeTotalCount 

