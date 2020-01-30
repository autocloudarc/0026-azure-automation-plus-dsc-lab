function Test-Return
{
    param (
        [string]$a,
        [string]$b
    ) # end param
    $a = 10
    $b = 20
    return $a
} # end function

Test-Return -a 1 -b 2

function Test-CommentBasedHelp
<#
    .SYNOPSIS
        Short description.
    .DESCRIPTION
        Long description
#>
{
    "OK"
} # end function