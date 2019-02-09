Function Demo1
{
    [CmdletBinding()]
    Param()
    "Hello"
}

Demo1 -

Function Demo2
{
    [CmdletBinding()]
    Param($Name)
    "Hello, $Name."
}

Demo2 -
